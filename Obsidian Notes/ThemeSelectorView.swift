//
//  ThemeSelectorView.swift
//  Obsidian Notes
//
//  Created by 岡本秀斗 on 2025/07/29.
//

import SwiftUI

struct ThemeSelectorView: View {
    @ObservedObject var store: MemoStore
    @State private var isExpanded = false
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [store.currentTheme.accentColor, store.currentTheme.accentColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "paintbrush")
                        .font(.system(size: 14))
                        .foregroundColor(.obsidianText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.obsidianSecondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                HStack(spacing: 8) {
                    ForEach(ThemeColor.allCases, id: \.self) { theme in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                store.setTheme(theme)
                            }
                        }) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [theme.accentColor, theme.accentColor.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            store.currentTheme == theme ? Color.white : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                                .scaleEffect(store.currentTheme == theme ? 1.2 : 1.0)
                                .shadow(
                                    color: theme.accentColor.opacity(0.3),
                                    radius: store.currentTheme == theme ? 4 : 0
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: store.currentTheme)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
    }
}