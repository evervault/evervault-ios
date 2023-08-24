import XCTest

@testable import EvervaultCore

final class EvervaultDecryptTest: XCTestCase {
    
    let appId = ProcessInfo.processInfo.environment["VITE_EV_APP_UUID"]!
    let apiKey = ProcessInfo.processInfo.environment["VITE_EV_API_KEY"]!
    let evervault: Evervault = Evervault(
        teamId: ProcessInfo.processInfo.environment["VITE_EV_TEAM_UUID"]!,
        appId: ProcessInfo.processInfo.environment["VITE_EV_APP_UUID"]!
    )
    
    func testDecryptThrowsErrorForUnsupportedEncryptedType() async throws {
        let encryptedNumber = 123
        var token = try await createClientSideToken(data: ["data": encryptedNumber])
        var errorThrown = false
        do {
            let _: Int = try await evervault.decrypt(token: token, data: encryptedNumber)
        } catch {
            errorThrown = true
            XCTAssertEqual(error as? EvervaultError, EvervaultError.unsupportedEncryptedTypeError)
        }
        XCTAssertTrue(errorThrown)
        
        let encryptedArray = [123, 123]
        token = try await createClientSideToken(data: ["data": encryptedArray])
        errorThrown = false
        do {
            let _: Int = try await evervault.decrypt(token: token, data: encryptedArray)
        } catch {
            errorThrown = true
            XCTAssertEqual(error as? EvervaultError, EvervaultError.unsupportedEncryptedTypeError)
        }
        XCTAssertTrue(errorThrown)
    }
    
    func testDecryptThrowsErrorForInvalidReturnCast() async throws {
        let str = "Hello World!"
        let encrypted = try await evervault.encrypt(str)
        let token = try await createClientSideToken(data: ["data": encrypted])
        var errorThrown = false
        do {
            let _: Int = try await evervault.decrypt(token: token, data: encrypted)
        } catch {
            errorThrown = true
            XCTAssertEqual(error as? EvervaultError, EvervaultError.invalidCast)
        }
        XCTAssertTrue(errorThrown)
    }
    
    func testDecryptDoesNotThrowForNonEncryptedData() async throws {
        let str = "Hello World!"
        let token = try await createClientSideToken(data: ["data": str])
        let decrypted: String = try await evervault.decrypt(token: token, data: str)
        XCTAssertEqual(str, decrypted)
    }
    
    func testDecryptDoesNotThrowForInvalidEncryptedData() async throws {
        let str = "ev:Tk9D:+HgtYJkhglHsipoC:helloworld:helloworld:$"
        let token = try await createClientSideToken(data: ["data": str])
        let decrypted: String = try await evervault.decrypt(token: token, data: str)
        XCTAssertEqual(str, decrypted)
    }
    
    func testDecryptString() async throws {
        let str = "Hello World!"
        let encrypted = try await evervault.encrypt(str)
        let token = try await createClientSideToken(data: ["data": encrypted])
        let decrypted: String = try await evervault.decrypt(token: token, data: encrypted)
        XCTAssertEqual(str, decrypted)
    }
    
    func testDecryptInt() async throws {
        let number = 12345
        let encrypted = try await evervault.encrypt(number)
        let token = try await createClientSideToken(data: ["data": encrypted])
        let decrypted: Int = try await evervault.decrypt(token: token, data: encrypted)
        XCTAssertEqual(number, decrypted)
    }
    
    func testDecryptDouble() async throws {
        let number = 123.45
        let encrypted = try await evervault.encrypt(number)
        let token = try await createClientSideToken(data: ["data": encrypted])
        let decrypted: Double = try await evervault.decrypt(token: token, data: encrypted)
        XCTAssertEqual(number, decrypted)
    }
    
    func testDecryptTrue() async throws {
        let bool = true
        let encrypted = try await evervault.encrypt(bool)
        let token = try await createClientSideToken(data: ["data": encrypted])
        let decrypted: Bool = try await evervault.decrypt(token: token, data: encrypted)
        XCTAssertEqual(bool, decrypted)
    }
    
    func testDecryptFalse() async throws {
        let bool = false
        let encrypted = try await evervault.encrypt(bool)
        let token = try await createClientSideToken(data: ["data": encrypted])
        let decrypted: Bool = try await evervault.decrypt(token: token, data: encrypted)
        XCTAssertEqual(bool, decrypted)
    }
    
    func testDecryptArray() async throws {
        let array = ["hello world", "lol"]
        let encrypted = try await evervault.encrypt(array)
        let token = try await createClientSideToken(data: ["data": encrypted])
        let decrypted: [String] = try await evervault.decrypt(token: token, data: encrypted)
        XCTAssertEqual(array, decrypted)
    }
    
    func testDecryptDictionary() async throws {
        let array = ["hello world!", 12345, 123.45, true, false] as [Any]
        let dict = [
            "string": "hello world!",
            "int": 12345,
            "double": 123.45,
            "true": true,
            "false": false,
            "array": array
        ] as [String : Any]
        let encrypted = try await evervault.encrypt(dict)
        let token = try await createClientSideToken(data: encrypted as! [String : Any])
        let decrypted: [String : Any] = try await evervault.decrypt(token: token, data: encrypted)
        XCTAssertEqual(dict["string"] as! String, decrypted["string"] as! String)
        XCTAssertEqual(dict["int"] as! Int, decrypted["int"] as! Int)
        XCTAssertEqual(dict["double"] as! Double, decrypted["double"] as! Double)
        XCTAssertEqual(dict["true"] as! Bool, decrypted["true"] as! Bool)
        XCTAssertEqual(dict["false"] as! Bool, decrypted["false"] as! Bool)
        let actualArray = decrypted["array"] as! [Any]
        XCTAssertEqual(array[0] as! String, actualArray[0] as! String)
        XCTAssertEqual(array[1] as! Int, actualArray[1] as! Int)
        XCTAssertEqual(array[2] as! Double, actualArray[2] as! Double)
        XCTAssertEqual(array[3] as! Bool, actualArray[3] as! Bool)
        XCTAssertEqual(array[4] as! Bool, actualArray[4] as! Bool)
    }
    
    private func createClientSideToken(data: [String: Any]) async throws -> String {
        let credentials = "\(appId):\(apiKey)".data(using: .utf8)!.base64EncodedString()
        var request = URLRequest(url: URL(string: "https://api.evervault.com/client-side-tokens")!)
        request.httpMethod = "POST"
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = [
            "action": "api:decrypt",
            "payload": data
        ] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        let (responseData, _) = try await URLSession.shared.data(for: request)
        let dict = try (JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any])!
        return dict["token"] as! String
    }
}
