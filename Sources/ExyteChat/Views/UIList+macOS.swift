//
//  UIList+macOS.swift
//  Chat
//

import SwiftUI
import Combine

#if os(macOS)
public extension Notification.Name {
    static let onScrollToBottom = Notification.Name("onScrollToBottom")
}

struct UIList<MessageContent: View>: View {

    typealias MessageBuilderParamsClosure = ChatView<MessageContent, InputView, DefaultMessageMenuAction>.MessageBuilderParamsClosure

    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var inputViewModel: InputViewModel

    @Binding var isScrolledToBottom: Bool
    @Binding var shouldScrollToTop: () -> ()
    @Binding var tableContentHeight: CGFloat

    let messageBuilder: MessageBuilderParamsClosure
    let mainHeaderBuilder: (() -> AnyView)?
    let dateHeaderBuilder: ((Date) -> AnyView)?

    let type: ChatType
    let sections: [MessagesSection]
    let ids: [String]

    let chatParams: ChatCustomizationParameters
    let messageParams: MessageCustomizationParameters
    @Binding var timeViewWidth: CGFloat
    @Binding var reactionViewWidth: CGFloat
    @State private var contentSize: CGSize = .zero

    private let bottomID = "exyte-chat-macos-bottom"
    private let topID = "exyte-chat-macos-top"

    var body: some View {
        ScrollViewReader { proxy in
            // On macOS, we use a standard ScrollView with a LazyVStack instead of UITableView.
            // To simulate the "bottom-up" behavior typical of chat apps, we reverse the
            // sections and rows for the conversation view type.
            ScrollView {
                LazyVStack(spacing: 0) {
                    Color.clear
                        .frame(height: 0)
                        .id(topID)

                    ForEach(Array(displaySections.enumerated()), id: \.element.date) { sectionIndex, section in
                        sectionHeader(section: section, sectionIndex: sectionIndex)

                        ForEach(displayRows(for: section), id: \.id) { row in
                            ChatMessageView(
                                viewModel: viewModel,
                                messageBuilder: messageBuilder,
                                row: row,
                                chatType: type,
                                messageParams: messageParams,
                                timeViewWidth: $timeViewWidth,
                                reactionViewWidth: $reactionViewWidth,
                                isDisplayingMessageMenu: false
                            )
                            .onAppear {
                                chatParams.onWillDisplayCell?(row.message)
                            }
                        }
                    }

                    Color.clear
                        .frame(height: 0)
                        .id(bottomID)
                }
                .sizeGetter($contentSize)
            }
            .disabled(!chatParams.isScrollEnabled)
            .onAppear {
                isScrolledToBottom = true
                shouldScrollToTop = {
                    proxy.scrollTo(topID, anchor: .top)
                }
                scrollToInitialPosition(proxy)
            }
            .onReceive(NotificationCenter.default.publisher(for: .onScrollToBottom)) { _ in
                // Scroll to the latest message when requested via notification.
                withAnimation {
                    proxy.scrollTo(bottomID, anchor: .bottom)
                }
            }
            .onChange(of: ids) {
                // Automatically scroll to bottom when new messages arrive in conversation mode.
                guard type == .conversation else { return }
                withAnimation {
                    proxy.scrollTo(bottomID, anchor: .bottom)
                }
            }
            .onChange(of: chatParams.scrollToMessageID) {
                guard let messageID = chatParams.scrollToMessageID else { return }
                withAnimation {
                    proxy.scrollTo(messageID, anchor: .center)
                }
            }
            .onChange(of: contentSize) {
                tableContentHeight = contentSize.height
            }
        }
    }

    // In conversation mode, sections and rows are reversed so the latest message appears
    // at the bottom of the scroll view, simulating the inverted-table behavior of UIKit.
    private var displaySections: [MessagesSection] {
        switch type {
        case .conversation:
            return Array(sections.reversed())
        case .comments:
            return sections
        }
    }

    private func displayRows(for section: MessagesSection) -> [MessageRow] {
        switch type {
        case .conversation:
            return Array(section.rows.reversed())
        case .comments:
            return section.rows
        }
    }

    private func scrollToInitialPosition(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            if let messageID = chatParams.scrollToMessageID {
                proxy.scrollTo(messageID, anchor: .center)
            } else if type == .conversation {
                proxy.scrollTo(bottomID, anchor: .bottom)
            } else {
                proxy.scrollTo(topID, anchor: .top)
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(section: MessagesSection, sectionIndex: Int) -> some View {
        if shouldShowSectionHeader(sectionIndex: sectionIndex) {
            if let mainHeaderBuilder, sectionIndex == 0 {
                VStack(spacing: 0) {
                    mainHeaderBuilder()
                    dateView(section: section)
                }
            } else {
                dateView(section: section)
            }
        }
    }

    private func shouldShowSectionHeader(sectionIndex: Int) -> Bool {
        chatParams.showDateHeaders || (sectionIndex == 0 && mainHeaderBuilder != nil)
    }

    @ViewBuilder
    private func dateView(section: MessagesSection) -> some View {
        if chatParams.showDateHeaders {
            if let dateHeaderBuilder {
                dateHeaderBuilder(section.date)
            } else {
                Text(section.formattedDate)
                    .font(.system(size: 11))
                    .padding(.top, 30)
                    .padding(.bottom, 8)
                    .foregroundColor(.gray)
            }
        }
    }
}
#endif
