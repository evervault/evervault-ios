//
//  ContentView.swift
//  EvervaultIOSApp
//
//  Created by Lammert Westerhoff on 6/6/23.
//

import SwiftUI

import Evervault

struct ContentView: View {

    private let password = "SuperSecretPassword"
    @State private var encryptedPassword: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Password:")
                    .bold()
                Text(password)
            }
            if let encryptedPassword = encryptedPassword {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Encrypted Password:")
                        .bold()
                    Text(encryptedPassword)
                }
            } else {
                Text("Encrypting password...")
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .task {
            do {
                encryptedPassword = try await Evervault.shared.encrypt(password) as? String
            } catch {
                print("Error while encrypting: \(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
