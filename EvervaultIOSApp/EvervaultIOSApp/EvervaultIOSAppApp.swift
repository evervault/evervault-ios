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
        Evervault.shared.configure(teamId: "team_2cc9843ad3d4", appId: "app_b2630facb2f9")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
