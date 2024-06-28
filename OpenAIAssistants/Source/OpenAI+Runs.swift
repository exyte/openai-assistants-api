//
//  OpenAI+Runs.swift
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
import EventSourceHttpBody

public extension OpenAI {

    func createRun(in threadId: String, payload: CreateRunPayload) -> AnyPublisher<Run, OpenAIError> {
        runsProvider.requestPublisher(
            for: .createRun(
                threadId: threadId,
                payload: payload
            )
        )
        .map { $0.data }
        .decode(type: Run.self, decoder: OpenAI.defaultDecoder)
        .mapError { OpenAIError.decodingFailed($0) }
        .eraseToAnyPublisher()
    }

    func createStreamRun(in threadId: String, payload: CreateStreamRunPayload) -> AnyPublisher<StreamEvent, StreamError> {
        let subject = PassthroughSubject<StreamEvent, StreamError>()

        let url = OpenAI.baseURL.appending(path: "threads/\(threadId)/runs")
        let headers: [HTTPHeader] = [
            .authorization(bearerToken: apiKey),
            .contentType(value: MimeType.json),
            .openAIBeta(value: "assistants=v2")
        ]
        var request = URLRequest(url: url)
        request.httpMethod = HTTPRequestMethod.post.rawValue
        request.allHTTPHeaderFields = headers.dictionary

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            request.httpBody = try encoder.encode(payload)
        } catch {
            subject.send(completion: .failure(.invalidJSON))
        }

        let src = EventSource(urlRequest: request)
        src.onMessage { id, event, content in
            guard let event,
                  let data = content?.data(using: .utf8) else { return }
            
            if let streamEvent = StreamEvent(eventName: event, data: data) {
                subject.send(streamEvent)
            }
        }
        src.connect()
        return subject.handleEvents(
            receiveCancel: {
                src.disconnect()
            }
        ).eraseToAnyPublisher()
    }

    func createThreadAndRun(from payload: CreateThreadAndRunPayload) -> AnyPublisher<Run, OpenAIError> {
        runsProvider.requestPublisher(for: .createThreadAndRun(payload: payload))
            .map { $0.data }
            .decode(type: Run.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func listRuns(from threadId: String, payload: ListPayload) -> AnyPublisher<ObjectList<Run>, OpenAIError> {
        runsProvider.requestPublisher(
            for: .listRuns(
                threadId: threadId,
                payload: payload
            )
        )
            .map { $0.data }
            .decode(type: ObjectList<Run>.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func retrieveRun(id: String, from threadId: String) -> AnyPublisher<Run, OpenAIError> {
        runsProvider.requestPublisher(
            for: .retrieveRun(
                threadId: threadId,
                runId: id
            )
        )
            .map { $0.data }
            .decode(type: Run.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func modifyRun(id: String, from threadId: String, payload: ModifyPayload) -> AnyPublisher<Run, OpenAIError> {
        runsProvider.requestPublisher(
            for: .modifyRun(
                threadId: threadId,
                runId: id,
                payload: payload
            )
        )
            .map { $0.data }
            .decode(type: Run.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func cancelRun(id: String, from threadId: String) -> AnyPublisher<Run, OpenAIError> {
        runsProvider.requestPublisher(
            for: .cancelRun(
                threadId: threadId,
                runId: id
            )
        )
            .map { $0.data }
            .decode(type: Run.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func submitToolOutputs(to runId: String, from threadId: String, payload: SubmitToolOutputsPayload) -> AnyPublisher<Run, OpenAIError> {
        runsProvider.requestPublisher(
            for: .submitToolOutputs(
                threadId: threadId,
                runId: runId,
                payload: payload
            )
        )
            .map { $0.data }
            .decode(type: Run.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func listRunSteps(from runId: String, in threadId: String, payload: ListPayload) -> AnyPublisher<ObjectList<RunStep>, OpenAIError> {
        runsProvider.requestPublisher(
            for: .listRunSteps(
                threadId: threadId,
                runId: runId,
                payload: payload
            )
        )
            .map { $0.data }
            .decode(type: ObjectList<RunStep>.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func retrieveRunStep(id: String, from runId: String, in threadId: String) -> AnyPublisher<RunStep, OpenAIError> {
        runsProvider.requestPublisher(
            for: .retrieveRunStep(
                threadId: threadId,
                runId: runId,
                runStepId: id
            )
        )
            .map { $0.data }
            .decode(type: RunStep.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

}
