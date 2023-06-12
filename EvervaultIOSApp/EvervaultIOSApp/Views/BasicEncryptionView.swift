import SwiftUI

import EvervaultCore

struct BasicEncryptionView: View {

    @State private var password = "SuperSecretPassword"
    @State private var encryptedPassword: String?

    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 4) {
                Text("Password:")
                    .bold()
                TextField("Password", text: $password)
            }
            if let encryptedPassword = encryptedPassword {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Encrypted Password:")
                        .bold()
                    Text(encryptedPassword)
                }
            } else {
                Text("Encrypting password...")
            }
        }
        .task {
            await encryptPassword()
        }
        .onChange(of: self.password) { _ in
            Task {
                await encryptPassword()
            }
        }
    }

    private func encryptPassword() async {
        do {
            encryptedPassword = try await Evervault.shared.encrypt(password) as? String
        } catch {
            print("Error while encrypting: \(error)")
        }
    }
}

struct BasicEncryptionView_Previews: PreviewProvider {
    static var previews: some View {
        BasicEncryptionView()
    }
}
