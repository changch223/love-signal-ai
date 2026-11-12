import SwiftUI

struct ContentView: View {
    @AppStorage("remainingFreeChances") private var remainingFreeChances = 1
    @AppStorage("extraChances")         private var extraChances         = 0
    @Environment(\.scenePhase) private var scenePhase

    // 今できることを最初に伝える（無料か、残り何回か、広告が要るか）
    private var chipText: String {
        if remainingFreeChances > 0 {
            return localized("home_chip_free", remainingFreeChances)
        } else if extraChances > 0 {
            return localized("home_chip_extra", extraChances)
        }
        return localized("home_chip_ad")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 0) {
                    Spacer(minLength: 24)

                    VStack(spacing: 16) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 104, height: 104)

                        PulseView(beats: 1)
                            .frame(height: 40)
                            .padding(.horizontal, 48)

                        Text("title_text")
                            .font(Theme.rounded(32, .heavy))
                            .foregroundColor(Theme.ink)
                            .multilineTextAlignment(.center)

                        Text("home_subtitle")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.sub)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 24)

                    VStack(spacing: 12) {
                        ChipView(text: chipText)

                        NavigationLink(destination: AnalysisView()) {
                            PrimaryButtonLabel(
                                title: localized(remainingFreeChances > 0 ? "home_cta_free" : "home_cta")
                            )
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            ButtonSoundPlayer.playSound()
                        })

                        PrivacyLine(key: "privacy_short")
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                    AdBanner()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(Theme.pink)
        .onAppear { Chances.resetDailyIfNeeded() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Chances.resetDailyIfNeeded() }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
