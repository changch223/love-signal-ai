//
//  myakuariApp.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-11.
//

import SwiftUI
import SwiftData

@main
struct myakuariApp: App {
    init() {
            // 檢查 Keychain 中是否已存在 API_KEY，如無則儲存它
            if KeychainHelper.shared.read(key: "API_KEY") == nil {
                // 請將下方的 "YOUR_GOOGLE_API_KEY" 替換成您實際的金鑰
                KeychainHelper.shared.save(value: "YOUR_GOOGLE_API_KEY", for: "API_KEY")
            }
        }
        
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
