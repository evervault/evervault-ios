//
//  EvervaultIOSAppApp.swift
//  EvervaultIOSApp
//
//  Created by Lammert Westerhoff on 6/6/23.1
//

import SwiftUI

import EvervaultCore

@main
struct EvervaultIOSAppApp: App {

    init() {
        let teamId: String = nil ?? ProcessInfo.processInfo.environment["EV_TEAM_UUID"]! // replace nil with teamId or specify teamId as environment variable
        let appId: String = nil ?? ProcessInfo.processInfo.environment["EV_APP_UUID"]! // replace nil with appId or specify teamId as environment variable
        Evervault.shared.configure(teamId: teamId, appId: appId)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
