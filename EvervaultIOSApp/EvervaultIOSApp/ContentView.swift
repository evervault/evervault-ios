//
//  ContentView.swift
//  EvervaultIOSApp
//
//  Created by Lammert Westerhoff on 6/6/23.
//

import SwiftUI

import EvervaultCages
import EvervaultCore
import EvervaultInputs
//import EvervaultEnclaves

struct ContentView: View {

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

                Section("Cages") {
                    NavigationLink(destination: CageView()) {
                        Text("Cage HTTP Request")
                    }
                    
                    NavigationLink(destination: AttestedCageView()) {
                        Text("New Cage HTTP Request")
                    }
                    
//                    NavigationLink(destination: AttestedEnclaveView()) {
//                        Text("New Enclave HTTP Request")
//                    }
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
