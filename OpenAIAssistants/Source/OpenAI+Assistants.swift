//
//  OpenAI+Assistants.swift
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

    func createAssistant(from payload: CreateAssistantPayload) -> AnyPublisher<Assistant, OpenAIError> {
        assistantsProvider.requestPublisher(for: .createAssistant(payload: payload))
            .map { $0.data }
            .decode(type: Assistant.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func modifyAssistant(id: String, payload: CreateAssistantPayload) -> AnyPublisher<Assistant, OpenAIError> {
        assistantsProvider.requestPublisher(
            for: .modifyAssistant(
                assistantId: id,
                payload: payload
            )
        )
            .map { $0.data }
            .decode(type: Assistant.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func deleteAssistant(id: String) -> AnyPublisher<DeletionStatus, OpenAIError> {
        assistantsProvider.requestPublisher(for: .deleteAssistant(assistantId: id))
            .map { $0.data }
            .decode(type: DeletionStatus.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func listAssistants(payload: ListPayload) -> AnyPublisher<ObjectList<Assistant>, OpenAIError> {
        assistantsProvider.requestPublisher(for: .listAssistants(payload: payload))
            .map { $0.data }
            .decode(type: ObjectList<Assistant>.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func retrieveAssistant(id: String) -> AnyPublisher<Assistant, OpenAIError> {
        assistantsProvider.requestPublisher(for: .retrieveAssistant(assistantId: id))
            .map { $0.data }
            .decode(type: Assistant.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

    func deleteAssistantFile(id: String, from assistantId: String) -> AnyPublisher<DeletionStatus, OpenAIError> {
        assistantsProvider.requestPublisher(
            for: .deleteAssistantFile(
                assistantId: assistantId,
                fileId: id
            )
        )
            .map { $0.data }
            .decode(type: DeletionStatus.self, decoder: OpenAI.defaultDecoder)
            .mapError { OpenAIError.decodingFailed($0) }
            .eraseToAnyPublisher()
    }

}
