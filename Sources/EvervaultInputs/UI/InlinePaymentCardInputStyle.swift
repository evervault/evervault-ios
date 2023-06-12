import SwiftUI

public struct InlinePaymentCardInputStyle: PaymentCardInputStyle {

    public func makeBody(configuration: Configuration) -> some View {
        InlinePaymentCardInputView(configuration: configuration)
    }
}

private struct InlinePaymentCardInputView: View {

    let configuration: PaymentCardInputStyleConfiguration

    @State private var size: CGSize = .zero

    @Environment(\.font) private var font: Font?

    private var availableWidth: CGFloat {
        return max(0, size.width - (30 + 4 * 3))
    }

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ZStack {}.onAppear {
                    size = proxy.size
                }
            }
            HStack(alignment: .center, spacing: 0) {
                configuration.cardImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)

                Spacer().frame(width: 4)

                configuration.cardNumberField
                    .frame(width: availableWidth * 0.66)

                Spacer().frame(width: 4)

                configuration.expiryField
                    .frame(width: availableWidth * 0.20)

                Spacer().frame(width: 4)

                configuration.cvcField
                    .frame(width: availableWidth * 0.14)
            }
            .font(font ?? .callout)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension PaymentCardInputStyle where Self == InlinePaymentCardInputStyle {
    public static var inline: InlinePaymentCardInputStyle {
        InlinePaymentCardInputStyle()
    }
}
