# Evervault iOS SDK

The [Evervault](https://evervault.com/) iOS SDK is a Swift package that provides secure data encryption for your iOS and macOS applications. It's simple to integrate, easy to use and it supports a wide range of data types. The package includes the core encryption functionality as well as a customizable SwiftUI view for secure credit card input.

## Features
- Core encryption capabilities for various data types.
- A secure and customizable PaymentCardInput SwiftUI view.
- Built-in data type recognition and appropriate encryption handling.

## Supported Platforms
- iOS 15+
- macOS 12+

## Dependencies
- [Mockingbird](https://github.com/birdrides/mockingbird)

## Installation

You can add Evervault iOS SDK to an Xcode project by adding it as a package dependency.

1. Click **File > Swift Packages > Add Package Dependency** in Xcode's menu.
2. Enter `https://github.com/<your-repo>/Evervault.git` into the package repository URL text box.
3. Follow the prompts using the Next and Finish buttons.

## Usage

### EvervaultCore
To use EvervaultCore, first import the module at the top of your Swift file.

```swift
import EvervaultCore
```

Next, configure the module with your team ID and app ID.

```swift
Evervault.shared.configure(teamId: <TEAM_ID>, appId: <APP_ID>)
```

After that, you can use Evervault to encrypt data.

```swift
let encryptedPassword = Evervault.shared.encrypt("Super Secret Password")
```

Evervault supports a variety of data types including `Boolean`, `Numerics`, `Strings`, `Arrays`, `Dictionaries`, and `Data`. The return type of `encrypt` is `Any`, so you will need to safely cast the result.

For `Boolean`, `Numerics`, and `Strings`, the `encrypt` function will return an encrypted `String`. For `Arrays` and `Dictionaries`, it will return an encrypted structure of the same type. For `Data` type, it will return encrypted `Data`, which can be useful for encrypting entire files.

### EvervaultInputs

The EvervaultInputs library contains a `PaymentCardInput` SwiftUI View. This view provides a secure way to accept and encrypt credit card data without exposing the unencrypted information. To use this view, first import the EvervaultInputs module.

```swift
import EvervaultInputs
```

Then, you can include the `PaymentCardInput` view in your SwiftUI views hierarchy.

```swift
PaymentCardInput()
```

## Customizing the PaymentCardInput View

The `PaymentCardInput` view is fully customizable. For detailed instructions on how to customize this view, please refer to the API Documentation.

## API Documentation

For more detailed instructions and examples, refer to the [API Documentation](<LINK_TO_YOUR_API_DOCUMENTATION>).

## Contributing

Contributions are welcome. Please create a pull request with your changes.

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file for details.

## Contact

For any queries, please feel free to reach out to us at [support@evervault.com](mailto:support@evervault.com).
