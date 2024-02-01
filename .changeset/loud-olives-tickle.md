---
"evervault-ios": major
---

Note: This release is a breaking change from the previous version of the SDK. Please read the following carefully.

Before updating to this version of the SDK, you should make sure your Cage has been migrated to an Enclave. You can do this by following the instructions in the [Evervault Docs](https://docs.evervault.com/guides/cages-to-enclaves-migration).

All Enclave methods and classes are now moved into the EvervaultEnclaves Package. This includes the new attestation mechanism and has marked the old Cage methods as deprecated. The EvervaultCages package has been removed.

If you are using the old CageAttesationSession methods, you will need to update your code to use the new EnclaveAttestationSession URLSession which can be found in the EvervaultEnclaves package. The new URLSession also takes in a new data struct called EnclaveAttestationData. The URLSession can be initialized with the following code:

```swift
import EvervaultCore
import EvervaultEnclaves

...

let urlSession = await Evervault.enclaveAttestationSession(
    enclaveAttestationData: EnclaveAttestationData(
        enclaveName: enclaveName,
        appUuid: appUuid,
        provider: provider // Provider is optional, a harcoded set of PCRs can be used if not provided
    )
)
```
