//
//  Untitled.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-13.
//

import SwiftUI

struct PetalBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<30, id: \.self) { i in
                Petal()
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: animate ? UIScreen.main.bounds.height + 100 : -100
                    )
                    .animation(
                        Animation.linear(duration: Double.random(in: 8...12))
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...3)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct Petal: View {
    var body: some View {
        Image(systemName: "heart.fill") // 你可以換成自己的花瓣圖
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(Color.pink.opacity(0.6))
            .rotationEffect(.degrees(Double.random(in: 0...360)))
            .scaleEffect(Double.random(in: 0.7...1.3))
            .opacity(0.8)
    }
}
