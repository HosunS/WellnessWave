//
//  WellnessWaveApp.swift
//  WellnessWave
//
//  Created by Ho sun Song on 1/29/24.
//

import SwiftUI
//import EventKit
//import HealthKit
import Firebase
import FirebaseCore

class AppDelegate: NSObject,UIApplicationDelegate{
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey:Any]? = nil) -> Bool{
        FirebaseApp.configure()
        return true
    }
}

@main
struct WellnessWaveApp: App {
    
//register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
