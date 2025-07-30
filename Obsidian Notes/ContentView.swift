//
//  ContentView.swift
//  Obsidian Notes
//
//  Created by 岡本秀斗 on 2025/07/29.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = MemoStore()
    @State private var searchText = ""
    
    var filteredMemos: [Memo] {
        store.filteredMemos(searchText: searchText)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                searchBarView
                MemoListView(store: store, filteredMemos: filteredMemos)
            }
            .background(Color.obsidianLight)
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
        .background(Color.obsidianDark)
    }
    
    private var headerView: some View {
        HStack {
            // App Icon and Title
            HStack(spacing: 12) {
                // Crystal Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.obsidianDark,
                                    Color.obsidianLight,
                                    Color.obsidianBorder
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.obsidianBorder, lineWidth: 1)
                        )
                    
                    // Crystal Shape
                    Path { path in
                        path.move(to: CGPoint(x: 16, y: 8))
                        path.addLine(to: CGPoint(x: 22, y: 14))
                        path.addLine(to: CGPoint(x: 20, y: 20))
                        path.addLine(to: CGPoint(x: 16, y: 26))
                        path.addLine(to: CGPoint(x: 12, y: 20))
                        path.addLine(to: CGPoint(x: 10, y: 14))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [
                                store.currentTheme.accentColor.opacity(0.9),
                                store.currentTheme.accentColor.opacity(0.6),
                                Color.green.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Obsidian")
                        .font(.title2.bold())
                        .foregroundColor(.obsidianText)
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.obsidianSecondary)
                }
            }
            
            Spacer()
            
            // Theme Selector and New Button
            HStack(spacing: 12) {
                ThemeSelectorView(store: store)
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        store.addMemo()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                        Text("New")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
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
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.obsidianLight)
        .overlay(
            Rectangle()
                .fill(Color.obsidianBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var searchBarView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(.obsidianSecondary)
                
                TextField("Search memos...", text: $searchText)
                    .font(.body)
                    .foregroundColor(.obsidianText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.obsidianDark)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.obsidianBorder, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.obsidianLight)
        .overlay(
            Rectangle()
                .fill(Color.obsidianBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var welcomeView: some View {
        VStack(spacing: 24) {
            // Large Crystal Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.obsidianLight,
                                Color.obsidianDark
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .opacity(0.3)
                
                Path { path in
                    path.move(to: CGPoint(x: 60, y: 20))
                    path.addLine(to: CGPoint(x: 85, y: 45))
                    path.addLine(to: CGPoint(x: 75, y: 70))
                    path.addLine(to: CGPoint(x: 60, y: 100))
                    path.addLine(to: CGPoint(x: 45, y: 70))
                    path.addLine(to: CGPoint(x: 35, y: 45))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            store.currentTheme.accentColor.opacity(0.8),
                            store.currentTheme.accentColor.opacity(0.4),
                            Color.green.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .opacity(0.6)
            }
            
            VStack(spacing: 8) {
                Text("Ready to capture your thoughts")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.obsidianText)
                
                HStack(spacing: 4) {
                    Text("Welcome to")
                        .foregroundColor(.obsidianSecondary)
                    Text("Obsidian Notes")
                        .foregroundColor(store.currentTheme.accentColor)
                        .fontWeight(.semibold)
                }
                .font(.body)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.obsidianDark)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
