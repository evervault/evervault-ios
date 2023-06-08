import Foundation

internal actor HttpKeysLoader {

    private var activeTask: Task<CageKey, Error>?
    private var cachedKey: CageKey?

    let url: URL

    init(url: URL) {
        self.url = url
    }

    func loadKeys() async throws -> CageKey {
        if let activeTask {
            return try await activeTask.value
        }

        let task = Task<CageKey, Error> {
            if let cachedKey {
                activeTask = nil
                return cachedKey
            }

            do {
                let result = try await fetchKeys()
                activeTask = nil
                return result
            } catch {
                activeTask = nil
                throw error
            }
        }

        activeTask = task

        return try await task.value
    }

    private func fetchKeys() async throws -> CageKey {
        let urlSession = URLSession.shared
        let (data, response) = try await urlSession.data(from: url)
        let cageKeyBody = try JSONDecoder().decode(CageKeyBody.self, from: data)
        return CageKey(
            ecdhP256Key: cageKeyBody.ecdhP256Key,
            ecdhP256KeyUncompressed: cageKeyBody.ecdhP256KeyUncompressed,
            isDebugMode: (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "X-Evervault-Inputs-Debug-Mode") == "true"
        )
    }
}

fileprivate struct CageKeyBody: Decodable {
    let ecdhP256Key: String
    let ecdhP256KeyUncompressed: String
}
