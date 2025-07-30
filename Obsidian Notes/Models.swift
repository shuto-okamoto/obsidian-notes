//
//  Models.swift
//  Obsidian Notes
//
//  Created by 岡本秀斗 on 2025/07/29.
//

import Foundation
import SwiftUI

// MARK: - Memo Model
struct Memo: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String = "", content: String = "") {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var displayTitle: String {
        return title.isEmpty ? "Untitled" : title
    }
    
    var preview: String {
        let cleanContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanContent.isEmpty {
            return "No content"
        }
        return String(cleanContent.prefix(100))
    }
}

// MARK: - Theme Colors
enum ThemeColor: String, CaseIterable {
    case blue = "blue"
    case purple = "purple" 
    case green = "green"
    case orange = "orange"
    
    var displayName: String {
        switch self {
        case .blue: return "Ocean"
        case .purple: return "Amethyst"
        case .green: return "Forest"
        case .orange: return "Sunset"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .blue: return Color.blue
        case .purple: return Color.purple
        case .green: return Color.green
        case .orange: return Color.orange
        }
    }
    
    var accentColor: Color {
        switch self {
        case .blue: return Color(red: 0.345, green: 0.651, blue: 1.0) // #58a6ff
        case .purple: return Color(red: 0.737, green: 0.549, blue: 1.0) // #bc8cff
        case .green: return Color(red: 0.337, green: 0.827, blue: 0.392) // #56d364
        case .orange: return Color(red: 1.0, green: 0.584, blue: 0.0) // #ff9500
        }
    }
}

// MARK: - Color Extensions
extension Color {
    static let obsidianDark = Color(red: 0.051, green: 0.067, blue: 0.090) // #0d1117
    static let obsidianLight = Color(red: 0.086, green: 0.106, blue: 0.133) // #161b22
    static let obsidianBorder = Color(red: 0.188, green: 0.212, blue: 0.176) // #30363d
    static let obsidianText = Color(red: 0.941, green: 0.964, blue: 0.988) // #f0f6fc
    static let obsidianSecondary = Color(red: 0.690, green: 0.725, blue: 0.765) // #b1bac4
}