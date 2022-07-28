//
//  UserDefaultsWorker.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation

class UserDefaultsWorker {
    static let shared = UserDefaultsWorker()
    
    private static let OnboardingShownKey = "onboarding_shown"
    private static let FaucetUsedKey = "faucet_used"
    private static let TwitterLoginKey = "twitter_login"

    func isOnboardingShown() -> Bool? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: UserDefaultsWorker.OnboardingShownKey) as? Bool
    }

    func setOnBoardingShown(shown: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(shown, forKey: UserDefaultsWorker.OnboardingShownKey)
    }
    
    func isFaucetUsed() -> Bool? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: UserDefaultsWorker.OnboardingShownKey) as? Bool
    }

    func setFaucetUsed() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: UserDefaultsWorker.OnboardingShownKey)
    }
    
    func getTwitterLogin() -> String {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: UserDefaultsWorker.TwitterLoginKey) as? String ?? ""
    }
    
    func saveTwitterLogin(token: String) {
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: UserDefaultsWorker.TwitterLoginKey)
    }
}
