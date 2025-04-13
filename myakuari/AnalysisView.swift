import SwiftUI
import GoogleGenerativeAI

// Gemini 回傳的分析結果
struct AnalysisResult: Codable {
    let couple_possibility: Int
    let judgment_reason: String
    let improvement_suggestion: String
    let encouragement_message: String
}

// API 錯誤回傳結構
struct APIErrorResponse: Codable {
    struct ErrorDetail: Codable {
        let code: Int?
        let message: String?
        let status: String?
    }
    let error: ErrorDetail?
}

struct AnalysisView: View {
    @State private var navigateToResult = false
    @State private var showSuccessAnimation = false

    
    // 文字（對話或輔助說明）
    @State private var conversationText = ""
    // 最多可上傳 3 張圖
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    
    // 分析結果
    @State private var analysisResult: AnalysisResult?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // 讓使用者選圖時，控制「要加到第幾張」的索引
    @State private var imageIndexToAdd: Int?
    
    // 參考：用於 JSON Schema（你原本的程式就有定義，可留著/也可不留）
    private var analysisResultSchema: Schema {
        Schema(
            type: .object,
            properties: [
                "couple_possibility": Schema(type: .integer),
                "judgment_reason": Schema(type: .string),
                "improvement_suggestion": Schema(type: .string),
                "encouragement_message": Schema(type: .string)
            ]
        )
    }
    
    // MARK: - Body
    var body: some View {
        // 讓背景也有「戀愛小清新」的漸層
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.85, blue: 0.85),  // 淡粉橘
                    Color(red: 1.0, green: 0.95, blue: 0.9)    // 奶油白
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 淡淡白霧
            Color.white.opacity(0.2)
                .ignoresSafeArea()
                .blur(radius: 30)
            
            NavigationView {
                ScrollView {
                    VStack(spacing: 30) {
                        // 說明文字
                        VStack(spacing: 8) {
                            Text("1〜3枚の写真をアップロードしてね")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.3))
                            Text("二人の関係をいちばんよく表す写真や\n会話スクショを選んでください")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.3).opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        // 圖片區：最多 3 張
                        imageSelectorSection
                        
                        // 輸入區
                        VStack(alignment: .leading, spacing: 8) {
                            Text("補足あれば何でも入れてね (オプション)")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.3))
                            
                            TextEditor(text: $conversationText)
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )
                                // 監控字數，限制 300 字
                                .onChange(of: conversationText) { newValue in
                                    if newValue.count > 300 {
                                        conversationText = String(newValue.prefix(300))
                                    }
                                }
                        }
                        
                        // 分析按鈕 & 進度
                        if isLoading {
                            ProgressView("分析中…")
                                .padding()
                        } else {
                            Button {
                                runAnalysis()
                            } label: {
                                Text("分析開始")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 1.0, green: 0.6, blue: 0.7))
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                            }
                        }
                        
                        // 分析結果
                        if let result = analysisResult {
                            NavigationLink(
                                destination: ResultView(result: result),
                                isActive: $navigateToResult,
                                label: {
                                    EmptyView()
                                }
                            )
                            .hidden()
                        }
                        
                        // 錯誤訊息
                        if let errorMessage = errorMessage {
                            Text("エラー: \(errorMessage)")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding()
                    .navigationTitle("恋のAI分析")
                }
                .sheet(isPresented: $showImagePicker) {
                    // ImagePicker (單張選擇)
                    ImagePicker { uiImage in
                        if let uiImage = uiImage,
                           let index = imageIndexToAdd {
                            // 壓縮後存
                            let compressed = compressImage(uiImage)
                            if let finalImage = UIImage(data: compressed) {
                                // 放到對應的 index
                                if index < selectedImages.count {
                                    selectedImages[index] = finalImage
                                } else {
                                    selectedImages.append(finalImage)
                                }
                            }
                        }
                    }
                }
            }
        }.overlay(
            Group {
                if showSuccessAnimation {
                    VStack {
                        Text("🎉")
                            .font(.system(size: 80))
                            .scaleEffect(showSuccessAnimation ? 1.2 : 0.8)
                            .animation(.easeInOut(duration: 0.3).repeatCount(2, autoreverses: true), value: showSuccessAnimation)

                        Text("分析完成！")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                            .padding(.top, 10)
                            .opacity(showSuccessAnimation ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5), value: showSuccessAnimation)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.7))
                    .transition(.opacity)
                }
            }
        )
    }
    
    // MARK: - 圖片顯示區
    private var imageSelectorSection: some View {
        VStack(spacing: 10) {
            // 如果還沒有圖片
            if selectedImages.isEmpty {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 150)
                    .overlay(Text("画像未選択").foregroundColor(.gray))
                    .cornerRadius(8)
            } else {
                // 有選到圖片後，在一行中等比顯示
                GeometryReader { geometry in
                    // 可用寬度（扣掉一些內邊距，以免黏邊）
                    let totalWidth = geometry.size.width - 16  // 你也可以多留一點邊距
                    let spacing: CGFloat = 8
                    // 總共有 (selectedImages.count - 1) 處要用 spacing 分隔
                    let totalSpacing = spacing * CGFloat(selectedImages.count - 1)
                    // 每張圖片可分到的寬度
                    let widthPerImage = (totalWidth - totalSpacing) / CGFloat(selectedImages.count)
                    
                    // 讓高度至少能裝得下等比縮放後的圖片
                    HStack(alignment: .top, spacing: spacing) {
                        ForEach(0..<selectedImages.count, id: \.self) { index in
                            let img = selectedImages[index]
                            
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: widthPerImage)
                                    .cornerRadius(8)
                                
                                // 刪除按鈕
                                Button {
                                    selectedImages.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .shadow(radius: 1)
                                }
                                // 讓按鈕浮在右上角
                                .offset(x: 6, y: -6)
                            }
                        }
                    }
                    .frame(width: totalWidth) // 設定 HStack 寬度
                }
                // 給個固定高度，讓 GeometryReader 有空間排版
                // 如果你想要更彈性，就改成 .frame(minHeight: 150, maxHeight: 300)
                .frame(height: 150)
            }
            
            // 如果照片少於3張，就顯示「追加照片」按鈕
            if selectedImages.count < 3 {
                Button {
                    imageIndexToAdd = selectedImages.count
                    showImagePicker = true
                } label: {
                    Text(selectedImages.isEmpty ? "画像を選択" : "追加で画像を選択")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 1.0, green: 0.6, blue: 0.7))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                }
            }
        }
    }

           
    
    // MARK: - 分析結果區塊
    private func resultSection(_ result: AnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("カップルになる可能性: \(result.couple_possibility)")
            Text("判定理由: \(result.judgment_reason)")
            Text("改善できるポイント: \(result.improvement_suggestion)")
            Text("応援メッセージ: \(result.encouragement_message)")
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - 圖片壓縮 (直到 < 1MB)
    private func compressImage(_ image: UIImage) -> Data {
        var compressionQuality: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compressionQuality)
        
        // 先強制縮放成 1280x720 (維持比例)
        let targetSize = CGSize(width: 1280, height: 720)
        let resized = resizeImage(image: image, targetSize: targetSize)
        imageData = resized.jpegData(compressionQuality: compressionQuality)
        
        // 再依序降低壓縮率，直到 < 1MB
        while let data = imageData,
              data.count > 1_000_000,
              compressionQuality > 0 {
            compressionQuality -= 0.1
            imageData = resized.jpegData(compressionQuality: compressionQuality)
        }
        
        // 如果最終還是nil，就給一個最小品質
        return imageData ?? Data()
    }
    
    // MARK: - 圖片縮放到 1280x720 的比例
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        let scale = min(widthRatio, heightRatio)
        
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    // MARK: - 分析執行
    func runAnalysis() {
        // 對話內容或圖片必須至少有一項
        guard !conversationText.isEmpty || !selectedImages.isEmpty else {
            errorMessage = "画像または補足内容を入力してください。"
            return
        }
        errorMessage = nil
        isLoading = true
        
        // STEP 1: 準備 system_instruction 與 conversation content 部分
        
        // 定義 system_instruction 文字內容（與你提供的一致）
        let systemInstructionText = """
        あなたは恋愛の専門家です。提供されたすべての写真と補足内容を総合的に分析し、二つの対象が「カップル」になれる可能性を判断し、次の4つの項目を日本語で回答してください。
        対象は人間同士に限らず、人間と動物、人間と物、物同士など、どのような組み合わせでもかまいません。
        
        - カップルになる可能性（1〜100の数字）
        - すべての写真と補足内容を簡単にまとめた判定理由（3文）
        - より仲良くなるためのアドバイス（3文）
        - 応援メッセージ（3文）
        
        親しみやすく、優しい口調で回答してください。
        """
        
        // 組成 system_instruction 的 JSON 結構
        let systemInstructionObject: [String: Any] = [
            "parts": [
                ["text": systemInstructionText]
            ]
        ]
        
        // 組成 conversation content 的部分（只包含使用者對話內容）
        let conversationPart: [String: Any] = [
            "role": "user",
            "parts": [
                ["text": "補足内容:\n\(conversationText)"]
            ]
        ]
        // 先將 conversationPart 放入 contents 陣列內
        var contents: [[String: Any]] = [conversationPart]
        
        // 將多張圖片以 inline_data 依序放入 contents 內
        for img in selectedImages {
            let compressedData = compressImage(img)
            let base64String = compressedData.base64EncodedString()
            
            let imagePart: [String: Any] = [
                "role": "user",
                "parts": [
                    [
                        "inline_data": [
                            "mime_type": "image/jpeg",
                            "data": base64String
                        ]
                    ]
                ]
            ]
            contents.append(imagePart)
        }
        
        // STEP 2: 組成完整的 Payload，並更新 generationConfig
        let payload: [String: Any] = [
            "model_name": "gemini-2.0-flash",
            "system_instruction": systemInstructionObject,
            "contents": contents,
            "generationConfig": [
                "temperature": 0.3,
                "topP": 0.95,
                "topK": 10,
                "maxOutputTokens": 512,
                // 其他設定由 proxy 端補上 response_mime_type 與 response_schema
            ]
        ]
        
        // STEP 3: 發送至 Cloud Run Proxy
        guard let url = URL(string: "https://gemini-api-key-proxy-731897587704.us-central1.run.app") else {
            self.errorMessage = "無効なURLです"
            self.isLoading = false
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            self.errorMessage = "リクエスト作成エラー"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 這裡放你自己的 Secret Token
        request.setValue("Bearer vanila20180417", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "APIエラー: \(error.localizedDescription)"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "データなし"
                }
                return
            }
            
            do {
                // 先嘗試把 data 轉成 JSON
                if let rawJson = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    // 先印出整包 JSON
                    print("=== RAW JSON ===\n\(rawJson)\n=========")
                    
                    // 再照原本的流程解析
                    if let candidates = rawJson["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let text = parts.first?["text"] as? String {
                        
                        // text 是 Gemini 回來的 JSON 字串
                        let jsonData = Data(text.utf8)
                        let decodedResult = try JSONDecoder().decode(AnalysisResult.self, from: jsonData)
                        
                        DispatchQueue.main.async {
                            self.analysisResult = decodedResult
                            self.showSuccessAnimation = true   // 🎉 先顯示成功動畫
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // 1秒後跳轉
                                self.showSuccessAnimation = false
                                self.navigateToResult = true
                            }
                        }
                        
                    } else {
                        // 如果不是你想要的格式
                        DispatchQueue.main.async {
                            self.errorMessage = "APIフォーマットエラー"
                        }
                    }
                } else {
                    // 如果連 JSON 都 parse 不起來
                    DispatchQueue.main.async {
                        self.errorMessage = "JSON解析失敗"
                    }
                }
            } catch {
                // 如果 decode AnalysisResult 時出錯
                DispatchQueue.main.async {
                    self.errorMessage = "デコードエラー: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

