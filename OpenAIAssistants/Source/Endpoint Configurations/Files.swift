//
//  Files.swift
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

enum Files {
    case uploadFile(payload: FilePayload)
    case listFiles
    case retrieveFile(id: String)
    case deleteFile(id: String)
    case retrieveFileContent(id: String, destination: URL)
}

extension Files: EndpointConfiguration {

    var method: HTTPRequestMethod {
        switch self {
        case .uploadFile:
            return .post
        case .listFiles, .retrieveFile, .retrieveFileContent:
            return .get
        case .deleteFile:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .uploadFile, .listFiles:
            return "files"
        case .retrieveFile(let id), .deleteFile(let id):
            return "files/\(id)"
        case .retrieveFileContent(let id, _):
            return "files/\(id)/content"
        }
    }

    var task: RequestTask {
        switch self {
        case .uploadFile(let payload):
            let data: [FormBodyPart] = [
                FormBodyPart(
                    name: "file",
                    value: .fileURL(payload.fileURL),
                    fileName: payload.fileURL.lastPathComponent
                ),
                FormBodyPart(
                    name: "purpose",
                    value: .plainText(payload.purpose)
                )
            ]
            return .uploadMultipart(data)
        case .listFiles, .retrieveFile, .deleteFile:
            return .plain
        case .retrieveFileContent(let id, let destination):
            return .download(destination)
        }
    }
    
}
