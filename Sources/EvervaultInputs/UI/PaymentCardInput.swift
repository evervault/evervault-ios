import SwiftUI

import EvervaultCore

/// `PaymentCardInput` is a SwiftUI `View` that provides a user interface for entering and validating payment card information.
public struct PaymentCardInput: View {

    /// The state for the credit card number.
    @State private var creditCardNumber: String = ""

    /// The state for the credit card's CVC (Card Verification Code).
    @State private var cvc: String = ""

    /// The state for the credit card's expiry date.
    @State private var expiryDate: String = ""

    /// The state for the length of the expiry date text.
    @State private var expiryTextLen = 0

    /// The state for the raw payment card data entered by the user.
    @State private var rawCardData = PaymentCardData()

    /// The final, validated payment card data.
    @Binding private var cardData: PaymentCardData

    /// The style to be applied to this `PaymentCardInput` view, provided by the environment.
    @Environment(\.paymentCardInputStyle) private var style

    /// Enumeration of fields that could be focused.
    private enum FocusField: Hashable, Equatable {
        case number, expiry, cvc
    }

    /// The field currently focused for input.
    @FocusState private var focusedField: FocusField?

    /// Creates a new instance of `PaymentCardInput`.
    ///
    /// - Parameter cardData: A `Binding` to the final payment card data.
    public init(cardData: Binding<PaymentCardData>) {
        _cardData = cardData
    }

    /// The name of the image for the current card type.
    private var cardImageName: String {
        guard let cardType = cardData.card.type else {
            return "unknownCard"
        }

        guard cardData.isPotentiallyValid || CreditCardValidator(rawCardData.card.number).actualType.map({ CreditCardValidator.isValidCvc(cvc: self.rawCardData.card.cvc, type: $0) }) == false else {
            return "errorCard"
        }

        return cardType.rawValue
    }

    /// The body of the SwiftUI view.
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
                    #if os(iOS)
                        .keyboardType(.numberPad)
                    #endif
                ),
                cvcField: AnyView(
                    MultiplatformNumberTextfield(text: $cvc, prompt: "CVC", label: "CVC")
                )
            ))
        )
        .onChange(of: self.rawCardData.card.number) { number in
            updateCardData { cardData in
                var updatedCardData = cardData
                updatedCardData.card.number = number.isEmpty ? "" : try await Evervault.shared.encrypt(number.replacingOccurrences(of: " ", with: "")) as? String ?? ""
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

    /// Updates the payment card data, either by calling the provided update function or by copying from `rawCardData`.
    ///
    /// - Parameter update: An asynchronous function that takes the current payment card data and returns updated data.
    private func updateCardData(update: ((PaymentCardData) async throws -> (PaymentCardData))? = nil) {
        Task {
            do {
                var updatedCardData = self.rawCardData
                updatedCardData.card.number = self.cardData.card.number
                updatedCardData.card.cvc = self.cardData.card.cvc
                updatedCardData = try await update?(updatedCardData) ?? updatedCardData
                self.cardData = updatedCardData
            } catch {
                self.cardData.error = .encryptionFailed(message: error.localizedDescription)
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
