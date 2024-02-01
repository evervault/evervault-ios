import XCTest


@testable import EvervaultCore
@testable import EvervaultCages
@testable import AttestationBindings

final class CagesAttestationTest: XCTestCase {

    func testConnectionUnauthenticated() async throws {
        
        let name = "synthetic-cage"
        let appUuid = "app-f5f084041a7e"
        let url = URL(string: "https://\(name).\(appUuid).cage.evervault.com/echo")!
        let urlSession = Evervault.cageAttestationSession(
            cageAttestationData: AttestationDataWithApp(
                name: name,
                appUuid: appUuid,
                pcrs: PCRs(
                    pcr0: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                    pcr1: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                    pcr2: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                    pcr8: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
                )
            )
        )
        
        let (data, response) = try await urlSession.data(from: url)
            
        if let httpResponse = response as? HTTPURLResponse {
            print(String(data: data, encoding: .utf8) ?? "No data")  // Print the data
            print(httpResponse)  // Print the response object
            XCTAssertEqual(httpResponse.statusCode, 401, "Expected a 401 Unauthenticated response")
        } else {
            XCTFail("Unexpected response type: \(type(of: response))")
            print("Response: \(response)")
            print("Data: \(String(data: data, encoding: .utf8) ?? "No data")")
        }
    }
    
    func testConnectionAuthenticated() async throws {
        
        let name = "synthetic-cage"
        let appUuid = "app-f5f084041a7e"
        let url = URL(string: "https://\(name).\(appUuid).cage.evervault.com/echo")!
        let urlSession = Evervault.cageAttestationSession(
            cageAttestationData: AttestationDataWithApp(
                name: name,
                appUuid: appUuid,
                pcrs: PCRs(
                    pcr0: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                    pcr1: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                    pcr2: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                    pcr8: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
                )
            )
        )
        
        let apiKey = ProcessInfo.processInfo.environment["EV_SYNTHETIC_API_KEY"] ?? "no-key"

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "api-key")

        let (data, response) = try await urlSession.data(for: request)  // Make the request using the URLRequest

            
        if let httpResponse = response as? HTTPURLResponse {
            print(String(data: data, encoding: .utf8) ?? "No data")  // Print the data
            print(httpResponse)  // Print the response object
            XCTAssertEqual(httpResponse.statusCode, 200, "Expected a 200 OK response")
        } else {
            XCTFail("Unexpected response type: \(type(of: response))")
            print("Response: \(response)")
            print("Data: \(String(data: data, encoding: .utf8) ?? "No data")")
        }
    }
    
    func testAttestationFails() async throws {
        let name = "synthetic-cage"
        let appUuid = "app-f5f084041a7e"
        let url = URL(string: "https://\(name).\(appUuid).cage.evervault.com/echo")!
        let urlSession = Evervault.cageAttestationSession(
            cageAttestationData: AttestationDataWithApp(
                name: name,
                appUuid: appUuid,
                pcrs: PCRs(
                    // Replace with legitimate PCR strings when not in debug mode
                    pcr0: "123000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                    pcr1: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                    pcr2: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                    pcr8: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
                )
            )
        )
        
        var request = URLRequest(url: url)

        do {
            let (data, response) = try await urlSession.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print(String(data: data, encoding: .utf8) ?? "No data")
                print(httpResponse)
                XCTFail("Response should not have succeeded due to incorrect PCRS")
            } else {
                XCTFail("Response should fail TLS due to incorrect PCRS")
            }
        } catch {
            // Handle the error
            XCTAssertTrue(true, "Successful test, attestation measures don't match so expected test to fail.")
        }
    }
}
