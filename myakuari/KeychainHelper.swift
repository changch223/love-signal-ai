//
//  KeychainHelper.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-11.
//

import Foundation
import Security

class KeychainHelper {
    static let standard = KeychainHelper() // 單例模式

    private init() { }

    /// 儲存文字到 Keychain 中
    func save(_ value: String, forKey key: String) {
        if let data = value.data(using: .utf8) {
            // 建立查詢
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecValueData: data
            ] as CFDictionary
            
            // 若原本有相同 key 的資料，先刪除舊的內容
            SecItemDelete(query)
            let status = SecItemAdd(query, nil)
            if status != errSecSuccess {
                print("儲存失敗，錯誤代碼: \(status)")
            }
        }
    }

    /// 從 Keychain 中讀取指定 key 的文字
    func read(forKey key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
}
