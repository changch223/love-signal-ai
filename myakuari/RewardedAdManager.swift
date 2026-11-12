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

    private var rewardedAd: RewardedAd?
    private var adUnitID = "ca-app-pub-9275380963550837/1338217532"
    private var dismissAction: ((Bool) -> Void)?
    private var didEarnReward = false

    // 新增紀錄錯誤訊息的屬性
    var lastAdLoadError: String?

    override private init() {
        super.init()
        loadRewardedAd()
    }

    var isAdReady: Bool {
           return rewardedAd != nil
       }

    func loadRewardedAd() {
        //guard rewardedAd == nil else {
        //    print("⏳ Reward ad 已載入，略過重複加載")
        //    return
        //}

        RewardedAd.load(with: adUnitID, request: Request()) { ad, error in

            if let error = error {
                self.lastAdLoadError = error.localizedDescription
                print("❌ Reward ad failed to load: \(error.localizedDescription)")
                return
            }
            self.lastAdLoadError = nil
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            print("✅ Reward ad loaded")
        }
    }

    /// onReward: 報酬確定の瞬間に呼ばれる（ここで必ず報酬を付与する）
    /// onDismiss: 広告が閉じた後に呼ばれる。earned = 報酬を獲得したか
    func showAd(from root: UIViewController,
                onReward: @escaping () -> Void,
                onDismiss: ((Bool) -> Void)? = nil) {
        guard let ad = rewardedAd else {
            print("⚠️ Reward ad not ready")
            loadRewardedAd()
            onDismiss?(false)
            return
        }

        // 一度表示した広告は再利用できないので手放す
        rewardedAd = nil
        didEarnReward = false
        dismissAction = onDismiss
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
        action?(didEarnReward)
        loadRewardedAd()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Reward ad failed to present: \(error.localizedDescription)")
        let action = dismissAction
        dismissAction = nil
        action?(false)
        loadRewardedAd()
    }

}
