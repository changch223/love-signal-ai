import SwiftUI

struct ContentView: View {
    @State private var isPressed = false

    var body: some View {
        NavigationView {
            ZStack {
                // 背景：漸層
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.85, blue: 0.85),
                    Color(red: 1.0, green: 0.95, blue: 0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom)
                .ignoresSafeArea()

                Color.white.opacity(0.2)
                    .ignoresSafeArea()
                    .blur(radius: 30)

                // 主內容 VStack，包含 logo、標題文字、按鈕等
                VStack(spacing: 50) {
                    
                    // 新增 logo 圖片
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .shadow(radius: 5)
                        .padding(.top, 30)
                    
                    // 標題與副標題區域
                    VStack(spacing: 16) {
                        Text("title_text")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.3))
                            .multilineTextAlignment(.center)
                            .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 1)
                        
                        Text("subtitle_text")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.4).opacity(0.8))
                            .multilineTextAlignment(.center)
                            .shadow(radius: 1)
                    }
                    
                    // 分析開始的按鈕
                    NavigationLink(destination: AnalysisView()) {
                        Text("button_text")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 36)
                            .background(
                                Color(red: 1.0, green: 0.6, blue: 0.7)
                                    .cornerRadius(24)
                                    .shadow(radius: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            )
                            .scaleEffect(isPressed ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isPressed)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                isPressed = true
                                ButtonSoundPlayer.playSound() // 播放點擊音效
                            }
                            .onEnded { _ in
                                isPressed = false
                            }
                    )
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
