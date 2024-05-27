import XCTest

@testable import EvervaultCore

class R1StdEncryptionFormatterTest: XCTestCase {

    let formatter = R1StdEncryptionFormatter(evVersion: "QkTC", publicKey: Data(base64Encoded: "UEs=".data(using: .utf8)!)!, isDebug: false)
    let everVaultVersionToUse = Data("QkTC".utf8).base64EncodedString()

    func testFormattingEncryptedDataMustReturnDataInCorrectFormat() {

        let formattingParameters: [(expectedResult: String, dataType: DataType, iv: String, payLoad: String)] = [
            ("ev:\(everVaultVersionToUse):SVY:UEs:PL:$", .string, "IV", "PL"),
            ("ev:\(everVaultVersionToUse):boolean:SVY:UEs:PL:$", .boolean, "IV", "PL"),
            ("ev:\(everVaultVersionToUse):number:SVY:UEs:PL:$", .number, "IV", "PL"),
            ("ev:\(everVaultVersionToUse):SVY9PT09:UEs:PL:$", .string, "IV====", "PL===="),
            ("ev:\(everVaultVersionToUse):boolean:SVY9PQ:UEs:PL:$", .boolean, "IV==", "PL"),
            ("ev:\(everVaultVersionToUse):number:SVY9PQ:UEs:PL:$", .number, "IV==", "PL==========")
        ]

        formattingParameters.forEach { param in
            XCTAssertEqual(formatter.formatEncryptedData(dataType: param.dataType, keyIv: param.iv.data(using: .utf8)!, encryptedData: param.payLoad), param.expectedResult)
        }
    }
}
