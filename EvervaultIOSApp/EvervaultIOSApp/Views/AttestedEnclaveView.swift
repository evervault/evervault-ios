import SwiftUI

import EvervaultCore
import EvervaultCages
import EvervaultEnclaves

private struct EnclaveResponse: Decodable {
    let response: String
}

struct AttestedEnclaveView: View {

    // replace with your provider
    public var provider: (@escaping ([PCRs]?, Error?) -> Void) -> Void = { completion in
        URLSession.shared.dataTask(with: URL(string: "https://gist.githubusercontent.com/donaltuohy/5dbc1c175bcd0f0a9a621184cf3c78dc/raw/24582f4590ad074bd409049b4589be5300ebf6ce/pcrs.json")!) { data, _, error in
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
    private let enclaveName = "donal-prod-jan-2"
    private let appId = "app-7823eafc5d4e"
    
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
