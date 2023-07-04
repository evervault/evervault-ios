# Evervault iOS SDK

The [Evervault](https://evervault.com/) iOS SDK is a Swift package that provides secure data encryption for your iOS and macOS applications. It's simple to integrate, easy to use and it supports a wide range of data types. The package includes the core encryption functionality as well as a customizable SwiftUI view for secure credit card input.

## Features
- Core encryption capabilities for various data types.
- A secure and customizable PaymentCardInput SwiftUI view.
- Built-in data type recognition and appropriate encryption handling.

## Supported Platforms
- iOS 15+
- macOS 12+

## Installation

The Evervault iOS SDK can be easily installed using the Swift Package Manager.

### Swift Package Manager

1. Open your Xcode project.
2. Navigate to **File** > **Swift Packages** > **Add Package Dependency**.
3. Enter the repository URL for the Evervault iOS SDK: `https://github.com/evervault/evervault-ios.git`.
4. Choose the latest available version or specify a version rule.
5. Click **Next** and follow the instructions to integrate the package into your project.

## Usage

### Configuration

Before using the Evervault iOS SDK, you need to configure it with your Evervault Team ID and App ID. This step is essential for establishing a connection with the Evervault encryption service.

First import the module at the top of your Swift file.

```swift
import EvervaultCore
```

To configure the SDK, call the following method with your Team ID and App ID:

```swift
Evervault.shared.configure(teamId: "<TEAM_ID>", appId: "<APP_ID>")
```

Make sure to replace `<TEAM_ID>` and `<APP_ID>` with your actual Evervault Team ID and App ID.

### Encrypting Data

Once the SDK is configured, you can use the `encrypt` method to encrypt your sensitive data. The `encrypt` method accepts various data types, including Boolean, Numerics, Strings, Arrays, Dictionaries, and Data.

Here's an example of encrypting a password:

```swift
let encryptedPassword = Evervault.shared.encrypt("Super Secret Password")
```

The `encrypt` method returns an `Any` type, so you will need to safely cast the result based on the data type you provided. For Boolean, Numerics, and Strings, the encrypted data is returned as a String. For Arrays and Dictionaries, the encrypted data maintains the same structure but is encrypted. For Data, the encrypted data is returned as encrypted Data, which can be useful for encrypting files.

### Inputs

The Evervault iOS SDK also includes the `EvervaultInputs` module, which provides a SwiftUI view called `PaymentCardInput`. This view is designed for capturing credit card information and automatically encrypts the credit card number and CVC without exposing the unencrypted data. The `PaymentCardInput` view can be customized to fit your application's design.

To use `PaymentCardInput`, make sure you have imported the `EvervaultInputs` module in your file, and then simply add the view to your SwiftUI hierarchy:

```swift
import EvervaultInputs

struct ContentView: View {

    @State private var cardData = PaymentCardData()

    var body: some View {
        VStack {
            PaymentCardInput(cardData: $cardData)

            // Data captured:
            Text("Encrypted credit card number: \(cardData.card.number)")
        }
    }
}
```

The encrypted credit card number and CVC are captured in the `PaymentCardData` Binding, as well as the expiry month and year and validation fields.

#### Styling

Internally, the `PaymentCardInput` view uses SwiftUI `TextField`s. These can be customized using SwiftUI modifiers like any other `TextField`s in your application:

```swift
    PaymentCardInput(cardData: $cardData)
        .font(.footnote)
        .foregroundColor(.blue)
```

To provide more customization options, the `PaymentCardInput` can be styled using a `PaymentCardInputStyle`. There are two build-in styles:
- `InlinePaymentCardInputView` (the default style) - puts the credit card number, expiry and cvc fields all on a single row.

<img src="https://github.com/evervault/evervault-ios/blob/27f4b2c1dedbe9865a8b5afe89d55f5f0ef24d48/inline.png?raw=true" alt="InlinePaymentCardInputView" align="center"/>

To explicitly use this style:
```swift
    PaymentCardInput(cardData: $cardData)
        .paymentCardInputStyle(.inline)
```

 - `RowsPaymentCardInputStyle` -  puts the credit card number on a single row. Below it, places the expiry and cvc fields next to each other.

<img src="https://github.com/evervault/evervault-ios/blob/27f4b2c1dedbe9865a8b5afe89d55f5f0ef24d48/rows.png?raw=true" alt="RowsPaymentCardInputStyle" align="center"/>

To use this style:
```swift
    PaymentCardInput(cardData: $cardData)
        .paymentCardInputStyle(.rows)
```

If these two styles do not match your use case, you can create your own style:
```swift
struct CustomPaymentCardInputStyle: PaymentCardInputStyle {

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
```

```swift
    PaymentCardInput(cardData: $cardData)
        .paymentCardInputStyle(CustomPaymentCardInputStyle())
```

### Cages (Beta)

Evervault Cages allow developers to easily deploy Docker containers in a Secure Enclave. Endpoints of Cages are requested using normal HTTP requests. For this to work from iOS, it needs to verify the attestation before completing the TLS handshake. See Cages's [TLS Attestation](https://docs.evervault.com/products/cages#tls-attestation) to learn more.

The attestation verification is done in a custom `URLSessionDelegate`: `AttestationSessionDelegate`. The delegate is initialized with one or more `AttestationData` objects:

```swift
struct AttestationData {
    let cageName: String
    let pcrs: [PCRs]
}

struct PCRs {
    let pcr0: String
    let pcr1: String
    let pcr2: String
    let pcr8: String
}
```

These PCRs need to match the PCRs of the Cage.

You can either create your own `URLSession`s and configure them with the delegate or you can use `Evervault.cageSession(cageAttestationData:)` to create such a `URLSession` for you:

```swift
let url = URL(string: "https://\(cageName).\(appId).cages.evervault.com/attestation-doc")!
let urlSession = Evervault.cageSession(
    cageAttestationData: AttestationData(
        cageName: cageName,
        pcrs: PCRs(
            // replace with valid PCR string when not running in debug mode
            pcr0: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            pcr1: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            pcr2: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            pcr8: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        )
    )
)
let response = try await urlSession.data(from: url)
```

#### Limitations

- Keep it mind that the Cage PCRs change with each new Cage deployment. Therefore it's possible that an older version of your app with hardcoded PCRs would stop working. You can however support older deployments by providing multipl `PCRs` objects:

```swift
AttestationData(
    cageName: cageName,
    pcrs: PCRs(
        pcr0: "fd4b",
        pcr1: "bc3f",
        pcr2: "2c10",
        pcr8: "dfb3"
    ),
    PCRs(
        pcr0: "c779",
        pcr1: "bc3f",
        pcr2: "4cbf",
        pcr8: "dfb3"
    )
)
```

- Since the Cage works wirth self signed certificates, you need to add an exception for the Cage to the *App Transport Security Settings* of your Info.plist file:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>evervault.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

- The iOS SDK only works with Cages that have API Key Authentication set to `false` in your cage.toml file:
```
api_key_auth = false
```

## Sample App

The Evervault iOS SDK Package includes a sample app, located in the `EvervaultIOSApp` directory. The sample app demonstrates various use cases of the SDK, including string encryption, file (image) encryption, and the usage of the `PaymentCardInput` view with customized styling.

## Running the Sample App

To run the sample app:

1. Open the `EvervaultIOSApp.xcodeproj` file in Xcode.
2a. Configure your Team ID and App ID in `EvervaultIOSAppApp.swift` or
2b. Add `EV_TEAM_UUID` and `EV_APP_UUID` Environment Variables to the Run Scheme
3. Select a simulator or physical device as the build target.
4. Build and run the app.

## License

The sample app is released under the MIT License. See the [LICENSE](https://github.com/evervault/evervault-ios/blob/main/LICENSE) file for more information.

Feel free to experiment with the sample app to understand the capabilities of the Evervault iOS SDK and explore different integration options for your own projects.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/evervault/evervault-ios.

## Feedback

Questions or feedback? [Let us know](mailto:support@evervault.com).
