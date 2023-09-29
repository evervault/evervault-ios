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


    // replace with your cage name and app id
    private let cageName = "hello-cage"
    private let appId = "app_000000000000"

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
            let url = URL(string: "https://\(cageName).\(appId).cage.evervault.com/attestation")!
            let urlSession = Evervault.cageAttestationSession(
                cageAttestationData: AttestationDataWithApp(
                    cageName: cageName,
                    appUuid: appId,
                    pcrs: PCRs(
                        // Replace with legitimate PCR strings when not in debug mode
                        pcr0: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                        pcr1: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                        pcr2: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                        pcr8: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
                    )
                )
            )

            do {
                let response = try await urlSession.data(from: url)
                print(response)
                let cageRespone = try! JSONDecoder().decode(CageResponse.self, from: response.0)
                responseText = cageRespone.response
            } catch {
                responseText = error.localizedDescription
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

struct AttestedCageView_Previews: PreviewProvider {
    static var previews: some View {
        CageView()
    }
}
