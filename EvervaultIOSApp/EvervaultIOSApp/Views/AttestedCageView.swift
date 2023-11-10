//
//  AttestedCageView.swift
//  EvervaultIOSApp
//
//  Created by Donal Tuohy on 29/09/2023.
//

import SwiftUI

import EvervaultCore
import EvervaultCages

private struct CageResponse: Decodable {
    let response: String
}

struct AttestedCageView: View {

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
    private let cageName = "donal-nov-10-egress"
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
            let url = URL(string: "https://\(cageName).\(appId).cage.evervault.com/hi")!
            let urlSession = Evervault.cageAttestationSession(
                cageAttestationData: AttestationDataWithApp(
                    cageName: cageName,
                    appUuid: appId,
                    provider: provider
                )
            )

            do {
                let response = try await urlSession.data(from: url)
                print(response)
                let cageResponse = try! JSONDecoder().decode(CageResponse.self, from: response.0)
                responseText = cageResponse.response
            } catch {
                responseText = error.localizedDescription
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

struct AttestedCageView_Previews: PreviewProvider {
    static var previews: some View {
        AttestedCageView()
    }
}
