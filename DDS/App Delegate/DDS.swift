//
//  DDS.swift
//  DDS
//
//  Created by Nirmit Dagly on 30/12/2022.
//

import SwiftUI
import IQKeyboardManagerSwift

@main
struct DDS: App {
    @StateObject var alertController = AlertController()
    @StateObject var view = Views()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            Login()
                .environmentObject(view)
        }
    }
}

struct DDS_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}

// MARK: Add from here
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        IQKeyboardManager.shared.enable = true
        
        return true
    }
}
