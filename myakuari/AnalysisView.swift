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
    @State private var animateIn = false  // 控制整體進場動畫
    @State private var isAnalysisButtonPressed = false // 控制分析開始按鈕點擊動畫

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

    var body: some View {
        ZStack {
            // 背景：粉橘到奶油白漸層，外加輕微模糊
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.85, blue: 0.85),
                    Color(red: 1.0, green: 0.95, blue: 0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Color.white.opacity(0.2)
                .ignoresSafeArea()
                .blur(radius: 30)

            // 使用進場動畫效果包裹 NavigationView 整體內容
            NavigationView {
                ScrollView {
                    VStack(spacing: 30) {
                        // ❤️ 恋のAI分析標題與說明
                        VStack(spacing: 8) {
                            Text("❤️ 恋のAI分析")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.3))
                            
                            Label(
                                title: { Text("1〜3枚の写真をアップロードしてね") },
                                icon: { Image(systemName: "camera") }
                            )
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.3))
                            
                            Text("二人の関係をいちばんよく表す写真や\n会話スクショを選んでください")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.3).opacity(0.6))
                                .multilineTextAlignment(.center)
                                .lineSpacing(5)
                        }
                        
                        // 圖片選擇區
                        imageSelectorSection
                        
                        // ✍️ 補足輸入區
                        VStack(alignment: .leading, spacing: 8) {
                            Label(
                                title: { Text("補足あれば何でも入れてね (オプション)") },
                                icon: { Image(systemName: "pencil.and.outline") }
                            )
                            .font(.headline)
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.3))
                            
                            TextEditor(text: $conversationText)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )
                                .onChange(of: conversationText) { newValue in
                                    if newValue.count > 300 {
                                        conversationText = String(newValue.prefix(300))
                                    }
                                }
                        }
                        
                        // ⚡️ 分析開始按鈕
                        if isLoading {
                            ProgressView("分析中…")
                                .padding()
                        } else {
                            Button {
                                runAnalysis()
                            } label: {
                                Label(
                                    title: { Text("分析開始") },
                                    icon: { Image(systemName: "bolt.fill") }
                                )
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 1.0, green: 0.6, blue: 0.7))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                            }
                            .scaleEffect(isAnalysisButtonPressed ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isAnalysisButtonPressed)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        isAnalysisButtonPressed = true
                                        ButtonSoundPlayer.playSound()
                                    }
                                    .onEnded { _ in
                                        isAnalysisButtonPressed = false
                                    }
                            )
                        }
                        
                        // 錯誤訊息顯示
                        if let errorMessage = errorMessage {
                            Text("エラー: \(errorMessage)")
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        // 分析完成後自動跳轉到 ResultView
                        if let result = analysisResult {
                            NavigationLink(
                                destination: ResultView(result: result),
                                isActive: $navigateToResult,
                                label: { EmptyView() }
                            )
                            .hidden()
                        }
                    }
                    .padding()
                }
                // 進場動畫：從下方移入並由透明漸進
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 50)
                .animation(.easeOut(duration: 1.0), value: animateIn)
                .navigationTitle("")
                .navigationBarHidden(true)
            }
            .onAppear {
                animateIn = true
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { uiImage in
                    if let uiImage = uiImage, let index = imageIndexToAdd {
                        let compressed = compressImage(uiImage)
                        if let finalImage = UIImage(data: compressed) {
                            if index < selectedImages.count {
                                selectedImages[index] = finalImage
                            } else {
                                selectedImages.append(finalImage)
                            }
                        }
                    }
                }
            }
            
            // 🎉 成功動畫（略）
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
    }
    
    // MARK: - 圖片顯示區
    private var imageSelectorSection: some View {
        VStack(spacing: 10) {
            if selectedImages.isEmpty {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 150)
                    .overlay(Text("画像未選択").foregroundColor(.gray))
                    .cornerRadius(8)
            } else {
                GeometryReader { geometry in
                    let totalWidth = geometry.size.width - 16
                    let spacing: CGFloat = 8
                    let totalSpacing = spacing * CGFloat(selectedImages.count - 1)
                    let widthPerImage = (totalWidth - totalSpacing) / CGFloat(selectedImages.count)
                    
                    HStack(alignment: .top, spacing: spacing) {
                        ForEach(0..<selectedImages.count, id: \.self) { index in
                            let img = selectedImages[index]
                            
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: widthPerImage)
                                    .cornerRadius(8)
                                
                                Button {
                                    selectedImages.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .shadow(radius: 1)
                                }
                                .offset(x: 6, y: -6)
                            }
                        }
                    }
                    .frame(width: totalWidth)
                }
                .frame(height: 150)
            }
            
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
    
    // MARK: - 圖片壓縮 (直到 < 1MB)
    private func compressImage(_ image: UIImage) -> Data {
        var compressionQuality: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compressionQuality)
        
        let targetSize = CGSize(width: 1280, height: 720)
        let resized = resizeImage(image: image, targetSize: targetSize)
        imageData = resized.jpegData(compressionQuality: compressionQuality)
        
        while let data = imageData,
              data.count > 1_000_000,
              compressionQuality > 0 {
            compressionQuality -= 0.1
            imageData = resized.jpegData(compressionQuality: compressionQuality)
        }
        
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
        guard !conversationText.isEmpty || !selectedImages.isEmpty else {
            errorMessage = "画像または補足内容を入力してください。"
            return
        }
        errorMessage = nil
        isLoading = true
        
        let systemInstructionText = """
        あなたは恋愛の専門家です。提供されたすべての写真と補足内容を総合的に分析し、二つの対象が「カップル」になれる可能性を判断し、次の4つの項目を日本語で回答してください。
        対象は人間同士に限らず、人間と動物、人間と物、物同士など、どのような組み合わせでもかまいません。
        
        - カップルになる可能性（1〜100の数字）
        - すべての写真と補足内容を簡単にまとめた判定理由（3文）
        - より仲良くなるためのアドバイス（3文）
        - 応援メッセージ（3文）
        
        親しみやすく、優しい口調で回答してください。
        """
        
        let systemInstructionObject: [String: Any] = [
            "parts": [
                ["text": systemInstructionText]
            ]
        ]
        
        let conversationPart: [String: Any] = [
            "role": "user",
            "parts": [
                ["text": "補足内容:\n\(conversationText)"]
            ]
        ]
        var contents: [[String: Any]] = [conversationPart]
        
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
        
        let payload: [String: Any] = [
            "model_name": "gemini-2.0-flash",
            "system_instruction": systemInstructionObject,
            "contents": contents,
            "generationConfig": [
                "temperature": 0.3,
                "topP": 0.95,
                "topK": 10,
                "maxOutputTokens": 512,
            ]
        ]
        
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
                if let rawJson = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("=== RAW JSON ===\n\(rawJson)\n=========")
                    
                    if let candidates = rawJson["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let text = parts.first?["text"] as? String {
                        
                        let jsonData = Data(text.utf8)
                        let decodedResult = try JSONDecoder().decode(AnalysisResult.self, from: jsonData)
                        
                        DispatchQueue.main.async {
                            self.analysisResult = decodedResult
                            self.showSuccessAnimation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.showSuccessAnimation = false
                                self.navigateToResult = true
                            }
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "APIフォーマットエラー"
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "JSON解析失敗"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "デコードエラー: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
