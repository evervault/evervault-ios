# evervault-ios

## 1.1.3

### Patch Changes

- 4649d8f: Fix invalid package checksum

## 1.1.2

### Patch Changes

- 749510b: bumping attestation bindings version

## 1.1.1

### Patch Changes

- db5cba7: Fix linker issue

## 1.1.0

### Minor Changes

- abbae3f: Add privacy info to SDK and update attestation bindings

## 1.0.0

### Major Changes

- ec4a9c8: Remove deprecated old Cage Attestation URLSessions.
- 96988f9: Note: This release is a breaking change from the previous version of the SDK. Please read the following carefully.

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

### Patch Changes

- 9590952: Bugfix numbers to include Obj-c numbers

## 0.3.0

### Minor Changes

- 1c62aa1: Add the EvervaultEnclaves package with a function to create an attestation session for requests to an Evervault Enclave.

## 0.2.0

### Minor Changes

- 8f87a0a: Allow partial set of PCRs to be specified for Cage attestation. Make PCR strings optional.

## 0.1.0

### Minor Changes

- 8afe512: Cages attestation: Add the option to provide callback instead of static PCRs to allow automatic refresh of PCRs without the need to restart a client

### Patch Changes

- a8baed9: Enable changeset to maintain changelog
