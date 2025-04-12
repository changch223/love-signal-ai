//
//  KeychainHelper.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-11.
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper() // 單例模式，方便呼叫

    private init() { }

    // 儲存資料到 Keychain
    func save(value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        // 首先，先移除已存在的項目（防止重複儲存）
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)

        // 建立新的項目
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != errSecSuccess {
            print("儲存 Keychain 資料失敗，錯誤代碼: \(status)")
        }
    }
    
    // 從 Keychain 中讀取資料
    func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
