//
//  Theme.swift
//  myakuari
//
//  画面共通の色・部品
//

import SwiftUI

enum Theme {
    static let ink      = Color(red: 0.35, green: 0.19, blue: 0.22)
    static let sub      = Color(red: 0.58, green: 0.44, blue: 0.47)
    static let pink     = Color(red: 0.95, green: 0.39, blue: 0.55)
    static let pinkSoft = Color(red: 1.00, green: 0.85, blue: 0.89)
    static let line     = Color(red: 0.95, green: 0.84, blue: 0.86)
    static let bgTop    = Color(red: 1.00, green: 0.89, blue: 0.90)
    static let bgBottom = Color(red: 1.00, green: 0.96, blue: 0.93)
    static let warnBg   = Color(red: 1.00, green: 0.96, blue: 0.90)
    static let warnLine = Color(red: 0.95, green: 0.83, blue: 0.64)
    static let warnInk  = Color(red: 0.42, green: 0.26, blue: 0.00)

    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// 分析回数の共通処理
enum Chances {
    /// 日付が変わっていたら無料回数を1回に戻す
    static func resetDailyIfNeeded() {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        if let last = defaults.object(forKey: "lastFreeResetDate") as? Date {
            if Calendar.current.compare(today, to: last, toGranularity: .day) == .orderedDescending {
                defaults.set(1, forKey: "remainingFreeChances")
                defaults.set(today, forKey: "lastFreeResetDate")
            }
        } else {
            defaults.set(today, forKey: "lastFreeResetDate")
        }
    }
}

enum AdGate {
    /// バナー・起動時広告は、最初の判定が終わるまで出さない
    static var showsPassiveAds: Bool {
        !isScreenshot && UserDefaults.standard.bool(forKey: "hasCompletedAnalysis")
    }

    /// App Store スクリーンショット撮影中か（デバッグビルドのみ true になりうる）
    static var isScreenshot: Bool {
        #if DEBUG
        return ScreenshotMode.current != nil
        #else
        return false
        #endif
    }
}

func localized(_ key: String, _ args: CVarArg...) -> String {
    String(format: NSLocalizedString(key, comment: ""), arguments: args)
}

// MARK: - 背景

struct AppBackground: View {
    var body: some View {
        LinearGradient(colors: [Theme.bgTop, Theme.bgBottom], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

// MARK: - 脈拍ライン

struct PulseLine: Shape {
    var beats: Int = 2

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let seg = rect.width / CGFloat(max(beats, 1))
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        for i in 0..<max(beats, 1) {
            let x0 = rect.minX + seg * CGFloat(i)
            p.addLine(to: CGPoint(x: x0 + seg * 0.36, y: rect.midY))
            p.addLine(to: CGPoint(x: x0 + seg * 0.44, y: rect.minY + rect.height * 0.08))
            p.addLine(to: CGPoint(x: x0 + seg * 0.54, y: rect.maxY - rect.height * 0.04))
            p.addLine(to: CGPoint(x: x0 + seg * 0.62, y: rect.minY + rect.height * 0.30))
            p.addLine(to: CGPoint(x: x0 + seg * 0.68, y: rect.midY))
            p.addLine(to: CGPoint(x: x0 + seg, y: rect.midY))
        }
        return p
    }
}

/// 脈拍ラインの上を走る光。phase は 0 → 1 + length まで動かす
struct PulseSweep: Shape {
    var beats: Int
    var phase: CGFloat
    var length: CGFloat = 0.35

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        PulseLine(beats: beats)
            .path(in: rect)
            .trimmedPath(from: max(0, phase - length), to: min(1, phase))
    }
}

struct PulseView: View {
    var beats = 2
    var animated = false
    var lineWidth: CGFloat = 3

    @State private var phase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var style: StrokeStyle {
        StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
    }

    var body: some View {
        ZStack {
            PulseLine(beats: beats)
                .stroke(Theme.pink.opacity(animated && !reduceMotion ? 0.25 : 1), style: style)
            if animated && !reduceMotion {
                // 撮影時は光の位置を固定する
                PulseSweep(beats: beats, phase: AdGate.isScreenshot ? 0.72 : phase)
                    .stroke(Theme.pink, style: style)
                    .onAppear {
                        guard !AdGate.isScreenshot else { return }
                        withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                            phase = 1.35
                        }
                    }
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - ボタン・チップ・カード

struct PrimaryButtonLabel: View {
    let title: String
    var subtitle: String? = nil
    var enabled = true

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(Theme.rounded(17))
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .opacity(0.92)
            }
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 34)
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(Capsule().fill(enabled ? Theme.pink : Theme.sub.opacity(0.45)))
        .shadow(color: Theme.pink.opacity(enabled ? 0.3 : 0), radius: 8, y: 4)
    }
}

struct SecondaryButtonLabel: View {
    let title: String
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage { Image(systemName: systemImage) }
            Text(title)
        }
        .font(Theme.rounded(16))
        .foregroundColor(Theme.pink)
        .frame(maxWidth: .infinity, minHeight: 34)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Capsule().fill(Color.white))
        .overlay(Capsule().strokeBorder(Theme.pink, lineWidth: 1.5))
    }
}

struct ChipView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(Theme.ink)
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background(Capsule().fill(Color.white))
            .overlay(Capsule().strokeBorder(Theme.line, lineWidth: 1))
    }
}

struct PrivacyLine: View {
    let key: LocalizedStringKey

    var body: some View {
        Label(key, systemImage: "lock.fill")
            .font(.system(size: 12))
            .foregroundColor(Theme.sub)
            .multilineTextAlignment(.center)
    }
}

struct AdBanner: View {
    // 最初の判定が終わった時点で表示に切り替わるよう、値を監視する
    @AppStorage("hasCompletedAnalysis") private var hasCompletedAnalysis = false

    var body: some View {
        if hasCompletedAnalysis && !AdGate.isScreenshot {
            BannerAdView(adUnitID: "ca-app-pub-9275380963550837/6056788210")
                .frame(height: 50)
        }
    }
}

extension View {
    func card() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Theme.line, lineWidth: 1))
    }
}
