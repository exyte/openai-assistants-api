//
//  OpenAI+Messages.swift
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

public extension OpenAI {

    func createMessage(in threadId: String, payload: CreateMessagePayload) -> AnyPublisher<Message, OpenAIError> {
        messagesProvider.requestPublisher(for: .createMessage(threadId: threadId, payload: payload))
            .map { $0.data }
            .decode(type: Message.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func listMessages(from threadId: String, payload: ListPayload) -> AnyPublisher<ObjectList<Message>, OpenAIError> {
        messagesProvider.requestPublisher(
            for: .listMessages(
                threadId: threadId,
                payload: payload
            )
        )
            .map { $0.data }
            .decode(type: ObjectList<Message>.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func retrieveMessage(id: String, from threadId: String) -> AnyPublisher<Message, OpenAIError> {
        messagesProvider.requestPublisher(
            for: .retrieveMessage(
                threadId: threadId,
                messageId: id
            )
        )
            .map { $0.data }
            .decode(type: Message.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func modifyMessage(id: String, from threadId: String, payload: ModifyPayload) -> AnyPublisher<Message, OpenAIError> {
        messagesProvider.requestPublisher(
            for: .modifyMessage(
                threadId: threadId,
                messageId: id,
                payload: payload
            )
        )
            .map { $0.data }
            .decode(type: Message.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

}
