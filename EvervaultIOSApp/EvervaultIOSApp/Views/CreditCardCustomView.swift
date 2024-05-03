//
//  SwiftUIView.swift
//  
//
//  Created by Eoin Boylan on 03/05/2024.
//

import SwiftUI
import EvervaultInputs

struct CreditCardCustomView: View {
    @State private var cardData = PaymentCardData()
    
    private var enabledFields = EnabledFields(isCardNumberEnabled: true, isExpiryEnabled: false, isCVCEnabled: false)
    
    var body: some View {
        Form {
            Section("Payment card input") {
                PaymentCardInput(cardData: $cardData, fields: enabledFields)
            }
            
            Section("Payment card data") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Card number:")
                        .bold()
                    Text(cardData.card.number)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bin:")
                        .bold()
                    Text(cardData.card.bin)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last 4:")
                        .bold()
                    Text(cardData.card.lastFour)
                }
                
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Card type:")
                        .bold()
                    Text(cardData.card.type?.brand ?? "")
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Is valid:")
                        .bold()
                    Text(cardData.isValid ? "Yes" : "No")
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Is potentially valid:")
                        .bold()
                    Text(cardData.isPotentiallyValid ? "Yes" : "No")
                }
                
                if let error = cardData.error {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Error message:")
                            .bold()
                        Text(error.localizedDescription)
                    }
                }
            }
        }
    }
}

struct CreditCardCustomView_Previews: PreviewProvider {
    static var previews: some View {
        CreditCardCustomView()
    }
}
