import SwiftUI

import EvervaultCore
import EvervaultEnclaves

private struct EnclaveResponse: Decodable {
    let response: String
}

struct AttestedEnclaveView: View {
    // The Evervault API returns a list of the active PCRs for an Enclave under a top level "data" key:
    // { "data": [ { "pcr0": "...", ... } ] }
    public struct EvervaultProviderResponse: Decodable {
        public let data: [PCRs]

        public init(data: [PCRs]) {
            self.data = data
        }
    }

    // replace with your cage name and app id
    private let enclaveName = "example-enclave"
    private let appId = "app-uuid" //Make sure it's hyphenated

    // Using the Evervault API as a PCR Provider
    public var provider: (@escaping ([PCRs]?, Error?) -> Void) -> Void = { completion in
        var request = URLRequest(url: URL(string: "https://api.evervault.com/enclaves/\(enclaveName)/attestation")!)
        var underscoredAppId = appId.replacingOccurrences(of: "-", with: "_")
        request.addValue(underscoredAppId, forHTTPHeaderField: "x-evervault-app-id")
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error ?? NSError(domain: "Evervault Provider", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data or error."]))
                return
            }
            do {
                // Decode the API Response into a PCRContainer
                let container = try JSONDecoder().decode(EvervaultProviderResponse.self, from: data)
                // Extract the PCRs array from the container and pass it to the completion handler
                completion(container.data, nil)
            } catch {
                print("Error: ", error.localizedDescription)
                completion(nil, error)
            }
        }.resume()
    }
    
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
            let url = URL(string: "https://\(enclaveName).\(appId).enclave.evervault.com/hello")!
            let urlSession = Evervault.enclaveAttestationSession(
                enclaveAttestationData: EnclaveAttestationData(
                    enclaveName: enclaveName,
                    appUuid: appId,
                    provider: provider
                )
            )

            do {
                let response = try await urlSession.data(from: url)
                print(response)
                let enclaveResponse = try! JSONDecoder().decode(EnclaveResponse.self, from: response.0)
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
