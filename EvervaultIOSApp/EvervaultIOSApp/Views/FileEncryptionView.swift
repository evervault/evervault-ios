import PhotosUI
import SwiftUI

import EvervaultCore

struct FileEncryptionView: View {

    @State private var imageItem: PhotosPickerItem?
    @State private var image: Image?

    @State private var encryptedData: Data?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PhotosPicker("Select photo", selection: $imageItem, matching: .images)

                image?
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)


                if let encoded = encryptedData?.base64EncodedString() {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Encrypted image data as Base64 Encoded")
                            .font(.headline)

                        let limit = 5000
                        Text("Only showing first \(limit) characters")
                            .font(.footnote)
                        Text(encoded.prefix(limit))
                            .font(.callout)
                    }
                }
            }
            .padding()
        }
        .onChange(of: imageItem) { _ in
            Task {
                if let data = try? await imageItem?.loadTransferable(type: Data.self) {
                    self.encryptedData = try? await Evervault.shared.encrypt(data) as? Data
                    #if os(iOS)
                    if let uiImage = UIImage(data: data) {
                        image = Image(uiImage: uiImage)
                        return
                    }
                    #elseif os(macOS)
                    if let nsImage = NSImage(data: data) {
                        image = Image(nsImage: nsImage)
                        return
                    }
                    #endif
                }

                print("Failed")
            }
        }
    }
}

struct FileEncryptionView_Previews: PreviewProvider {
    static var previews: some View {
        FileEncryptionView()
    }
}
