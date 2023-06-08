//
//  EvervaultIOSAppApp.swift
//  EvervaultIOSApp
//
//  Created by Lammert Westerhoff on 6/6/23.
//

import SwiftUI

import Evervault

@main
struct EvervaultIOSAppApp: App {

    init() {
        let teamId: String = nil ?? ProcessInfo.processInfo.environment["VITE_EV_TEAM_UUID"]! // replace nil with teamId or specify teamId as environment variable
        let appId: String = nil ?? ProcessInfo.processInfo.environment["VITE_EV_APP_UUID"]! // replace nil with appId or specify teamId as environment variable
        Evervault.shared.configure(teamId: teamId, appId: appId)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
