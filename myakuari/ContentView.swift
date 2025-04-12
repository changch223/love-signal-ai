import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // 背景：溫柔粉橘到奶油白的漸層
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.85, blue: 0.85), // 淡粉橘
                    Color(red: 1.0, green: 0.95, blue: 0.9)   // 奶油白
                ]),
                startPoint: .top,
                endPoint: .bottom)
                .ignoresSafeArea()

                Color.white.opacity(0.2)
                    .ignoresSafeArea()
                    .blur(radius: 30)

                VStack(spacing: 50) {
                    VStack(spacing: 16) {
                        // 大標題
                        Text("脈ありAIジャッジ！")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.3)) // 柔和的棕色
                            .multilineTextAlignment(.center)
                            .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 1)

                        // 小標語
                        Text("AIがあなたの恋のチャンスを瞬間判定！")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.4).opacity(0.8))
                            .multilineTextAlignment(.center)
                            .shadow(radius: 1)
                    }

                    // 按鈕
                    NavigationLink(destination: AnalysisView()) {
                        Text("さっそくジャッジを開始")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 36)
                            .background(
                                Color(red: 1.0, green: 0.6, blue: 0.7) // 淡粉色糖果色
                                    .cornerRadius(24)
                                    .shadow(radius: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            )
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
