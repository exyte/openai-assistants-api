//
//  BotChatViewModel.swift
//  OpenAIAssistantsExample
//
//  Created by Alisa Mylnikova on 25.06.2024.
//

import Foundation
import ExyteChat

class BotChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = []

    private var aiManager = AIManager.shared

    private var me = User(id: "me", name: "Me", avatarURL: nil, isCurrentUser: true)
    private var bot = User(id: "bot", name: "AIBot", avatarURL: nil, isCurrentUser: false)

    func sendMessage(_ draft: DraftMessage) {
        Task {
            let message = await Message.makeMessage(id: UUID().uuidString, user: me, draft: draft)
            DispatchQueue.main.async {
                self.messages.append(message)
            }
            let (id, text) = await aiManager.getBotResponse(draft.text)
            let responseMessage = Message(id: id, user: bot, status: .sent, createdAt: Date(), text: text)
            DispatchQueue.main.async {
                self.messages.append(responseMessage)
            }
        }
    }
}
