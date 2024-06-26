//
//  AIManager.swift
//  OpenAIAssistantsExample
//
//  Created by Alisa Mylnikova on 25.06.2024.
//

import Foundation
import Combine
import OpenAIAssistants

final class AIManager {

    static let shared = AIManager()

    private var apiKey: String {
        ""
    }

    private var assistID: String {
        ""
    }

    private var client: OpenAI?
    private var threadID = ""
    private var didReceiveResponse: ((String, String)->())?
    private var subscriptions = Set<AnyCancellable>()

    init() {
        client = OpenAI(apiKey: apiKey)
        createThreadIfNeeded()
    }

    func getBotResponse(_ messageText: String) async -> (String, String) { // id, text
        await withCheckedContinuation { continuation in
            didReceiveResponse = { id, text in
                continuation.resume(returning: (id, text))
                self.didReceiveResponse = nil
            }
            sendMessage(messageText, fileID: nil)
        }
    }
}

private extension AIManager {

    func createThreadIfNeeded() {
        if let threadID = UserDefaults.standard.value(forKey: "thread_id") as? String {
            self.threadID = threadID
        } else {
            createThread()
        }
    }

    func createThread() {
        guard let client else { return }

        let createThreadPayload = CreateThreadPayload(
            messages: [],
            metadata: [:]
        )
        client.createThread(from: createThreadPayload)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] thread in
                    self?.threadID = thread.id
                    UserDefaults.standard.setValue(thread.id, forKey: "thread_id")
                })
            .store(in: &subscriptions)
    }

    func sendMessage(_ messageText: String, fileID: String?) {
        guard let client else { return }

        let createMessagePayload = CreateMessagePayload(role: .user, content: messageText)

        client.createMessage(in: threadID, payload: createMessagePayload)
            .sink { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] message in
                self?.createRun(lastMessageID: message.id)
            }
            .store(in: &subscriptions)
    }

    func sendMessage(_ messageText: String, fileURL: URL) {
        guard let client else { return }

        let filePayload = FilePayload(purpose: .assistants, fileURL: fileURL)
        client.uploadFile(payload: filePayload)
            .sink { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] file in
                guard let self else { return }
                sendMessage(messageText, fileID: file.id)
            }
            .store(in: &subscriptions)
    }

    func createRun(lastMessageID: String) {
        guard let client else { return }

        let runPayload = CreateRunPayload(assistantId: assistID)
        client.createRun(in: threadID, payload: runPayload)
            .sink { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] run in
                guard let self else { return }

                checkRunStatus(runID: run.id, lastMessageID: lastMessageID)
            }
            .store(in: &subscriptions)
    }

    func checkRunStatus(runID: String, lastMessageID: String) {
        guard let client else { return }

        client.retrieveRun(id: runID, from: threadID)
            .sink { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] run in
                guard let self else { return }

                if run.status != .completed {
                    usleep(300)
                    checkRunStatus(runID: runID, lastMessageID: lastMessageID)
                } else {
                    fetchResponse(lastMessageID: lastMessageID)
                }
            }
            .store(in: &subscriptions)
    }

    func fetchResponse(lastMessageID: String) {
        guard let client else { return }

        let listPayload = ListPayload(limit: 1, after: lastMessageID)
        client.listMessages(from: threadID, payload: listPayload)
            .sink { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] list in
                guard let self,
                      let message = list.data.first else { return }

                didReceiveResponse?(message.id, message.content.first?.text?.value ?? "")
            }
            .store(in: &subscriptions)
    }
}
