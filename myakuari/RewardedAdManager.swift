//
//  RewardedAdManager.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-14.
//

import GoogleMobileAds
import SwiftUI

class RewardedAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    static let shared = RewardedAdManager()

    enum Status {
        case loading   // 読み込み中
        case ready     // 表示できる
        case noFill    // 配信できる広告がない
        case failed    // 読み込みに失敗（通信エラーなど）
    }

    @Published private(set) var status: Status = .loading

    private var rewardedAd: RewardedAd?
    private var loadedAt: Date?
    private var adUnitID = "ca-app-pub-9275380963550837/1338217532"
    private var dismissAction: ((Bool) -> Void)?
    private var failureAction: (() -> Void)?
    private var didEarnReward = false
    private var isLoading = false

    // 自動の再読み込みは回数を限り、同時に1本だけ予約する
    private var retryCount = 0
    private var retryScheduled = false
    private let maxAutoRetries = 3
    // 読み込んだ広告は約1時間で失効する
    private let adLifetime: TimeInterval = 55 * 60

    override private init() {
        super.init()
        loadRewardedAd()
    }

    var isAdReady: Bool {
        return rewardedAd != nil && !isExpired
    }

    private var isExpired: Bool {
        guard let loadedAt else { return false }
        return Date().timeIntervalSince(loadedAt) > adLifetime
    }

    func loadRewardedAd() {
        if rewardedAd != nil, isExpired {
            rewardedAd = nil
            status = .loading
        }
        guard rewardedAd == nil, !isLoading else { return }
        isLoading = true
        if status == .failed { status = .loading }

        RewardedAd.load(with: adUnitID, request: Request()) { ad, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("❌ Reward ad failed to load: \(error.localizedDescription)")
                    // code 1 = 在庫なし（No fill）
                    let nsError = error as NSError
                    let noFill = nsError.code == 1 || nsError.localizedDescription.contains("No ad to show")
                    self.status = noFill ? .noFill : .failed
                    self.scheduleRetry()
                    return
                }
                self.retryCount = 0
                self.rewardedAd = ad
                self.loadedAt = Date()
                self.rewardedAd?.fullScreenContentDelegate = self
                self.status = .ready
                print("✅ Reward ad loaded")
            }
        }
    }

    /// ユーザーの操作による再読み込み。自動再試行の回数をリセットする
    func retryLoad() {
        retryCount = 0
        loadRewardedAd()
    }

    private func scheduleRetry() {
        guard !retryScheduled, retryCount < maxAutoRetries else { return }
        retryScheduled = true
        retryCount += 1
        // 20秒 → 40秒 → 80秒
        let delay = 20.0 * pow(2.0, Double(retryCount - 1))
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.retryScheduled = false
            self.loadRewardedAd()
        }
    }

    /// onReward: 報酬確定の瞬間に呼ばれる（ここで必ず報酬を付与する）
    /// onDismiss: 広告が閉じた後に呼ばれる。earned = 報酬を獲得したか
    /// onFailure: 広告を表示できなかったときに呼ばれる
    func showAd(from root: UIViewController,
                onReward: @escaping () -> Void,
                onDismiss: ((Bool) -> Void)? = nil,
                onFailure: (() -> Void)? = nil) {
        guard let ad = rewardedAd, !isExpired else {
            print("⚠️ Reward ad not ready")
            loadRewardedAd()
            onFailure?()
            return
        }

        // 一度表示した広告は再利用できないので手放す
        rewardedAd = nil
        status = .loading
        didEarnReward = false
        dismissAction = onDismiss
        failureAction = onFailure
        ad.present(from: root) {
            let reward = ad.adReward
            print("🎉 Reward received: \(reward.amount)")
            self.didEarnReward = true
            onReward()
        }
    }

    // Optional: Reload ad after dismissed
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("🔁 Reward ad dismissed")
        let action = dismissAction
        dismissAction = nil
        failureAction = nil
        action?(didEarnReward)
        loadRewardedAd()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Reward ad failed to present: \(error.localizedDescription)")
        let action = failureAction
        dismissAction = nil
        failureAction = nil
        action?()
        loadRewardedAd()
    }

}
