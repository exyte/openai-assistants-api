//
//  StreamEventError.swift
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

public enum StreamEvent {

    enum EventName: String {
        case threadRunCreated = "thread.run.created"
        case threadRunQueued = "thread.run.queued"
        case threadRunInProgress = "thread.run.in_progress"
        case threadRunStepCreated = "thread.run.step.created"
        case threadRunStepInProgress = "thread.run.step.in_progress"
        case threadMessageCreated = "thread.message.created"
        case threadMessageInProgress = "thread.message.in_progress"
        case threadMessageDelta = "thread.message.delta"
        case threadMessageCompleted = "thread.message.completed"
        case threadRunStepCompleted = "thread.run.step.completed"
        case threadRunCompleted = "thread.run.completed"
        case done = "done"
    }

    case unknown(Error?)
    case threadRunCreated(Run)
    case threadRunQueued(Run)
    case threadRunInProgress(Run)
    case threadRunStepCreated(RunStep)
    case threadRunStepInProgress(RunStep)
    case threadMessageCreated(Message)
    case threadMessageInProgress(Message)
    case threadMessageDelta(DeltaMessage)
    case threadMessageCompleted(Message)
    case threadRunStepCompleted(RunStep)
    case threadRunCompleted(Run)
    case done

    var eventName: String {
        switch self {
        case .threadRunCreated:
            return EventName.threadRunCreated.rawValue
        case .threadRunQueued:
            return EventName.threadRunQueued.rawValue
        case .threadRunInProgress:
            return EventName.threadRunInProgress.rawValue
        case .threadRunStepCreated:
            return EventName.threadRunStepCreated.rawValue
        case .threadMessageCreated:
            return EventName.threadMessageCreated.rawValue
        case .threadMessageDelta:
            return EventName.threadMessageDelta.rawValue
        case .threadRunStepInProgress:
            return EventName.threadRunStepInProgress.rawValue
        case .threadMessageInProgress:
            return EventName.threadMessageInProgress.rawValue
        case .threadMessageCompleted:
            return EventName.threadMessageCompleted.rawValue
        case .threadRunStepCompleted:
            return EventName.threadRunStepCompleted.rawValue
        case .threadRunCompleted:
            return EventName.threadRunCompleted.rawValue
        case .done:
            return EventName.done.rawValue
        case .unknown:
            return "unknown"
        }
    }

    public init?(eventName: String, data: Data) {
        self = .unknown(nil)
        switch eventName {
        case EventName.threadRunCreated.rawValue,
            EventName.threadRunQueued.rawValue,
            EventName.threadRunInProgress.rawValue,
            EventName.threadRunCompleted.rawValue:

            self = decodeRunEvent(from: data, eventName: eventName) ?? .unknown(StreamError.decodeError)
        case EventName.threadRunStepCreated.rawValue,
            EventName.threadRunStepInProgress.rawValue,
            EventName.threadRunStepCompleted.rawValue:

            self = decodeRunStepEvent(from: data, eventName: eventName) ?? .unknown(StreamError.decodeError)
        case EventName.threadMessageCreated.rawValue,
            EventName.threadMessageInProgress.rawValue,
            EventName.threadMessageCompleted.rawValue:

            self = decodeThreadMessageEvent(from: data, eventName: eventName) ?? .unknown(StreamError.decodeError)
        case EventName.threadMessageDelta.rawValue:

            self = decodeThreadMessageDelta(from: data) ?? .unknown(StreamError.decodeError)
        case EventName.done.rawValue:

            self = .done
        default:
            self = .unknown(StreamError.unknownEvent)
        }
    }

    private func decodeRunEvent(from data: Data, eventName: String) -> StreamEvent? {
        let model: Run? = StreamEvent.decodeData(data)
        var event: StreamEvent?
        guard let model else {
            return nil
        }

        if eventName == EventName.threadRunCreated.rawValue {
            event = .threadRunCreated(model)
        } else if eventName == EventName.threadRunInProgress.rawValue {
            event = .threadRunInProgress(model)
        } else if eventName == EventName.threadRunQueued.rawValue {
            event = .threadRunQueued(model)
        } else if eventName == EventName.threadRunCompleted.rawValue {
            event = .threadRunCompleted(model)
        }

        return event
    }

    private func decodeRunStepEvent(from data: Data, eventName: String) -> StreamEvent? {
        var event: StreamEvent?
        let model: RunStep? = StreamEvent.decodeData(data)
        guard let model else {
            return nil
        }

        if eventName == EventName.threadRunStepCreated.rawValue {
            event = .threadRunStepCreated(model)
        } else if eventName == EventName.threadRunStepInProgress.rawValue {
            event = .threadRunStepInProgress(model)
        } else if eventName == EventName.threadRunStepCompleted.rawValue {
            event = .threadRunStepCompleted(model)
        }

        return event
    }

    private func decodeThreadMessageEvent(from data: Data, eventName: String) -> StreamEvent? {
        var event: StreamEvent?
        let model: Message? = StreamEvent.decodeData(data)
        guard let model else {
            return nil
        }

        if eventName == EventName.threadMessageCreated.rawValue {
            event = .threadMessageCreated(model)
        } else if eventName == EventName.threadMessageInProgress.rawValue {
            event = .threadMessageInProgress(model)
        } else if eventName == EventName.threadMessageCompleted.rawValue {
            event = .threadMessageCompleted(model)
        }

        return event
    }

    private func decodeThreadMessageDelta(from data: Data) -> StreamEvent? {
        var event: StreamEvent?
        let model: DeltaMessage? = StreamEvent.decodeData(data)
        guard let model else {
            return nil
        }

        event = .threadMessageDelta(model)
        return event
    }

    static private func decodeData<T: Decodable>(_ data: Data) -> T? {
        try? OpenAI.defaultDecoder.decode(T.self, from: data)
    }

}
