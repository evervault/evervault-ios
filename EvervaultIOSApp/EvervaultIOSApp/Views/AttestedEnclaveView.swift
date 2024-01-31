import SwiftUI

import EvervaultCore
import EvervaultEnclaves

private struct EnclaveResponse: Decodable {
    let response: String
}

struct AttestedEnclaveView: View {
    public struct EvervaultProviderResponse: Decodable {
        public let data: [PCRs]

        public init(data: [PCRs]) {
            self.data = data
        }
    }
    
    
    //Automatically pulls PCRs for Enclave from Evervault API
    public var provider: (@escaping ([PCRs]?, Error?) -> Void) -> Void = { completion in
        var request = URLRequest(url: URL(string: "https://api.evervault.com/enclaves/$[ENCLAVE_NAME]/attestation")!)
        request.addValue("$[UNDERSCORED APP UUID]", forHTTPHeaderField: "x-evervault-app-id")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error ?? NSError(domain: "Evervault Provider", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data or error."]))
                return
            }
            do {
                let container = try JSONDecoder().decode(EvervaultProviderResponse.self, from: data)
                completion(container.data, nil)
            } catch {
                print("Error: ", error.localizedDescription)
                completion(nil, error)
            }
        }.resume()
    }

    private let enclaveName = "$[ENCLAVE_NAME]"
    private let appId = "$[HYPHENATED APP UUID]"
    
    @State private var responseText: String? = nil

    var body: some View {
        Group {
            if let responseText {
                Text(responseText)
            } else {
                Text("Loading...")
            }
        }
        .padding()
        .task {
            do {
                // Use async function to get the session
                let urlSession = await Evervault.enclaveAttestationSession(
                    enclaveAttestationData: EnclaveAttestationData(
                        enclaveName: enclaveName,
                        appUuid: appId,
                        provider: provider
                    )
                )

                let url = URL(string: "https://\(enclaveName).\(appId).enclave.evervault.com/hello")!
                let (data, _) = try await urlSession.data(from: url)
                let enclaveResponse = try JSONDecoder().decode(EnclaveResponse.self, from: data)
                responseText = enclaveResponse.response
            } catch {
                responseText = error.localizedDescription
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

struct AttestedEnclaveView_Previews: PreviewProvider {
    static var previews: some View {
        AttestedEnclaveView()
    }
}
