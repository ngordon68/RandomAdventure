//
//  LearningModelForMap.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 9/15/25.
//
//
import Foundation
import FoundationModels
import SwiftUI


struct ChatGPTTestView: View {
    @State var chatInput: String = ""
    @State var chatOutput: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Testing Foundaton Model Framework")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 8) {
                Text("Ask a question")
                    .font(.headline)
                TextField("Type your question here...", text: $chatInput, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
            }

            HStack {
                Button(action: {
                    Task { try? await generateResponse() }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Generate Response")
                            .foregroundStyle(.black)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Button("Clear") {
                    chatInput = ""
                    chatOutput = ""
                    errorMessage = nil
                }
                .buttonStyle(.bordered)
                .disabled(isLoading)
            }

            Group {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.callout)
                        .accessibilityLabel("Error: \(errorMessage)")
                } else if isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Thinking...")
                            .foregroundStyle(.secondary)
                    }
                } else if !chatOutput.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Response")
                            .font(.headline)
                        ScrollView {
                            Text(chatOutput)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                                .padding(12)
                        }
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    Text("Your response will appear here.")
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
    }

    @MainActor
    func generateResponse() async throws {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let trimmed = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a question before generating a response."
            return
        }

        let instructions = """
            You are a helpful tourist. Answer the user's question clearly and concisely.
            If the user asks for ideas, provide a short bulleted list. Keep responses under 200 words.
            """

        do {
            let session = LanguageModelSession(instructions: instructions)
            let response = try await session.respond(to: trimmed)
            chatOutput = response.content
        } catch {
            errorMessage = "Failed to generate a response. Please try again. (\(error.localizedDescription))"
        }
    }
}

#Preview {
    ChatGPTTestView()
}
