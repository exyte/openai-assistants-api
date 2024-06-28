//
//  Assistants.swift
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

enum Assistans {

    case createAssistant(payload: CreateAssistantPayload)
    case listAssistants(payload: ListPayload)
    case retrieveAssistant(assistantId: String)
    case modifyAssistant(assistantId: String, payload: CreateAssistantPayload)
    case deleteAssistant(assistantId: String)
    case createAssistantFile(assistantId: String, payload: CreateAssistantFilePayload)
    case listAssistantFiles(assistantId: String, payload: ListPayload)
    case retrieveAssistantFile(assistantId: String, fileId: String)
    case deleteAssistantFile(assistantId: String, fileId: String)

}

extension Assistans: EndpointConfiguration {

    var method: HTTPRequestMethod {
        switch self {
        case .createAssistant, .modifyAssistant, .createAssistantFile:
            return .post
        case .listAssistants, .listAssistantFiles, .retrieveAssistant, .retrieveAssistantFile:
            return .get
        case .deleteAssistant, .deleteAssistantFile:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .createAssistant, .listAssistants:
            return "/assistants"
        case .retrieveAssistant(let assistantId), .modifyAssistant(let assistantId, _), .deleteAssistant(let assistantId):
            return "/assistants/\(assistantId)"
        case .listAssistantFiles(let assistantId, _), .createAssistantFile(let assistantId, _):
            return "/assistants/\(assistantId)/files"
        case .retrieveAssistantFile(let assistantId, let fileId), .deleteAssistantFile(let assistantId, let fileId):
            return "/assistants/\(assistantId)/files/\(fileId)"
        }
    }

    var task: RequestTask {
        switch self {
        case .createAssistant(let payload):
            return .JSONEncodable(payload)
        case .listAssistants(let payload), .listAssistantFiles(_, let payload):
            return .URLParametersEncodable(payload)
        case .modifyAssistant(_, let payload):
            return .JSONEncodable(payload)
        case .retrieveAssistant, .deleteAssistant, .retrieveAssistantFile, .deleteAssistantFile:
            return .plain
        case .createAssistantFile(_, let payload):
            return .JSONEncodable(payload)
        }
    }
    
}
