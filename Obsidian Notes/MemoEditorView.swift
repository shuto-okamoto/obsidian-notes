//
//  MemoEditorView.swift
//  Obsidian Notes
//
//  Created by 岡本秀斗 on 2025/07/29.
//

import SwiftUI

struct MemoEditorView: View {
    @ObservedObject var store: MemoStore
    let memo: Memo
    
    @State private var title: String
    @State private var content: String
    @State private var saveTimer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    init(store: MemoStore, memo: Memo) {
        self.store = store
        self.memo = memo
        self._title = State(initialValue: memo.title)
        self._content = State(initialValue: memo.content)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Editor Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title Input
                    TextField("Untitled", text: $title)
                        .font(.largeTitle.bold())
                        .foregroundColor(.obsidianText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: title) { _ in
                            scheduleAutoSave()
                        }
                    
                    // Content Editor
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Start writing your memo...")
                                .font(.body)
                                .foregroundColor(.obsidianSecondary.opacity(0.6))
                                .padding(.top, 8)
                        }
                        
                        TextEditor(text: $content)
                            .font(.body)
                            .foregroundColor(.obsidianText)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 400)
                            .onChange(of: content) { _ in
                                scheduleAutoSave()
                            }
                    }
                }
                .padding(24)
            }
            .background(Color.obsidianDark)
            
            // Footer
            footerView
        }
        .background(Color.obsidianDark)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    saveChanges()
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.body)
                    }
                    .foregroundColor(store.currentTheme.accentColor)
                }
            }
        }
        .onDisappear {
            saveChanges()
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Last updated: \(formatDate(memo.updatedAt))")
                .font(.caption)
                .foregroundColor(.obsidianSecondary)
            
            Spacer()
            
            HStack(spacing: 16) {
                Text("\(wordCount) words")
                    .font(.caption)
                    .foregroundColor(.obsidianSecondary)
                
                Text("\(content.count) characters")
                    .font(.caption)
                    .foregroundColor(.obsidianSecondary)
                
                Circle()
                    .fill(store.currentTheme.accentColor)
                    .frame(width: 8, height: 8)
                    .opacity(0.8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.obsidianLight)
        .overlay(
            Rectangle()
                .fill(Color.obsidianBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var footerView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundColor(.obsidianSecondary)
                
                Text("Auto-save enabled")
                    .font(.caption)
                    .foregroundColor(.obsidianSecondary)
            }
            
            Spacer()
            
            Button(action: saveChanges) {
                HStack(spacing: 8) {
                    Text("Save Now")
                        .font(.system(size: 14, weight: .medium))
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 12))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [store.currentTheme.accentColor, store.currentTheme.accentColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: store.currentTheme.accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: store.currentTheme)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [store.currentTheme.accentColor.opacity(0.05), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .overlay(
            Rectangle()
                .fill(Color.obsidianBorder)
                .frame(height: 1),
            alignment: .top
        )
    }
    
    private var wordCount: Int {
        let words = content.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return words.count
    }
    
    private func scheduleAutoSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            saveChanges()
        }
    }
    
    private func saveChanges() {
        var updatedMemo = memo
        updatedMemo.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedMemo.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        store.updateMemo(updatedMemo)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}