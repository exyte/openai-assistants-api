//
//  OpenAI.swift
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

public final class OpenAI {

    let apiKey: String
    let organization: String?

    static var defaultDecoder: JSONDecoder = {
        $0.dateDecodingStrategy = .secondsSince1970
        $0.keyDecodingStrategy = .convertFromSnakeCase
        return $0
    }(JSONDecoder())

    static var baseURL: URL {
        URL(string: "https://api.openai.com/v1")!
    }

    let modelsProvider: Provider<Models>
    let assistantsProvider: Provider<Assistans>
    let threadsProvider: Provider<Threads>
    let messagesProvider: Provider<Messages>
    let runsProvider: Provider<Runs>
    let filesProvider: Provider<Files>

    public init(apiKey: String, organization: String? = nil) {
        self.apiKey = apiKey
        self.organization = organization

        modelsProvider = Provider<Models>(with: apiKey)
        filesProvider = Provider<Files>(with: apiKey)

        assistantsProvider = Provider<Assistans>(with: apiKey)
        threadsProvider = Provider<Threads>(with: apiKey)
        messagesProvider = Provider<Messages>(with: apiKey)
        runsProvider = Provider<Runs>(with: apiKey)
    }

}
