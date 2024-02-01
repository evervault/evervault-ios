import Foundation

class AttestationDocumentHttpHelper {
    
    enum AttestationError: LocalizedError {
        case invalidURL
        case requestError(Error)
        case invalidHTTPResponse
        case invalidJSONResponse
        case noData
        case missingAttestationDoc
        case httpError(statusCode: Int)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid Enclave Attestation URL."
            case .requestError(let error):
                return "Request error: \(error.localizedDescription)"
            case .invalidHTTPResponse:
                return "Invalid HTTP response."
            case .invalidJSONResponse:
                return "Invalid JSON response."
            case .noData:
                return "No data received from the server."
            case .missingAttestationDoc:
                return "Attestation document not found in JSON."
            case .httpError(let statusCode):
                return "HTTP Error: \(statusCode)"
            }
        }
    }
    
    static let shared = AttestationDocumentHttpHelper()
    
    private init() {}
    
    private let domain: String = {
        if let domainFromEnv = ProcessInfo.processInfo.environment["EV_DOMAIN"], !domainFromEnv.isEmpty {
            return domainFromEnv
        } else {
            return "evervault.com"
        }
    }()
    
    func buildUrl(host: String, identifier: String) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(identifier).\(host).\(domain)"
        components.path = "/.well-known/attestation"
        
        guard let url = components.url else {
            throw AttestationError.invalidURL
        }
        
        return url
    }

    func fetchAttestationDoc(host: String, identifier: String, completion: @escaping (Result<String, AttestationError>) -> Void) {
        do {
            let url = try buildUrl(host: host, identifier: identifier)
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 120.0
            configuration.timeoutIntervalForResource = 120.0
            let session = URLSession(configuration: configuration)
            
            let task = session.dataTask(with: url) { data, response, error in
                
                if let error = error {
                    print("Evervault: Request error for attestation document of \(identifier): \(error.localizedDescription)")
                    completion(.failure(.requestError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Evervault: Invalid HTTP response for attestation document of \(identifier).")
                    completion(.failure(.invalidHTTPResponse))
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    print("Evervault: HTTP error fetching attestation document for \(identifier). Status code: \(httpResponse.statusCode)")
                    completion(.failure(.httpError(statusCode: httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    print("Evervault: No data received fetching attestation document for \(identifier).")
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let attestationDoc = jsonObject["attestation_doc"] as? String {
                        completion(.success(attestationDoc))
                    } else {
                        print("Evervault: Missing valid attestation doc structure in response for \(identifier).")
                        completion(.failure(.missingAttestationDoc))
                    }
                } catch {
                    print("Evervault: Invalid JSON response fetching attestation document for \(identifier). Error: \(error.localizedDescription)")
                    completion(.failure(.invalidJSONResponse))
                }
            }
            
            task.resume()
            
        } catch let error as AttestationError {
            print("Evervault: Attestation error for \(identifier): \(error.localizedDescription)")
            completion(.failure(error))
        } catch {
            completion(.failure(.invalidURL))
        }
    }
}
