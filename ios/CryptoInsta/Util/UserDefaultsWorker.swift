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

    func isOnboardingShown() -> Bool? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: UserDefaultsWorker.OnboardingShownKey) as? Bool
    }

    func setOnBoardingShown(shown: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(shown, forKey: UserDefaultsWorker.OnboardingShownKey)
    }
}
