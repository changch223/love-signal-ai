//
//  ResultView.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-13.
//

import SwiftUI

struct ResultView: View {
    let result: AnalysisResult
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // 背景漸層
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.9, green: 0.95, blue: 1.0), // 淡藍色
                    Color.white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    // 上方標題
                    VStack(spacing: 10) {
                        Text("AI恋愛分析結果")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.6))
                        
                        Text("二人の未来を一緒に見てみよう")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.7))
                    }
                    .padding(.top, 20)
                    
                    // 結果顯示區塊
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // 成為情侶的可能性
                        VStack(alignment: .leading, spacing: 8) {
                            Text("カップルになる可能性")
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
                            Text("判定理由")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(result.judgment_reason)
                                .font(.body)
                                .foregroundColor(.black)
                        }
                        
                        // 改善建議
                        VStack(alignment: .leading, spacing: 8) {
                            Text("より仲良くなるためのアドバイス")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(result.improvement_suggestion)
                                .font(.body)
                                .foregroundColor(.black)
                        }
                        
                        // 応援メッセージ
                        VStack(alignment: .leading, spacing: 8) {
                            Text("応援メッセージ")
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
                    
                    // 返回按鈕
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("戻る")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 1.0, green: 0.6, blue: 0.7))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
    }
}
