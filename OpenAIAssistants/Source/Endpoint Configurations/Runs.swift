//
//  Runs.swift
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

enum Runs {

    case createThreadAndRun(payload: CreateThreadAndRunPayload)
    case createRun(threadId: String, payload: CreateRunPayload)
    case listRuns(threadId: String, payload: ListPayload)
    case listRunSteps(threadId: String, runId: String, payload: ListPayload)
    case retrieveRun(threadId: String, runId: String)
    case retrieveRunStep(threadId: String, runId: String, runStepId: String)
    case modifyRun(threadId: String, runId: String, payload: ModifyPayload)
    case cancelRun(threadId: String, runId: String)
    case submitToolOutputs(threadId: String, runId: String, payload: SubmitToolOutputsPayload)

}

extension Runs: EndpointConfiguration {

    var method: HTTPRequestMethod {
        switch self {
        case .createThreadAndRun, .createRun, .modifyRun, .cancelRun, .submitToolOutputs:
            return .post
        case .retrieveRun, .retrieveRunStep, .listRuns, .listRunSteps:
            return .get
        }
    }

    var path: String {
        switch self {
        case .createThreadAndRun:
            return "threads/runs"
        case .createRun(let threadId, _), .listRuns(let threadId, _):
            return "threads/\(threadId)/runs"
        case .retrieveRun(let threadId, let runId), .modifyRun(let threadId, let runId, _):
            return "threads/\(threadId)/runs/\(runId)"
        case .cancelRun(let threadId, let runId):
            return "threads/\(threadId)/runs/\(runId)/cancel"
        case .listRunSteps(let threadId, let runId, _):
            return "/threads/\(threadId)/runs/\(runId)/steps"
        case .retrieveRunStep(let threadId, let runId, let runStepId):
            return "/threads/\(threadId)/runs/\(runId)/steps/\(runStepId)"
        case .submitToolOutputs(let threadId, let runId, _):
            return "/threads/\(threadId)/runs/\(runId)/submit_tool_outputs"
        }
    }

    var task: RequestTask {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        switch self {
        case .createThreadAndRun(let payload):
            return .JSONEncodable(payload)
        case .createRun(_, let payload):
            return .JSONEncodable(payload)
        case .submitToolOutputs(_, _, let payload):
            return .JSONEncodable(payload)
        case .listRuns(_, let payload), .listRunSteps(_, _, let payload):
            return .URLParametersEncodable(payload)
        case .modifyRun(_, _, let payload):
            return .JSONEncodable(payload)
        case .retrieveRun, .retrieveRunStep, .cancelRun:
            return .plain
        }
    }
    
}
