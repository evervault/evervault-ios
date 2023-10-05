import Foundation

class AttestationDocumentHttpHelper {
    
    enum AttestationError: LocalizedError {
        case invalidURL
        case requestError(Error)
        case invalidHTTPResponse
        case invalidJSONResponse
        case noData
        case missingAttestationDoc
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid Cage Attestation URL."
            case .requestError(let error): return "Request error: \(error.localizedDescription)"
            case .invalidHTTPResponse: return "Invalid HTTP response."
            case .invalidJSONResponse: return "Invalid JSON response."
            case .noData: return "No data received from the server."
            case .missingAttestationDoc: return "Attestation document not found in JSON."
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
    
    func buildCageUrl(cageIdentifier: String) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(cageIdentifier).cage.\(domain)"
        components.path = "/.well-known/attestation"
        
        guard let url = components.url else {
            throw AttestationError.invalidURL
        }
        
        return url
    }
    
    func fetchCageAttestationDoc(cageIdentifier: String, completion: @escaping (Result<String, AttestationError>) -> Void) {
        do {
            let url = try buildCageUrl(cageIdentifier: cageIdentifier)
            
            let session = URLSession.shared
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if let error = error {
                    completion(.failure(.requestError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(.invalidHTTPResponse))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let attestationDoc = jsonObject["attestation_doc"] as? String {
                        completion(.success(attestationDoc))
                    } else {
                        completion(.failure(.missingAttestationDoc))
                    }
                } catch {
                    completion(.failure(.invalidJSONResponse))
                }
            }
            
            task.resume()
            
        } catch let error as AttestationError {
            completion(.failure(error))
        } catch {
            completion(.failure(.invalidURL))
        }
    }
}
