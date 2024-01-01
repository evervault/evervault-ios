import SwiftUI

import EvervaultCore
import EvervaultEnclaves

private struct EnclaveResponse: Decodable {
    let response: String
}

struct AttestedEnclaveView: View {

    // replace with your provider
    public var provider: (@escaping ([PCRs]?, Error?) -> Void) -> Void = { completion in
        URLSession.shared.dataTask(with: URL(string: "https://example.provider.com")!) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error ?? NSError(domain: "Evervault Provider", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data or error."]))
                return
            }
            do {
                completion(try JSONDecoder().decode([PCRs].self, from: data), nil)
            } catch {
                print("Error: ", error.localizedDescription)
                completion(nil, error)
            }
        }.resume()
    }

    // replace with your cage name and app id
    private let enclaveName = "hello-cage"
    private let appId = "app-000000000000"
    
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
            let url = URL(string: "https://\(cageName).\(appId).cage.evervault.com/hello")!
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
