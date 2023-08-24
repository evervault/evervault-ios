import Foundation

internal actor HttpDecrypter {

    let url: URL

    init(url: URL) {
        self.url = url
    }

    func decrypt(token: String, data: Any) async throws -> Any {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if data is String {
            request.httpBody = "\"\(data)\"".data(using: .utf8)
        } else {
            request.httpBody = try? JSONSerialization.data(withJSONObject: data)
        }
        let (responseData, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw EvervaultError.serverError
        }
        
        return try decodeJSONValue(data: responseData)
    }
    
    func decodeJSONValue(data: Data) throws -> Any {
        let decoder = JSONDecoder()
        
        if let value = try? decoder.decode(String.self, from: data) {
            return value
        } else if let value = try? decoder.decode(Int.self, from: data) {
            return value
        } else if let value = try? decoder.decode(Double.self, from: data) {
            return value
        } else if let value = try? decoder.decode(Bool.self, from: data) {
            return value
        } else {
            return try JSONSerialization.jsonObject(with: data, options: [])
        }
    }

}
