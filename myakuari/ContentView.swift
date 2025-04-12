//
//  ContentView.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-11.
//

import SwiftUI
import GoogleGenerativeAI

// 預期 Gemini 模型回傳的分析結果（對應 Python 中 SummaryRating）
struct AnalysisResult: Codable {
    let comprehensive_emotional_index: Int
    let confidence_score: Int
    let rating_reason: String
    let supplement_suggestion: String
}

// API 錯誤回傳的結構（用於除錯）
struct APIErrorResponse: Codable {
    struct ErrorDetail: Codable {
        let code: Int?
        let message: String?
        let status: String?
    }
    let error: ErrorDetail?
}

struct ContentView: View {
    @State private var conversationText = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var analysisResult: AnalysisResult?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // 👇 Schema 定義
    private var analysisResultSchema: Schema {
        Schema(
            type: .object,
            properties: [
                "comprehensive_emotional_index": Schema(type: .integer),
                "confidence_score": Schema(type: .integer),
                "rating_reason": Schema(type: .string),
                "supplement_suggestion": Schema(type: .string)
            ]
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 1. 画像の表示
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(Text("画像未選択").foregroundColor(.gray))
                    }
                    
                    Button("画像を選択") {
                        showImagePicker = true
                    }
                    
                    // 2. 対話内容の入力
                    Text("対話内容を入力:")
                        .font(.headline)
                    TextEditor(text: $conversationText)
                        .frame(height: 150)
                        .border(Color.gray, width: 1)
                    
                    // 3. 分析実行ボタン
                    if isLoading {
                        ProgressView("分析中…")
                    } else {
                        Button("分析開始") {
                            runAnalysis()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    // 4. 分析結果の表示
                    if let result = analysisResult {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("総合感情指数: \(result.comprehensive_emotional_index)")
                            Text("信頼度: \(result.confidence_score)")
                            Text("評価理由: \(result.rating_reason)")
                            Text("補足提案: \(result.supplement_suggestion)")
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // 5. エラー表示
                    if let errorMessage = errorMessage {
                        Text("エラー: \(errorMessage)")
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Gemini 分析")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    func runAnalysis() {
        // 対話内容または画像が必須
        guard !conversationText.isEmpty || selectedImage != nil else {
            errorMessage = "対話内容または画像を入力してください。"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        let imageDescription = selectedImage != nil ? "画像が提供されています。" : "画像データはありません。"
        
        // 1. 組成最終 prompt
        let overallPrompt = """
        以下の説明に基づき、総合感情指数（1〜100）、信頼度（1〜100）、1文の評価理由、および追加入力の提案を提供してください。
        純粋な JSON フォーマットで返してください：
        {
          "comprehensive_emotional_index": number,
          "confidence_score": number,
          "rating_reason": "summary sentence",
          "supplement_suggestion": "additional info suggestion"
        }
        説明：
        画像説明:
        \(imageDescription)
        
        対話内容:
        \(conversationText)
        """

        // 2. Cloud Run Proxy 的 URL
        guard let url = URL(string: "https://gemini-api-key-proxy-731897587704.us-central1.run.app") else {
            errorMessage = "無効なURLです"
            isLoading = false
            return
        }
        
        // 3. 組成 Cloud Run 需要的 payload
        let payload: [String: Any] = [
            "model_name": "gemini-2.0-flash",
            "contents": [
                [
                    "parts": [
                        ["text": overallPrompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.0,
                "topP": 1.0,
                "topK": 1,
                "maxOutputTokens": 512
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            errorMessage = "リクエスト作成エラー"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer vanila20180417", forHTTPHeaderField: "Authorization") // 這裡帶你的 SECRET_TOKEN
        request.httpBody = jsonData

        // 4. 發送 API 請求
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
                // 解析 Cloud Run Proxy 回傳的 response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {

                    // text 是 JSON 字串，要 decode 成 AnalysisResult
                    let jsonData = Data(text.utf8)
                    let decodedResult = try JSONDecoder().decode(AnalysisResult.self, from: jsonData)

                    DispatchQueue.main.async {
                        self.analysisResult = decodedResult
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "APIフォーマットエラー"
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
