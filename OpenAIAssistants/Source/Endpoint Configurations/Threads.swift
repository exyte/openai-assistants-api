//
//  Threads.swift
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
import Moya

enum Threads {

    case createThread(payload: CreateThreadPayload)
    case retrieveThread(threadId: String)
    case modifyThread(threadId: String, payload: ModifyPayload)
    case deleteThread(threadId: String)

}

extension Threads: EndpointConfiguration {

    var method: HTTPRequestMethod {
        switch self {
        case .createThread, .modifyThread:
            return .post
        case .retrieveThread:
            return .get
        case .deleteThread:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .createThread:
            return "/threads"
        case .retrieveThread(let threadId), .modifyThread(let threadId, _), .deleteThread(let threadId):
            return "/threads/\(threadId)"
        }
    }

    var task: RequestTask {
        switch self {
        case .createThread(let payload):
            return .JSONEncodable(payload)
        case .retrieveThread:
            return .plain
        case .modifyThread(_, let payload):
            return .JSONEncodable(payload)
        case .deleteThread:
            return .plain
        }
    }
    
}
