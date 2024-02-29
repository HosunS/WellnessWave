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
import UserNotifications


class AppDelegate: NSObject,UIApplicationDelegate, UNUserNotificationCenterDelegate{
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey:Any]? = nil) -> Bool{
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
            }
        
        UNUserNotificationCenter.current().delegate = self

        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .sound])
        }
}


@main
struct WellnessWaveApp: App {
//register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    init() {
        configureNavigationBarAppearance()
    }
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                HomePageView()
                    .environmentObject(authViewModel)
            } else {
                WelcomeView()
                    .environmentObject(authViewModel)
            }
        }
    }
    
    func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black // Your preferred background color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Sets the title color to white
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // Also set large title color if you use it
        
        // Apply the appearance settings to all navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
