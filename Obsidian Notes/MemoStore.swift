//
//  MemoStore.swift
//  Obsidian Notes
//
//  Created by 岡本秀斗 on 2025/07/29.
//

import Foundation
import SwiftUI

class MemoStore: ObservableObject {
    @Published var memos: [Memo] = []
    @Published var selectedMemo: Memo?
    @Published var currentTheme: ThemeColor = .blue
    
    private let userDefaults = UserDefaults.standard
    private let memosKey = "ObsidianNotes_Memos"
    private let themeKey = "ObsidianNotes_Theme"
    
    init() {
        loadMemos()
        loadTheme()
    }
    
    // MARK: - Memo Operations
    func addMemo() {
        let newMemo = Memo()
        memos.insert(newMemo, at: 0)
        selectedMemo = newMemo
        saveMemos()
    }
    
    func updateMemo(_ memo: Memo) {
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            var updatedMemo = memo
            updatedMemo.updatedAt = Date()
            memos[index] = updatedMemo
            
            if selectedMemo?.id == memo.id {
                selectedMemo = updatedMemo
            }
            
            // Sort by update time
            memos.sort { $0.updatedAt > $1.updatedAt }
            saveMemos()
        }
    }
    
    func deleteMemo(_ memo: Memo) {
        memos.removeAll { $0.id == memo.id }
        if selectedMemo?.id == memo.id {
            selectedMemo = nil
        }
        saveMemos()
    }
    
    func selectMemo(_ memo: Memo) {
        selectedMemo = memo
    }
    
    // MARK: - Search
    func filteredMemos(searchText: String) -> [Memo] {
        if searchText.isEmpty {
            return memos
        }
        return memos.filter { memo in
            memo.title.localizedCaseInsensitiveContains(searchText) ||
            memo.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Theme
    func setTheme(_ theme: ThemeColor) {
        currentTheme = theme
        saveTheme()
    }
    
    // MARK: - Persistence
    private func saveMemos() {
        if let encoded = try? JSONEncoder().encode(memos) {
            userDefaults.set(encoded, forKey: memosKey)
        }
    }
    
    private func loadMemos() {
        if let data = userDefaults.data(forKey: memosKey),
           let decodedMemos = try? JSONDecoder().decode([Memo].self, from: data) {
            memos = decodedMemos
        }
    }
    
    private func saveTheme() {
        userDefaults.set(currentTheme.rawValue, forKey: themeKey)
    }
    
    private func loadTheme() {
        if let themeString = userDefaults.string(forKey: themeKey),
           let theme = ThemeColor(rawValue: themeString) {
            currentTheme = theme
        }
    }
}