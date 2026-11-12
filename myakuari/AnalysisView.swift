import SwiftUI

// Gemini 回傳的分析結果
struct AnalysisResult: Codable {
    let couple_possibility: Int
    let judgment_reason: String
    let improvement_suggestion: String
    let encouragement_message: String
}

struct AnalysisView: View {
    // 免費與額外分析次數
    @AppStorage("remainingFreeChances") private var remainingFreeChances = 1
    @AppStorage("extraChances")         private var extraChances         = 0
    // 初回のみ、AIへの送信について同意を取る
    @AppStorage("aiConsentGiven")       private var aiConsentGiven       = false
    @AppStorage("hasCompletedAnalysis") private var hasCompletedAnalysis = false

    @ObservedObject private var adManager = RewardedAdManager.shared

    // 文字（對話或輔助說明）
    @State private var conversationText: String
    // 最多可上傳 3 張圖
    @State private var selectedImages: [UIImage]
    @State private var showImagePicker = false
    @State private var showConsent = false

    // 分析結果
    @State private var analysisResult: AnalysisResult?
    @State private var navigateToResult = false
    @State private var isLoading: Bool
    @State private var loadingStep: Int
    @State private var errorMessage: String?

    @FocusState private var noteFocused: Bool

    private let maxImages = 3

    init(images: [UIImage] = [], note: String = "", loading: Bool = false) {
        _selectedImages = State(initialValue: images)
        _conversationText = State(initialValue: note)
        _isLoading = State(initialValue: loading)
        _loadingStep = State(initialValue: loading ? 1 : 0)
    }

    // MARK: - 判定ボタンの状態

    private enum CTAState {
        case free       // 無料回数あり
        case extra      // 追加回数あり
        case watchAd    // 回数なし・広告あり
        case adLoading  // 回数なし・広告を読み込み中
        case adFailed   // 回数なし・広告を読み込めなかった（タップで再読み込み）
        case noAd       // 回数なし・広告の在庫なし
    }

    private var ctaState: CTAState {
        if remainingFreeChances > 0 { return .free }
        if extraChances > 0 { return .extra }
        switch adManager.status {
        case .ready:   return .watchAd
        case .noFill:  return .noAd
        case .loading: return .adLoading
        case .failed:  return .adFailed
        }
    }

    private var ctaTitle: String {
        switch ctaState {
        case .free:      return localized("cta_free")
        case .extra:     return localized("cta_extra")
        case .watchAd:   return localized("cta_ad")
        case .adLoading: return localized("cta_ad_loading")
        case .adFailed:  return localized("cta_ad_failed")
        case .noAd:      return localized("cta_no_ad")
        }
    }

    private var ctaSubtitle: String? {
        switch ctaState {
        case .free:      return localized("cta_free_sub", remainingFreeChances)
        case .extra:     return localized("cta_extra_sub", extraChances)
        case .watchAd:   return localized("cta_ad_sub")
        case .adLoading: return localized("cta_ad_loading_sub")
        case .adFailed:  return localized("cta_ad_failed_sub")
        case .noAd:      return nil
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 6) {
                        Text("input_title")
                            .font(Theme.rounded(24, .heavy))
                            .foregroundColor(Theme.ink)
                        Text("input_sub")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.sub)
                    }
                    .multilineTextAlignment(.center)

                    VStack(spacing: 8) {
                        photoSlots
                        PrivacyLine(key: "input_privacy")
                    }

                    noteField

                    if let errorMessage {
                        errorCard(errorMessage)
                    }

                    Text("disclaimer_text")
                        .font(.footnote)
                        .foregroundColor(Theme.sub.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)

            if isLoading {
                loadingOverlay
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isLoading {
                bottomBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isLoading)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(LocalizedStringKey("keyboard_done")) { noteFocused = false }
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let result = analysisResult {
                ResultView(result: result)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { uiImage in
                guard let uiImage, selectedImages.count < maxImages else { return }
                if let finalImage = UIImage(data: compressImage(uiImage)) {
                    selectedImages.append(finalImage)
                    errorMessage = nil
                }
            }
        }
        .alert(LocalizedStringKey("consent_title"), isPresented: $showConsent) {
            Button(LocalizedStringKey("consent_agree")) {
                aiConsentGiven = true
                // アラートが閉じてから広告表示・分析に進む
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    startAnalysisFlow()
                }
            }
            Button(LocalizedStringKey("consent_cancel"), role: .cancel) {}
        } message: {
            Text("consent_message")
        }
        .onChange(of: adManager.status) { _, status in
            // 広告が用意できたら、広告のエラー表示は消す
            if status == .ready, errorMessage == localized("error_ad_unavailable") {
                errorMessage = nil
            }
        }
        .onAppear {
            Chances.resetDailyIfNeeded()
            adManager.loadRewardedAd()
        }
    }

    // MARK: - 写真の選択枠（枠そのものがタップ領域）

    private var photoSlots: some View {
        HStack(spacing: 10) {
            ForEach(0..<maxImages, id: \.self) { index in
                if index < selectedImages.count {
                    filledSlot(index)
                } else {
                    emptySlot
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 20).fill(Theme.pinkSoft.opacity(0.55)))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Theme.pink.opacity(0.7), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
        )
    }

    private func filledSlot(_ index: Int) -> some View {
        Color.clear
            .aspectRatio(3.0 / 4.0, contentMode: .fit)
            .overlay(
                Image(uiImage: selectedImages[index])
                    .resizable()
                    .scaledToFill()
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .topTrailing) {
                Button {
                    if index < selectedImages.count { selectedImages.remove(at: index) }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.black.opacity(0.55))
                }
                .padding(4)
                .accessibilityLabel(Text("photo_remove"))
            }
    }

    private var emptySlot: some View {
        Button {
            noteFocused = false
            showImagePicker = true
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
                .overlay(
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundColor(Theme.pink)
                )
        }
        .accessibilityLabel(Text("select_photo_button"))
    }

    // MARK: - 補足

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("input_note_label")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Theme.ink)
            TextField(
                "",
                text: $conversationText,
                prompt: Text("input_note_placeholder").foregroundColor(Theme.sub.opacity(0.7)),
                axis: .vertical
            )
            .lineLimit(3...5)
            .focused($noteFocused)
            .font(.system(size: 15))
            .foregroundColor(Theme.ink)
            .onChange(of: conversationText) { _, newValue in
                if newValue.count > 300 {
                    conversationText = String(newValue.prefix(300))
                }
            }
        }
        .card()
    }

    // MARK: - エラー（何が起きたか・回数がどうなったか）

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(LocalizedStringKey("error_title"), systemImage: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .bold))
            Text(message)
                .font(.system(size: 14))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundColor(Theme.warnInk)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.warnBg))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.warnLine, lineWidth: 1))
    }

    // MARK: - 下部バー（回数 → 判定ボタン）

    private var bottomBar: some View {
        VStack(spacing: 10) {
            ChipView(text: localized("chip_counts", remainingFreeChances, extraChances))

            Button {
                ButtonSoundPlayer.playSound()
                handleAnalysisTap()
            } label: {
                PrimaryButtonLabel(title: ctaTitle, subtitle: ctaSubtitle, enabled: ctaState != .adLoading)
            }
            .disabled(ctaState == .adLoading)

            // 回数が残っているときだけ、追加で広告を見られる
            if adManager.status == .ready, ctaState == .free || ctaState == .extra, !AdGate.isScreenshot {
                Button(LocalizedStringKey("watch_ad_reward_button")) {
                    watchAdForExtraChance()
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.pink)
            }

            AdBanner()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Theme.bgBottom.opacity(0.96).ignoresSafeArea(edges: .bottom))
    }

    // MARK: - 判定中

    private var loadingOverlay: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 20) {
                PulseView(beats: 3, animated: true)
                    .frame(height: 56)
                    .padding(.horizontal, 32)

                Text("loading_title")
                    .font(Theme.rounded(24, .heavy))
                    .foregroundColor(Theme.ink)

                VStack(alignment: .leading, spacing: 12) {
                    loadingRow("loading_step1", index: 0)
                    loadingRow("loading_step2", index: 1)
                    loadingRow("loading_step3", index: 2)
                }
                .card()

                Text("loading_eta")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.sub)
            }
            .padding(.horizontal, 28)
        }
    }

    private func loadingRow(_ key: LocalizedStringKey, index: Int) -> some View {
        HStack(spacing: 10) {
            Circle()
                .strokeBorder(Theme.pink, lineWidth: 2)
                .background(Circle().fill(index <= loadingStep ? Theme.pink : Color.clear))
                .frame(width: 12, height: 12)
            Text(key)
                .font(.system(size: 15, weight: index <= loadingStep ? .semibold : .regular))
                .foregroundColor(index <= loadingStep ? Theme.ink : Theme.sub)
        }
    }

    // MARK: - タップ処理

    private func handleAnalysisTap() {
        noteFocused = false

        // ⓪ 入力チェックは回数消費・広告表示より先に行う
        if conversationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImages.isEmpty {
            errorMessage = localized("error_no_input")
            return
        }

        // ① 初回は、写真がAIへ送信されることに同意してもらう
        if !aiConsentGiven {
            showConsent = true
            return
        }

        startAnalysisFlow()
    }

    private func startAnalysisFlow() {
        switch ctaState {
        case .free, .extra:
            // 回数は分析が成功した時点で消費する（失敗時は減らさない）
            runAnalysis()

        case .watchAd:
            guard let rootVC = UIApplication.rootViewController else {
                errorMessage = localized("error_ad_unavailable")
                return
            }
            adManager.showAd(
                from: rootVC,
                onReward: {
                    // 報酬は必ず回数として付与する。分析が失敗しても回数が残り、広告なしで再試行できる
                    extraChances += 1
                },
                onDismiss: { earned in
                    // 広告が閉じてから分析を実行
                    if earned { runAnalysis() }
                },
                onFailure: {
                    errorMessage = localized("error_ad_unavailable")
                }
            )

        case .noAd:
            // 表示できる広告がないときは、広告なしで分析
            runAnalysis(consumesChance: false)

        case .adFailed:
            // 広告を読み込めなかったときは、タップで読み込み直す
            adManager.retryLoad()

        case .adLoading:
            break
        }
    }

    private func watchAdForExtraChance() {
        guard let rootVC = UIApplication.rootViewController else { return }
        adManager.showAd(from: rootVC, onReward: {
            extraChances += 1
        }, onFailure: {
            errorMessage = localized("error_ad_unavailable")
        })
    }

    // 成功時に回数を1つ消費（無料分 → 追加分の順）
    private func consumeChance() {
        if remainingFreeChances > 0 {
            remainingFreeChances -= 1
        } else if extraChances > 0 {
            extraChances -= 1
        }
    }

    // MARK: - 圖片壓縮 (直到 < 1MB)
    private func compressImage(_ image: UIImage) -> Data {
        var compressionQuality: CGFloat = 0.9
        let resized = resizeImage(image: image, targetSize: CGSize(width: 1280, height: 1280))
        var imageData = resized.jpegData(compressionQuality: compressionQuality)

        while let data = imageData,
              data.count > 1_000_000,
              compressionQuality > 0.1 {
            compressionQuality -= 0.1
            imageData = resized.jpegData(compressionQuality: compressionQuality)
        }

        return imageData ?? Data()
    }

    // MARK: - 長辺を targetSize に収める（拡大はしない）
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        let scale = min(widthRatio, heightRatio, 1.0)

        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }

    // MARK: - 分析執行

    private func finishAnalysis(errorKey: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = localized(errorKey)
        }
    }

    func runAnalysis(consumesChance: Bool = true) {
        guard !isLoading else { return }
        errorMessage = nil
        isLoading = true
        loadingStep = 0
        // 進行表示（実際の処理段階ではなく、待ち時間の目安）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { if isLoading { loadingStep = 1 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { if isLoading { loadingStep = 2 } }

        let systemInstructionObject: [String: Any] = [
            "parts": [
                ["text": NSLocalizedString("gemini_system_prompt", comment: "")]
            ]
        ]

        // 補充內容：使用 localized 補充前置字串
        let conversationTextCombined = NSLocalizedString("supplementary_prefix", comment: "") + conversationText
        var contents: [[String: Any]] = [[
            "role": "user",
            "parts": [
                ["text": conversationTextCombined]
            ]
        ]]

        for img in selectedImages {
            // 選択時に圧縮済みなので、ここでは再圧縮しない
            let base64String = (img.jpegData(compressionQuality: 0.85) ?? Data()).base64EncodedString()
            contents.append([
                "role": "user",
                "parts": [
                    [
                        "inline_data": [
                            "mime_type": "image/jpeg",
                            "data": base64String
                        ]
                    ]
                ]
            ])
        }

        // モデルはプロキシ側で決める（アプリに固定すると提供終了時に全ユーザーが失敗する）
        let payload: [String: Any] = [
            "system_instruction": systemInstructionObject,
            "contents": contents,
            "generationConfig": [
                "temperature": 0.3,
                "topP": 0.95,
                "topK": 10,
                "maxOutputTokens": 1024,
            ]
        ]

        guard let url = URL(string: "https://gemini-api-key-proxy-731897587704.us-central1.run.app"),
              let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            finishAnalysis(errorKey: "error_service_unavailable")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Secrets.apiAuthorizationKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                finishAnalysis(errorKey: "error_network")
                return
            }

            // HTTP エラー（プロキシ／Gemini 側の障害）は内部エラー文言を出さず、再試行を案内する
            // 429 = プロキシの回数制限。時間をおいての再試行を案内する
            if let http = response as? HTTPURLResponse, http.statusCode == 429 {
                finishAnalysis(errorKey: "error_rate_limited")
                return
            }

            guard let data = data,
                  let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                print("❌ API status \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                finishAnalysis(errorKey: "error_service_unavailable")
                return
            }

            guard let rawJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                finishAnalysis(errorKey: "error_service_unavailable")
                return
            }

            // 200 だが候補なし = 安全フィルタ等で回答が生成されなかった
            guard let candidates = rawJson["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String else {
                finishAnalysis(errorKey: "error_cannot_judge")
                return
            }

            guard let decodedResult = try? JSONDecoder().decode(AnalysisResult.self, from: Data(text.utf8)) else {
                print("❌ Decode error")
                finishAnalysis(errorKey: "error_service_unavailable")
                return
            }

            DispatchQueue.main.async {
                if consumesChance { self.consumeChance() }
                self.hasCompletedAnalysis = true
                self.analysisResult = decodedResult
                self.isLoading = false
                self.navigateToResult = true
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
