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
    private var rewardAction: (() -> Void)?
    
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

    func showAd(from root: UIViewController, reward: @escaping () -> Void) {
        guard let ad = rewardedAd else {
            print("⚠️ Reward ad not ready")
            loadRewardedAd()
            return
        }

        self.rewardAction = reward
        ad.present(from: root) {
            let reward = ad.adReward
            print("🎉 Reward received: \(reward.amount)")
            self.rewardAction?()
            self.rewardAction = nil
        }
    }

    // Optional: Reload ad after dismissed
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("🔁 Reward ad dismissed")
        loadRewardedAd()
    }
    
    
}
