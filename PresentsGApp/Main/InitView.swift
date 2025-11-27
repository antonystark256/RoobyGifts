//
//  InitView.swift
//  PresentsGApp
//
//  Created by D K on 26.11.2025.
//

import SwiftUI

struct InitView: View {
    
    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted = false
    
    
    init() {
        // 2. Configure Realm & Basics
        RealmConfig.shared.configure()
        
        // 3. Customize global tabbar appearance just in case, though we use custom one
        UITabBar.appearance().isHidden = true
        
        // 4. Force dark keyboard for consistency
        UITextField.appearance().keyboardAppearance = .dark
    }
    
    var body: some View {
        Group {
            if isOnboardingCompleted {
                RootView()
                    .tint(.appPurple)
                    .transition(.opacity) // Smooth transition after onboarding
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            AppDelegate.orientationLock = .portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
        .preferredColorScheme(.dark) // FORCE DARK MODE EVERYWHERE
    }
}

#Preview {
    InitView()
}
