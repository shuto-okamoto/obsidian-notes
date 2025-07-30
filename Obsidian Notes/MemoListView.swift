//
//  MemoListView.swift
//  Obsidian Notes
//
//  Created by 岡本秀斗 on 2025/07/29.
//

import SwiftUI

struct MemoListView: View {
    @ObservedObject var store: MemoStore
    let filteredMemos: [Memo]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if filteredMemos.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredMemos) { memo in
                        NavigationLink(destination: MemoEditorView(store: store, memo: memo)) {
                            MemoRowView(
                                memo: memo,
                                isSelected: store.selectedMemo?.id == memo.id,
                                accentColor: store.currentTheme.accentColor,
                                onDelete: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        store.deleteMemo(memo)
                                    }
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(Color.obsidianLight)
                        .onTapGesture {
                            store.selectMemo(memo)
                        }
                    }
                }
            }
        }
        .background(Color.obsidianLight)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "note.text")
                .font(.system(size: 48))
                .foregroundColor(.obsidianSecondary.opacity(0.4))
            
            VStack(spacing: 4) {
                Text("No memos found")
                    .font(.headline)
                    .foregroundColor(.obsidianText)
                
                Text("Create your first memo")
                    .font(.caption)
                    .foregroundColor(.obsidianSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}

struct MemoRowView: View {
    let memo: Memo
    let isSelected: Bool
    let accentColor: Color
    let onDelete: () -> Void
    
    @State private var showDeleteButton = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(memo.displayTitle)
                        .font(.headline)
                        .foregroundColor(isSelected ? accentColor : .obsidianText)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Text(memo.preview)
                    .font(.body)
                    .foregroundColor(.obsidianSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.obsidianSecondary)
                    
                    Text(formatDate(memo.updatedAt))
                        .font(.caption)
                        .foregroundColor(.obsidianSecondary)
                    
                    Spacer()
                    
                    if isSelected {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: showDeleteButton)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .background(
            Rectangle()
                .fill(isSelected ? Color.obsidianDark : Color.clear)
                .overlay(
                    Rectangle()
                        .fill(isSelected ? accentColor : Color.clear)
                        .frame(width: 4),
                    alignment: .leading
                )
        )
        .overlay(
            Rectangle()
                .fill(Color.obsidianBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let days = components.day, days > 0 {
            if days == 1 {
                return "1d ago"
            } else if days < 7 {
                return "\(days)d ago"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return formatter.string(from: date)
            }
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
}