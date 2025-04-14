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
    @Environment(\.scenePhase) private var scenePhase // ⭐️ 這行加上去
    
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
            ContentView()
                .onAppear {
                    // App 啟動的時候，載一次廣告
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        AppOpenAdManager.shared.loadAd()
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        // App 從背景回到前景時，再預先載一支新的廣告
                        AppOpenAdManager.shared.loadAd()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
