import Foundation

internal enum ASN1 {
    static func encode(_ type: String, _ hexStrings: String...) -> String {
        let str = hexStrings.joined().replacingOccurrences(of: "\\s+", with: "", options: .regularExpression).lowercased()
        let len = str.count / 2
        var lenlen = 0
        var hex = type

        if len != Int(len) {
            fatalError("Invalid hex")
        }

        if len > 127 {
            lenlen += 1
            var lenCopy = len
            while lenCopy > 255 {
                lenlen += 1
                lenCopy = lenCopy >> 8
            }
        }

        if lenlen > 0 {
            hex += numToHex(0x80 + lenlen)
        }

        return hex + numToHex(len) + str
    }

    // The Integer type has some special rules
    static func UINT(_ arguments: String...) -> String {
        var str = arguments.joined()
        let first = Int(str.prefix(2), radix: 16) ?? 0

        // If the first byte is 0x80 or greater, the number is considered negative
        // Therefore we add a '00' prefix if the 0x80 bit is set
        if (0x80 & first) != 0 {
            str = "00" + str
        }

        return ASN1.encode("02", str)
    }

    static func BITSTR(_ arguments: String...) -> String {
        let str = arguments.joined()
        // '00' is a mask of how many bits of the next byte to ignore
        return ASN1.encode("03", "00" + str)
    }

    static func numToHex(_ d: Int) -> String {
        let hexString = String(d, radix: 16)
        if hexString.count % 2 != 0 {
            return "0" + hexString
        }
        return hexString
    }

}
