import SwiftUI

import EvervaultCore

public struct PaymentCardInput: View {

    @State private var creditCardNumber: String = ""
    @State private var cvc: String = ""
    @State private var expiryDate: String = ""
    @State private var expiryTextLen = 0

    @State private var rawCardData = PaymentCardData()
    @Binding private var cardData: PaymentCardData

    @Environment(\.paymentCardInputStyle) private var style

    private enum FocusField: Hashable, Equatable {
        case number, expiry, cvc
    }

    @FocusState private var focusedField: FocusField?

    public init(cardData: Binding<PaymentCardData>) {
        _cardData = cardData    }

    private var cardImageName: String {
        guard let cardType = cardData.card.type else {
            return "unknownCard"
        }

        guard cardData.isPotentiallyValid || CreditCardValidator(rawCardData.card.number).actualType.map({ CreditCardValidator.isValidCvc(cvc: self.rawCardData.card.cvc, type: $0) }) == false else {
            return "errorCard"
        }

        return cardType.rawValue
    }

    public var body: some View {
        AnyView(
            style.makeBody(configuration: PaymentCardInputStyleConfiguration(
                cardImage: Image(cardImageName, bundle: Bundle.module),
                cardNumberField: AnyView(
                    MultiplatformNumberTextfield(text: $creditCardNumber, prompt: "4242 4242 4242 4242", label: "Card number")
                        .focused($focusedField, equals: .number)
                ),
                expiryField: AnyView(
                    TextField(text: $expiryDate, prompt: Text(LocalizedString("MM/YY"))) {
                        Text(LocalizedString("MM/YY"))
                    }
                        .focused($focusedField, equals: .expiry)
                ),
                cvcField: AnyView(
                    MultiplatformNumberTextfield(text: $cvc, prompt: "CVC", label: "CVC")
                )
            ))
        )
        .onChange(of: self.rawCardData.card.number) { number in
            updateCardData { cardData in
                var updatedCardData = cardData
                updatedCardData.card.number = number.isEmpty ? "" : try await Evervault.shared.encrypt(number) as? String ?? ""
                return updatedCardData
            }
        }
        .onChange(of: self.rawCardData.card.cvc) { cvc in
            updateCardData { cardData in
                var updatedCardData = cardData
                updatedCardData.card.cvc = cvc.isEmpty ? "" : try await Evervault.shared.encrypt(cvc) as? String ?? ""
                return updatedCardData
            }
        }
        .onChange(of: self.rawCardData.expiry) { expiry in
            updateCardData()
        }
        .onChange(of: creditCardNumber) { value in
            self.rawCardData.updateNumber(value)
            self.creditCardNumber = self.rawCardData.card.number

            let validator = CreditCardValidator(self.creditCardNumber)
            if let type = validator.actualType, validator.string.count == type.validNumberLength.last {
                focusedField = .expiry
            }
        }
        .onChange(of: cvc) { value in
            self.rawCardData.updateCvc(value)
            self.cvc = self.rawCardData.card.cvc
        }
        .onChange(of: expiryDate) { value in
            var value = value
            if expiryTextLen > value.count && value.count == 2 {
                // delete key used on '/'
                value = String(value.prefix(1))
            }

            expiryTextLen = value.count
            expiryDate = CreditCardFormatter.formatExpiryDate(value)

            self.rawCardData.updateExpiry(value)

            if value.count == 5 {
                focusedField = .cvc
            }
        }
    }

    private func updateCardData(update: ((PaymentCardData) async throws -> (PaymentCardData))? = nil) {
        Task {
            do {
                var updatedCardData = self.rawCardData
                updatedCardData.card.number = self.cardData.card.number
                updatedCardData.card.cvc = self.cardData.card.cvc
                updatedCardData = try await update?(updatedCardData) ?? updatedCardData
                self.cardData = updatedCardData
            } catch {
                self.cardData.error = PaymentCardError(type: "encryption_failed", message: error.localizedDescription)
            }
        }
    }
}

fileprivate struct MultiplatformNumberTextfield: View {

    @Binding var text: String
    let prompt: String
    let label: String

    var body: some View {
        #if os(iOS)
        TextField(text: $text, prompt: Text(prompt)) {
            Text(LocalizedString(label))
        }
            .keyboardType(.numberPad)
        #elseif os(macOS)
        TextField(text: $text, prompt: Text(prompt)) {
            Text(LocalizedString(label))
        }
        #endif
    }
}

struct PaymentCardInput_Previews: PreviewProvider {
    static var previews: some View {
        PaymentCardInput(cardData: .constant(.init()))
    }
}
