import SwiftUI
import AVFoundation

struct ResultView: View {
    let result: AnalysisResult
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showDialog = false
    @State private var rotateHeart = false
    @State private var showParticles = false
    @State private var isButtonPressed = false

    
    // 使用 SoundManager
    @StateObject private var soundManager = SoundManager()
    
    var body: some View {
        ZStack {
            // 背景漸層
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.9, green: 0.95, blue: 1.0),
                    Color.white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Text("result_title")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.6))
                        
                        Text("result_subtitle")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.7))
                    }
                    .padding(.top, 20)
                    
                    // 結果顯示區塊
                    VStack(alignment: .leading, spacing: 20) {
                        // 成為情侶的可能性
                        VStack(alignment: .leading, spacing: 8) {
                            Text("result_couple_possibility_title")
                                .font(.headline)
                                .foregroundColor(.pink)
                            ProgressView(value: Float(result.couple_possibility), total: 100)
                                .accentColor(.pink)
                            Text("\(result.couple_possibility)%")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.pink)
                        }
                        
                        Divider()
                        
                        // 判定理由
                        VStack(alignment: .leading, spacing: 8) {
                            Text("result_judgment_reason_title")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(result.judgment_reason)
                                .font(.body)
                                .foregroundColor(.black)
                        }
                        
                        // 改善建議
                        VStack(alignment: .leading, spacing: 8) {
                            Text("result_improvement_title")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(result.improvement_suggestion)
                                .font(.body)
                                .foregroundColor(.black)
                        }
                        
                        // 応援メッセージ
                        VStack(alignment: .leading, spacing: 8) {
                            Text("result_encouragement_title")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(result.encouragement_message)
                                .font(.body)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(radius: 8)
                    .padding()
                    
                    Button(action: {
                        ButtonSoundPlayer.playSound() // 🔊 播放可愛按鈕音效
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("result_back_button")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding()
                    // 廣告放底部
                    BannerAdView(adUnitID: "ca-app-pub-9275380963550837/6056788210")
                        .frame(height: 50)
                }
            }
            
            // 🎉 豪華版 Celebration Dialog（新版）
            if showDialog {
                ZStack {
                    PetalBackground()
                        .opacity(showParticles ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: showParticles)
                    
                    VStack(spacing: 16) {
                        // 脈あり！ 漸層文字
                        Text("celebration_title")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.5, blue: 0.7), Color(red: 1.0, green: 0.6, blue: 0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.pink.opacity(0.3), radius: 3, x: 0, y: 2)
                        
                        // 說明文字
                        Text("celebration_message")
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // 可愛按鈕
                        Button(action: {
                            //ButtonSoundPlayer.playSound() // 🔊 播放可愛按鈕音效
                            isButtonPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isButtonPressed = false
                                showDialog = false // 按一下後稍微延遲，然後關掉Dialog
                            }
                        }) {
                            Text("celebration_button")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color(red: 1.0, green: 0.5, blue: 0.7))
                                )
                        }
                        .padding(.top, 10)
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 24)
                    .background(
                        Color.white
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 30)
                    .transition(.scale)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            if result.couple_possibility >= 70 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showDialog = true
                    rotateHeart = true
                    showParticles = true
                    soundManager.playSound()  // 呼叫 SoundManager 播放音效
                }
            }
        }
    }
}
