import SwiftUI
import AVFoundation

struct ResultView: View {
    let result: AnalysisResult
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var shownScore = 0
    @State private var showPetals = false
    @State private var shareImage: Image?

    // 使用 SoundManager
    @StateObject private var soundManager = SoundManager()

    private var score: Int { min(max(result.couple_possibility, 0), 100) }
    private var isHigh: Bool { score >= 70 }

    private var verdict: String {
        if score >= 70 { return localized("verdict_high") }
        if score >= 40 { return localized("verdict_mid") }
        return localized("verdict_low")
    }

    var body: some View {
        ZStack {
            AppBackground()

            // 祝福は結果を隠さず、背景で降らせるだけ
            if showPetals {
                PetalBackground()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text(verdict)
                            .font(Theme.rounded(17))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 18)
                            .background(Capsule().fill(Theme.pink))

                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(shownScore)")
                                .font(Theme.rounded(84, .heavy))
                                .contentTransition(.numericText(value: Double(shownScore)))
                            Text("%")
                                .font(Theme.rounded(32, .heavy))
                        }
                        .foregroundColor(Theme.pink)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text("\(localized("result_couple_possibility_title")) \(score)%"))

                        Text("result_couple_possibility_title")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.sub)

                        PulseView(beats: 3)
                            .frame(height: 36)
                            .padding(.horizontal, 12)
                    }
                    .padding(.top, 4)

                    section("result_reason", text: result.judgment_reason)
                    section("result_next", text: result.improvement_suggestion)
                    section("result_cheer", text: result.encouragement_message)

                    Text("disclaimer_text")
                        .font(.footnote)
                        .foregroundColor(Theme.sub.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .safeAreaInset(edge: .bottom) { bottomBar }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if reduceMotion {
                shownScore = score
            } else {
                withAnimation(.easeOut(duration: 1.0)) { shownScore = score }
            }
            if shareImage == nil { shareImage = renderShareImage() }

            if isHigh {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    soundManager.playSound()  // 呼叫 SoundManager 播放音效
                    guard !reduceMotion else { return }
                    withAnimation(.easeIn(duration: 0.5)) { showPetals = true }
                }
            }
        }
    }

    private func section(_ title: LocalizedStringKey, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Theme.pink)
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Theme.ink)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .card()
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                if let shareImage {
                    ShareLink(
                        item: shareImage,
                        preview: SharePreview(localized("share_title", score), image: shareImage)
                    ) {
                        SecondaryButtonLabel(title: localized("result_share"), systemImage: "square.and.arrow.up")
                    }
                }

                Button {
                    ButtonSoundPlayer.playSound() // 🔊 播放可愛按鈕音效
                    dismiss()
                } label: {
                    PrimaryButtonLabel(title: localized("result_again"))
                }
            }
            AdBanner()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Theme.bgBottom.opacity(0.96).ignoresSafeArea(edges: .bottom))
    }

    // 共有用の画像（写真は含めず、判定結果だけ）
    @MainActor
    private func renderShareImage() -> Image? {
        let renderer = ImageRenderer(content: ShareCard(score: score, verdict: verdict, reason: result.judgment_reason))
        renderer.scale = 3
        guard let uiImage = renderer.uiImage else { return nil }
        return Image(uiImage: uiImage)
    }
}

// MARK: - 共有カード

private struct ShareCard: View {
    let score: Int
    let verdict: String
    let reason: String

    var body: some View {
        VStack(spacing: 14) {
            Text("title_text")
                .font(Theme.rounded(15))
                .foregroundColor(Theme.sub)

            Text(verdict)
                .font(Theme.rounded(18))
                .foregroundColor(.white)
                .padding(.vertical, 5)
                .padding(.horizontal, 18)
                .background(Capsule().fill(Theme.pink))

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(score)").font(Theme.rounded(96, .heavy))
                Text("%").font(Theme.rounded(36, .heavy))
            }
            .foregroundColor(Theme.pink)

            PulseLine(beats: 3)
                .stroke(Theme.pink, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(height: 36)

            Text(reason)
                .font(.system(size: 14))
                .foregroundColor(Theme.ink)
                .lineSpacing(4)
                .lineLimit(6)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))

            Spacer(minLength: 0)
        }
        .padding(28)
        .frame(width: 360, height: 480)
        .background(LinearGradient(colors: [Theme.bgTop, Theme.bgBottom], startPoint: .top, endPoint: .bottom))
    }
}
