import Foundation

internal actor HttpDecrypter {

    let url: URL

    init(url: URL) {
        self.url = url
    }

    func decryptDictionary(token: String, data: Any) async throws -> [String: Any] {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)
        let (responseData, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw EvervaultError.serverError
        }
        
        return try (JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any])!
    }

}
