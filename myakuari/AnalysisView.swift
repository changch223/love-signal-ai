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

    // 免費與額外分析次數
    @AppStorage("remainingFreeChances") private var remainingFreeChances = 1
    @AppStorage("extraChances")         private var extraChances         = 0
    
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

    private func handleAdAndRunAnalysis() {
        // ⓪ 入力チェックは回数消費・広告表示より先に行う
        if conversationText.isEmpty && selectedImages.isEmpty {
            errorMessage = NSLocalizedString("error_no_input", comment: "")
            return
        }

        // ① 残り無料 or 追加チャンスがある場合 → そのまま runAnalysis()
        //    回数は分析が成功した時点で消費する（失敗時は減らさない）
        if remainingFreeChances > 0 || extraChances > 0 {
            runAnalysis()
            return
        }

        // ② チャンスがない場合 → リワード広告を表示して runAnalysis()
        if RewardedAdManager.shared.isAdReady,
           let rootVC = UIApplication.rootViewController {
            RewardedAdManager.shared.showAd(
                from: rootVC,
                onReward: {
                    // 報酬は必ず回数として付与する。分析が失敗しても回数が残り、広告なしで再試行できる
                    extraChances += 1
                },
                onDismiss: { earned in
                    // 広告が閉じてから分析を実行
                    if earned { runAnalysis() }
                }
            )
        }
        // ③ 広告ロードはされたが表示できる広告がないときも分析
        else if let lastError = RewardedAdManager.shared.lastAdLoadError,
                lastError.contains("No ad to show") {
            runAnalysis(consumesChance: false)
        }
        // ④ それ以外（広告未ロード／準備中）はアラート表示
        else if let rootVC = UIApplication.rootViewController {
            let alert = UIAlertController(
                title: NSLocalizedString("AdNotReadyTitle", comment: ""),
                message: NSLocalizedString("AdNotReadyMessage", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            rootVC.present(alert, animated: true)
        }
    }


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
                    VStack(spacing: 20) {
                        // 次數顯示與廣告按鈕
                        VStack(spacing: 8) {
                            // “剩餘免費分析次數：%d”
                               Text(String(format: NSLocalizedString("remaining_free_chances", comment: ""),
                                           remainingFreeChances))
                               // “額外分析次數：%d”
                               Text(String(format: NSLocalizedString("extra_chances", comment: ""),
                                           extraChances))
                            Button(LocalizedStringKey("watch_ad_reward_button")) {
                                // ここで直接広告を表示して、完了時に extraChances を +1
                                if RewardedAdManager.shared.isAdReady,
                                   let rootVC = UIApplication.rootViewController {
                                    RewardedAdManager.shared.showAd(from: rootVC, onReward: {
                                        extraChances += 1
                                    })
                                } else if let lastError = RewardedAdManager.shared.lastAdLoadError,
                                          lastError.contains("No ad to show") {
                                    // 広告がない場合でもユーザーへ回数付与したければここで
                                    extraChances += 1
                                } else if let rootVC = UIApplication.rootViewController {
                                    let alert = UIAlertController(
                                        title: NSLocalizedString("AdNotReadyTitle", comment: ""),
                                        message: NSLocalizedString("AdNotReadyMessage", comment: ""),
                                        preferredStyle: .alert
                                    )
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                                    rootVC.present(alert, animated: true)
                                }
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical)
                        
                        // ❤️ 恋のAI分析標題與說明
                        VStack(spacing: 8) {
                            Text("title_ai_analysis")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.3))
                            
                            Label(
                                title: { Text("photo_upload_prompt") },
                                icon: { Image(systemName: "camera") }
                            )
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.3))
                            
                            Text("photo_upload_instruction")
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
                                title: { Text("supplementary_input") },
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
                            ProgressView(LocalizedStringKey("loading_analysis"))
                                .padding()
                        } else {
                            Button {
                                
                                handleAdAndRunAnalysis()
                                
                            } label: {
                                Label(
                                    title: { Text("start_analysis_button") },
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
                            Text("\(NSLocalizedString("error_prefix", comment: "")) \(errorMessage)")
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
                        
                        Spacer()  // <=== 中間空間撐開
                        
                        
                        //免責
                        Text("disclaimer_text")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        
                        // 廣告放底部
                        BannerAdView(adUnitID: "ca-app-pub-9275380963550837/6056788210")
                            .frame(height: 50)
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
                if !RewardedAdManager.shared.isAdReady {
                    RewardedAdManager.shared.loadRewardedAd()
                }
                // 每日重置免費次數
                let today = Calendar.current.startOfDay(for: Date())
                if let last = UserDefaults.standard.object(forKey: "lastFreeResetDate") as? Date {
                    if Calendar.current.compare(today, to: last, toGranularity: .day) == .orderedDescending {
                        remainingFreeChances = 1
                        UserDefaults.standard.set(today, forKey: "lastFreeResetDate")
                    }
                } else {
                    UserDefaults.standard.set(today, forKey: "lastFreeResetDate")
                }
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
                    
                    Text("analysis_complete")
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
                    .overlay(Text("no_image_selected").foregroundColor(.gray))
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
                    Text(selectedImages.isEmpty ? "select_photo_button" : "add_more_photo_button")
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
    // 成功時に回数を1つ消費（無料分 → 追加分の順）
    private func consumeChance() {
        if remainingFreeChances > 0 {
            remainingFreeChances -= 1
        } else if extraChances > 0 {
            extraChances -= 1
        }
    }

    func runAnalysis(consumesChance: Bool = true) {
        // 使用 localized 讀取錯誤文字
        if conversationText.isEmpty && selectedImages.isEmpty {
            errorMessage = NSLocalizedString("error_no_input", comment: "")
            return
        }
        errorMessage = nil
        isLoading = true
        
        let systemInstructionText = NSLocalizedString("gemini_system_prompt", comment: "")
        let systemInstructionObject: [String: Any] = [
            "parts": [
                ["text": systemInstructionText]
            ]
        ]
        
        // 補充內容：使用 localized 補充前置字串
        let conversationTextCombined = NSLocalizedString("supplementary_prefix", comment: "") + conversationText
        let conversationPart: [String: Any] = [
            "role": "user",
            "parts": [
                ["text": conversationTextCombined]
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
        
        // モデルはプロキシ側で決める（アプリに固定すると提供終了時に全ユーザーが失敗する）
        let payload: [String: Any] = [
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
            self.errorMessage = NSLocalizedString("error_invalid_url", comment: "")
            self.isLoading = false
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            self.errorMessage = NSLocalizedString("error_create_request", comment: "")
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authorizationKey = Bundle.main.authorizationKey {
            request.setValue("Bearer \(authorizationKey)", forHTTPHeaderField: "Authorization")
        } else {
            print("⚠️ Error: Authorization key not found in Info.plist")
        }
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    // 使用 sprintf 格式化 localized 錯誤字串
                    self.errorMessage = String(format: NSLocalizedString("error_api", comment: ""), error.localizedDescription)
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = NSLocalizedString("error_no_data", comment: "")
                }
                return
            }
            
            // HTTP エラー（プロキシ／Gemini 側の障害）は内部エラー文言を出さず、再試行を案内する
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                print("❌ API status \(http.statusCode)")
                DispatchQueue.main.async {
                    self.errorMessage = NSLocalizedString("error_service_unavailable", comment: "")
                }
                return
            }

            do {
                if let rawJson = try JSONSerialization.jsonObject(with: data) as? [String: Any] {

                    if let candidates = rawJson["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let text = parts.first?["text"] as? String {
                        
                        let jsonData = Data(text.utf8)
                        let decodedResult = try JSONDecoder().decode(AnalysisResult.self, from: jsonData)
                        
                        DispatchQueue.main.async {
                            if consumesChance { self.consumeChance() }
                            self.analysisResult = decodedResult
                            self.showSuccessAnimation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.showSuccessAnimation = false
                                self.navigateToResult = true
                            }
                        }
                        
                    } else {
                        // 200 だが候補なし = 安全フィルタ等で回答が生成されなかった
                        DispatchQueue.main.async {
                            self.errorMessage = NSLocalizedString("error_cannot_judge", comment: "")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = NSLocalizedString("error_service_unavailable", comment: "")
                    }
                }
            } catch {
                print("❌ Decode error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = NSLocalizedString("error_service_unavailable", comment: "")
                }
            }
        }.resume()
    }
}

import UIKit

extension UIApplication {
    static var rootViewController: UIViewController? {
        return shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    }
}

// 一個小的 helper，從 Info.plist 讀取字串
extension Bundle {
    var authorizationKey: String? {
        return infoDictionary?["API_AUTHORIZATION_KEY"] as? String
    }
}
