//
//  Provider.swift
//
//  Copyright (c) 2024 Exyte
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Combine

open class Provider<T: EndpointConfiguration> {
    
    private let mandatoryHeaders: [HTTPHeader]
    
    public init(with apiKey: String) {
        mandatoryHeaders = [
            .authorization(bearerToken: apiKey),
            .openAIBeta(value: "assistants=v2")
        ]
    }
    
    open func requestPublisher(for endpoint: T) -> AnyPublisher<URLSession.DataTaskPublisher.Output, OpenAIError> {
        createRequestPublisher(for: endpoint)
            .flatMap { [weak self] in
                guard let self else {
                    return Fail<URLSession.DataTaskPublisher.Output, OpenAIError>(error: OpenAIError.requestMappingFailed)
                        .eraseToAnyPublisher()
                }
                return self.dataTaskPublisher(for: $0)
            }
            .eraseToAnyPublisher()
    }
    
    open func downloadTaskPublisher(for endpoint: T) -> AnyPublisher<URL, OpenAIError> {
        Future<URL, OpenAIError> { promise in
            guard case let .download(destinationURL) = endpoint.task else {
                promise(.failure(OpenAIError.incompatibleRequestTask))
                return
            }
            var urlRequest = URLRequest(url: OpenAI.baseURL.appending(path: endpoint.path))
            urlRequest.httpMethod = endpoint.method.rawValue
            URLSession.shared.downloadTask(with: urlRequest) { url, response, error in
                guard let response = response as? HTTPURLResponse else {
                    promise(.failure(OpenAIError.invalidResponse))
                    return
                }
                let statusCode = response.statusCode
                guard 200...299 ~= response.statusCode else {
                    promise(.failure(OpenAIError.statusCode(statusCode)))
                    return
                }
                if let error {
                    promise(.failure(OpenAIError.downloadFailed(error.localizedDescription)))
                    return
                }
                guard let url else {
                    promise(.failure(OpenAIError.emptyFileURL))
                    return
                }
                do {
                    try FileManager.default.moveItem(at: url, to: destinationURL)
                    promise(.success(destinationURL))
                } catch {
                    promise(.failure(.saveFailed(error.localizedDescription)))
                }
            }
            .resume()
        }.eraseToAnyPublisher()
    }
    
    private func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, OpenAIError> {
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse else {
                    throw OpenAIError.invalidResponse
                }
                let statusCode = response.statusCode
                guard 200...299 ~= response.statusCode else {
                    throw OpenAIError.statusCode(statusCode)
                }
                return result
            }
            .mapError { error -> OpenAIError in
                switch error {
                case let apiError as OpenAIError:
                    return apiError
                default:
                    return OpenAIError.underlying(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func createRequestPublisher(for endpoint: T) -> AnyPublisher<URLRequest, OpenAIError> {
        Future<URLRequest, OpenAIError> { [weak self] promise in
            guard let self else {
                promise(.failure(.requestMappingFailed))
                return
            }
            let url = OpenAI.baseURL.appending(path: endpoint.path)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = endpoint.method.rawValue
            switch endpoint.task {
            case .plain:
                urlRequest.allHTTPHeaderFields = mandatoryHeaders.dictionary
                promise(.success(urlRequest))
            case .JSONEncodable(let encodable):
                var headers = mandatoryHeaders
                headers.append(.contentType(value: MimeType.json))
                urlRequest.allHTTPHeaderFields = headers.dictionary
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                if let data = try? encoder.encode(encodable) {
                    urlRequest.httpBody = data
                }
                promise(.success(urlRequest))
            case .URLParametersEncodable(let encodable):
                urlRequest.allHTTPHeaderFields = mandatoryHeaders.dictionary
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                let parameters: [String: Any]
                if let data = try? encoder.encode(encodable) {
                    parameters = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
                        .flatMap { $0 as? [String: Any] } ?? [:]
                } else {
                    parameters = [:]
                }
                guard !parameters.isEmpty else {
                    promise(.success(urlRequest))
                    return
                }
                guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                    promise(.failure(.encodingFailed))
                    return
                }
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + parameters.map { "\($0)=\($1)" }.joined(separator: "&")
                urlComponents.percentEncodedQuery = percentEncodedQuery
                urlRequest.url = urlComponents.url
                promise(.success(urlRequest))
            case .uploadMultipart(let formData):
                do {
                    let multipartBody = try self.createMultipartBody(with: formData)
                    var headers = mandatoryHeaders
                    headers.append(.contentType(value: multipartBody.contentType))
                    urlRequest.allHTTPHeaderFields = headers.dictionary
                    urlRequest.httpBody = multipartBody.body
                    promise(.success(urlRequest))
                } catch {
                    switch error {
                    case let apiError as OpenAIError:
                        promise(.failure(apiError))
                    default:
                        promise(.failure(OpenAIError.underlying(error)))
                    }
                }
            case .download:
                promise(.success(urlRequest))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func createMultipartBody(with bodyParts: [FormBodyPart]) throws -> (contentType: String, body: Data) {
        var body = Data()

        let boundary = "Boundary-\(UUID().uuidString)"
        let boundaryPrefix = "--\(boundary)\r\n"
        let crlf = "\r\n"
        
        guard let boundaryPrefixData = boundaryPrefix.data(using: .utf8) else {
            throw OpenAIError.multipartEncoding(.dataEncodingFailed)
        }
        
        try bodyParts.forEach {
            body.append(boundaryPrefixData)
            var contentDisposition = "Content-Disposition: form-data; name=\"\($0.name)\""
            if let fileName = $0.fileName {
                contentDisposition.append("; filename=\"\(fileName)\"")
            }
            contentDisposition.append(crlf)
            guard let contentDispositionData = contentDisposition.data(using: .utf8) else {
                throw OpenAIError.multipartEncoding(.dataEncodingFailed)
            }
            body.append(contentDispositionData)
            let mimeType: String
            let bodyData: Data
            switch $0.value {
            case .data(let data):
                mimeType = $0.mimeType ?? MimeType.unknownBinary
                bodyData = data
            case .fileURL(let url):
                mimeType = $0.mimeType ?? url.mimeType
                guard url.isFileURL else {
                    throw OpenAIError.multipartEncoding(.invalidBodyPartURL)
                }
                guard try url.checkPromisedItemIsReachable() else {
                    throw OpenAIError.multipartEncoding(.fileNotReachable)
                }
                bodyData = try Data(contentsOf: url)
            case .plainText(let text):
                mimeType = $0.mimeType ?? MimeType.text
                guard let textData = text.data(using: .utf8) else {
                    throw OpenAIError.multipartEncoding(.dataEncodingFailed)
                }
                bodyData = textData
            }
            body.append("Content-Type: \(mimeType)\(crlf)\(crlf)".data(using: String.Encoding.utf8)!)
            body.append(bodyData)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
        }
        body.append("--\(boundary)--\(crlf)".data(using: String.Encoding.utf8)!)

        return (
            contentType: "multipart/form-data; boundary=\(boundary)",
            body: body
        )
    }
    
}
