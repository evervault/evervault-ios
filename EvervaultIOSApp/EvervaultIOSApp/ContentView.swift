//
//  ContentView.swift
//  EvervaultIOSApp
//
//  Created by Lammert Westerhoff on 6/6/23.
//

import SwiftUI

import EvervaultCore
import EvervaultInputs

struct ContentView: View {

    enum Target {
        case basicEncryption
        case creditCardInputInline
    }

    private let password = "SuperSecretPassword"
    @State private var encryptedPassword: String?

    @State private var cardData = PaymentCardData()

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink(destination: BasicEncryptionView()) {
                    Text("Basic Encryption")
                }
                NavigationLink(destination: FileEncryptionView()) {
                    Text("File Encryption")
                }
                Section("Credit Card Inputs") {
                    NavigationLink(destination: CreditCardInputView()) {
                        Text("Inline (Default)")
                    }
                    NavigationLink(destination:
                                    CreditCardInputView()
                        .font(.footnote)
                        .foregroundColor(.blue)
                    ) {
                        Text("Inline Customized")
                    }
                    NavigationLink(destination: CreditCardInputView().paymentCardInputStyle(.rows)) {
                        Text("Rows")
                    }
                    NavigationLink(destination: CreditCardInputView()
                        .paymentCardInputStyle(CustomPaymentCardInputStyle())) {
                        Text("Custom Style")
                    }
                }
            }
        } detail: {}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

fileprivate struct CustomPaymentCardInputStyle: PaymentCardInputStyle {

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center) {
            configuration.cardImage

            Text("CC Number").font(.title3)
            configuration.cardNumberField

            Divider()

            Text("Expiry").font(.title3)
            configuration.expiryField

            Divider()

            Text("CVC").font(.title3)
            configuration.cvcField
        }
    }
}
