import SwiftUI

public struct RowsPaymentCardInputStyle: PaymentCardInputStyle {

    public func makeBody(configuration: Configuration) -> some View {
        RowsPaymentCardInputView(configuration: configuration)
    }
}

private struct RowsPaymentCardInputView: View {

    let configuration: PaymentCardInputStyleConfiguration

    @Environment(\.font) private var font: Font?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                configuration.cardNumberField
                    .padding()

                Spacer()

                configuration.cardImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)
                    .padding(.trailing)
            }

            Divider()

            HStack(spacing: 0) {
                configuration.expiryField
                    .padding()

                Divider()

                configuration.cvcField
                    .padding()
            }
        }
            .font(font ?? .callout)
            .listRowInsets(EdgeInsets())
    }
}

extension PaymentCardInputStyle where Self == RowsPaymentCardInputStyle {
    public static var rows: RowsPaymentCardInputStyle {
        RowsPaymentCardInputStyle()
    }
}
