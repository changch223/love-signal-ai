//
//  myakuariApp.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-11.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    MobileAds.shared.start(completionHandler: nil)

    return true
  }
}

@main
struct myakuariApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            rootView
                // 配色はライト固定
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }

    @ViewBuilder
    private var rootView: some View {
        #if DEBUG
        if let mode = ScreenshotMode.current {
            ScreenshotHost(mode: mode)
        } else {
            mainView
        }
        #else
        mainView
        #endif
    }

    private var mainView: some View {
        ContentView()
            .onAppear {
                // 起動時広告は、最初の判定が終わったユーザーにだけ出す
                guard AdGate.showsPassiveAds else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    AppOpenAdManager.shared.loadAd()  // 只需要 loadAd
                }
            }
    }
}

#if DEBUG
// MARK: - App Store スクリーンショット撮影用（デバッグビルドのみ）
// 起動引数 `-shot home|input|loading|result` で各画面をサンプルデータ付きで直接表示する。
// 環境変数 SHOT_PHOTO に画像パスを渡すと、入力画面の1枚目に使う。

enum ScreenshotMode: String {
    case home, input, loading, result

    static var current: ScreenshotMode? {
        UserDefaults.standard.string(forKey: "shot").flatMap(ScreenshotMode.init)
    }
}

struct ScreenshotHost: View {
    let mode: ScreenshotMode

    private var language: String {
        let code = Bundle.main.preferredLocalizations.first ?? "en"
        return code
    }

    private var samplePhotos: [UIImage] {
        guard let path = ProcessInfo.processInfo.environment["SHOT_PHOTO"],
              let image = UIImage(contentsOfFile: path) else { return [] }
        return [image]
    }

    private var sampleNote: String {
        switch language {
        case "ja":      return "先週はじめて2人でごはんに行きました。"
        case "zh-Hans": return "上周第一次两个人一起吃饭。"
        case "zh-Hant": return "上週第一次兩個人一起吃飯。"
        default:        return "We had dinner together for the first time last week."
        }
    }

    private var sampleResult: AnalysisResult {
        switch language {
        case "ja":
            return AnalysisResult(
                couple_possibility: 82,
                judgment_reason: "ふたりとも体が相手のほうを向いていて、笑い方がとても自然です。はじめての食事のあともやり取りが続いているのは、お互いに居心地がいい証拠です。",
                improvement_suggestion: "次の予定は、こちらから具体的な日付で誘ってみましょう。相手の好きなお店や話題を覚えておくと、ぐっと距離が縮まります。",
                encouragement_message: "いい流れが来ています。あせらず、あなたらしく一歩ずつ進んでくださいね。応援しています！"
            )
        case "zh-Hans":
            return AnalysisResult(
                couple_possibility: 82,
                judgment_reason: "两个人的身体都朝向对方，笑容非常自然。第一次吃饭之后还一直保持联系，说明彼此相处得很舒服。",
                improvement_suggestion: "下一次约会，试着主动提出一个具体的日期。记住对方喜欢的店和话题，距离会一下子拉近。",
                encouragement_message: "现在的势头很好。不用着急，按照自己的节奏一步一步来。为你加油！"
            )
        case "zh-Hant":
            return AnalysisResult(
                couple_possibility: 82,
                judgment_reason: "兩個人的身體都朝向對方，笑容非常自然。第一次吃飯之後還一直保持聯絡，代表彼此相處得很自在。",
                improvement_suggestion: "下一次約會，試著主動提出一個具體的日期。記住對方喜歡的店和話題，距離會一下子拉近。",
                encouragement_message: "現在的氣氛很好。不用著急，照自己的步調一步一步來。為你加油！"
            )
        default:
            return AnalysisResult(
                couple_possibility: 82,
                judgment_reason: "You are both leaning toward each other and your smiles look natural. Staying in touch after your first dinner shows you feel comfortable together.",
                improvement_suggestion: "Suggest a specific date for your next plan. Remembering their favorite places and topics will bring you closer.",
                encouragement_message: "Things are going well. Take it one step at a time and stay yourself. We're rooting for you!"
            )
        }
    }

    var body: some View {
        switch mode {
        case .home:
            ContentView()
        case .input:
            NavigationStack { AnalysisView(images: samplePhotos, note: sampleNote) }
        case .loading:
            NavigationStack { AnalysisView(images: samplePhotos, note: sampleNote, loading: true) }
        case .result:
            NavigationStack { ResultView(result: sampleResult) }
        }
    }
}
#endif
