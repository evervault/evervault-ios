import Foundation
import EvervaultCore

public struct StoredPcrProvider {
    public var pcrs: [PCRs]
    public var provider: (@escaping ([PCRs]?, Error?) -> Void) -> Void

    public init(pcrs: [PCRs], provider: @escaping (@escaping ([PCRs]?, Error?) -> Void) -> Void) {
        self.pcrs = pcrs
        self.provider = provider
    }
}
class PcrManager {
    
    static let shared = PcrManager()
    private var store: [String: StoredPcrProvider] = [:]
    private let backgroundQueue = DispatchQueue(label: "com.evervault.pcrManagerQueue")
    
    private init() {
        print("Evervault: Started polling PCR providers every \(refreshInterval) seconds")
        scheduleManagerUpdate()
    }
    
    private let refreshInterval: TimeInterval = {
        if let intervalString = ProcessInfo.processInfo.environment["EV_PCR_PROVIDER_POLL_INTERVAL"],
           let interval = TimeInterval(intervalString) {
            return interval
        } else {
            // Five minutes
            return 300
        }
    }()
    
    //Pull in all new PCRs with stored provider and then schedule it after refreshInterval
    private func updateStore() {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            self.fetchPcrsFromAllStoredProviders()
            self.scheduleManagerUpdate()
        }
    }
    
    private func scheduleManagerUpdate() {
        backgroundQueue.asyncAfter(deadline: .now() + refreshInterval) { [weak self] in
            self?.updateStore()
        }
    }
    
    private func fetchPcrsFromAllStoredProviders() {
        for identifier in self.store.keys {
            runProvider(identifier: identifier) { _, error in
                if let error = error {
                    print("Evervault: Failed to update PCRs for \(identifier): \(error.localizedDescription)")
                } 
            }
        }
    }
    
    private func runProvider(identifier: String, completion: @escaping (StoredPcrProvider?, Error?) -> Void) {
        guard let storedProvider = self.store[identifier] else {
            completion(nil, NSError(domain: "Evervault", code: 404, userInfo: [NSLocalizedDescriptionKey: "No provider found for \(identifier)."]))
            return
        }

        attemptProviderWithRetries(identifier: identifier, storedProvider: storedProvider, retries: 3, delay: 1, completion: completion)
    }

    private func attemptProviderWithRetries(identifier: String, storedProvider: StoredPcrProvider, retries: Int, delay: TimeInterval, completion: @escaping (StoredPcrProvider?, Error?) -> Void) {
        
        storedProvider.provider { [weak self] newPCRs, error in
            guard let self = self else { return }

            if let newPCRs = newPCRs {
                let updatedProvider = StoredPcrProvider(pcrs: newPCRs, provider: storedProvider.provider)
                self.store[identifier] = updatedProvider
                print("Evervault: Successfully updated PCRs for \(identifier) from provider.")
                completion(updatedProvider, nil)
            } else if retries > 0 {
                // If there's an error and we still have retries left, try again after the specified delay.
                print("Evervault: Error fetching PCRs for \(identifier): \(String(describing: error)). Retrying in \(delay) seconds...")
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                    self.attemptProviderWithRetries(identifier: identifier, storedProvider: storedProvider, retries: retries - 1, delay: delay * 2, completion: completion)
                }
            } else {
                print("Evervault: Exhausted retries for \(identifier). Unable to fetch PCRs.")
                completion(nil, error ?? NSError(domain: "Evervault", code: 500, userInfo: [NSLocalizedDescriptionKey: "Exhausted retries for \(identifier)."]))
            }
        }
    }
    
    private func registerPcrProviderAndFetch(identifier: String, provider: @escaping (@escaping ([PCRs]?, Error?) -> Void) -> Void, completion: @escaping (StoredPcrProvider?, Error?) -> Void) {
            let storedProvider = StoredPcrProvider(pcrs: [], provider: provider)
            self.store[identifier] = storedProvider
            runProvider(identifier: identifier, completion: completion)
    }

    func fetchPcrs(identifier: String, provider: @escaping (@escaping ([PCRs]?, Error?) -> Void) -> Void, completion: @escaping ([PCRs]?, Error?) -> Void) {
        if let storedPcrProvider = self.store[identifier] {
            // If the provider is already stored, use it to fetch PCRs
            storedPcrProvider.provider(completion)
        } else {
            // If the provider isn't stored yet, register and fetch
            registerPcrProviderAndFetch(identifier: identifier, provider: provider) { storedProvider, error in
                if let storedProvider = storedProvider {
                    completion(storedProvider.pcrs, nil)
                } else if let error = error {
                    completion(nil, error)
                }
            }
        }
    }
}
