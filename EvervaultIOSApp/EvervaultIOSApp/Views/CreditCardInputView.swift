import SwiftUI

import EvervaultInputs

struct CreditCardInputView: View {

    @State private var cardData = PaymentCardData()
    
    var body: some View {
        Form {
            Section("Payment card input") {
                PaymentCardInput(cardData: $cardData)
            }

            Section("Payment card data") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Card number:")
                        .bold()
                    Text(cardData.card.number)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("CVC:")
                        .bold()
                    Text(cardData.card.cvc)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Card type:")
                        .bold()
                    Text(cardData.card.type?.brand ?? "")
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Exp month:")
                        .bold()
                    Text(cardData.card.expMonth)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Exp year:")
                        .bold()
                    Text(cardData.card.expYear)
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

struct CreditCardInputView_Previews: PreviewProvider {
    static var previews: some View {
        CreditCardInputView()
    }
}
