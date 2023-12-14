//
//  CageView.swift
//  EvervaultIOSApp
//
//  Created by Lammert Westerhoff on 7/3/23.
//

import SwiftUI

import EvervaultCore
import EvervaultCages

private struct CageResponse: Decodable {
    let response: String
}

struct CageView: View {


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
            let url = URL(string: "https://\(cageName).\(appId).cages.evervault.com/hello")!
            let urlSession = Evervault.cageSession(
                cageAttestationData:
                    AttestationData(
                        cageName: cageName,
                        pcrs: 
                            PCRs( //Can use a partial set of PCRs
                              pcr0: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
                        ),
                            PCRs( //Or can use a full set of PCRs
                            
                              pcr0: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              pcr1: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              pcr2: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              pcr8: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
                        )
                    )
            );

            do {
                let response = try await urlSession.data(from: url)
                let cageResponse = try! JSONDecoder().decode(CageResponse.self, from: response.0)
                responseText = cageResponse.response
            } catch {
                responseText = error.localizedDescription
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

struct CageView_Previews: PreviewProvider {
    static var previews: some View {
        CageView()
    }
}
