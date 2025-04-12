//
//  ImagePicker.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-11.
//

import SwiftUI
import PhotosUI

/// 只選「單張」圖片的 ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    /// 選完後，回傳「單張 UIImage?」的 completion
    var completion: (UIImage?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        // 設置 PHPickerConfiguration
        var config = PHPickerConfiguration()
        config.filter = .images     // 只要圖片
        config.selectionLimit = 1   // 限制「只能選1張」
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // 不需要更新
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // 關掉選圖視窗
            picker.dismiss(animated: true)
            
            // 如果沒有選任何圖片
            guard let firstResult = results.first else {
                parent.completion(nil)
                return
            }
            
            let itemProvider = firstResult.itemProvider
            // 確保可以載入 UIImage
            guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
                parent.completion(nil)
                return
            }
            
            itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                // 在背景 thread
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        // 回傳圖片給外界
                        self.parent.completion(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.parent.completion(nil)
                    }
                }
            }
        }
    }
}
