//
//  BotChatView.swift
//  OpenAIAssistantsExample
//
//  Created by Alisa Mylnikova on 25.06.2024.
//

import SwiftUI
import ExyteChat

struct BotChatView: View {

    @StateObject var viewModel = BotChatViewModel()

    var body: some View {
        ChatView(messages: viewModel.messages) { draft in
            viewModel.sendMessage(draft)
        }
        .setAvailableInput(.textOnly)
    }
}
