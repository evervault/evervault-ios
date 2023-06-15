import XCTest

@testable import EvervaultCore

class R1StdEncryptionFormatterTest: XCTestCase {

    let formatter = R1StdEncryptionFormatter(evVersion: "NOC", isDebug: false)
    let everVaultVersionToUse = Data("NOC".utf8).base64EncodedString()

    func testFormattingEncryptedDataMustReturnDataInCorrectFormat() {
        let formattingParameters: [(expectedResult: String, dataType: String, iv: String, publicKey: String, payLoad: String)] = [
            ("ev:\(everVaultVersionToUse):IV:PK:PL:$", "string", "IV", "PK", "PL"),
            ("ev:\(everVaultVersionToUse):boolean:IV:PK:PL:$", "boolean", "IV", "PK", "PL"),
            ("ev:\(everVaultVersionToUse):number:IV:PK:PL:$", "number", "IV", "PK", "PL"),
            ("ev:\(everVaultVersionToUse):IV:PK:PL:$", "string", "IV====", "PK==", "PL===="),
            ("ev:\(everVaultVersionToUse):boolean:IV:PK:PL:$", "boolean", "IV==", "PK=", "PL"),
            ("ev:\(everVaultVersionToUse):number:IV:PK:PL:$", "number", "IV==", "PK=", "PL==========")
        ]

        formattingParameters.forEach { param in
            XCTAssertEqual(formatter.formatEncryptedData(datatype: param.dataType, keyIv: param.iv, publicKey: param.publicKey, encryptedData: param.payLoad), param.expectedResult)
        }
    }
}
