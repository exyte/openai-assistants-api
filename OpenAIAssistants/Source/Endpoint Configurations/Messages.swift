//
//  Messages.swift
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

enum Messages {

    case createMessage(threadId: String, payload: CreateMessagePayload)
    case listMessages(threadId: String, payload: ListPayload)
    case retrieveMessage(threadId: String, messageId: String)
    case retrieveMessageFile(threadId: String, messageId: String, fileId: String)
    case modifyMessage(threadId: String, messageId: String, payload: ModifyPayload)
    case listMessageFiles(threadId: String, messageId: String, payload: ListPayload)

}

extension Messages: EndpointConfiguration {

    var method: HTTPRequestMethod {
        switch self {
        case .createMessage, .modifyMessage:
            return .post
        case .retrieveMessage, .retrieveMessageFile, .listMessages, .listMessageFiles:
            return .get
        }
    }

    var path: String {
        switch self {
        case .createMessage(let threadId, _), .listMessages(let threadId, _):
            return "threads/\(threadId)/messages"
        case .retrieveMessage(let threadId, let messageId), .modifyMessage(let threadId, let messageId, _):
            return "threads/\(threadId)/messages/\(messageId)"
        case .listMessageFiles(let threadId, let messageId, _):
            return "threads/\(threadId)/messages/\(messageId)/files"
        case .retrieveMessageFile(let threadId, let messageId, let fileId):
            return "threads/\(threadId)/messages/\(messageId)/files/\(fileId)"
        }
    }

    var task: RequestTask {
        switch self {
        case .createMessage(_, let payload):
            return .JSONEncodable(payload)
        case .listMessages(_, let payload), .listMessageFiles(_, _, let payload):
            return .URLParametersEncodable(payload)
        case .modifyMessage(_, _, let payload):
            return .JSONEncodable(payload)
        case .retrieveMessage, .retrieveMessageFile:
            return .plain
        }
    }
    
}
