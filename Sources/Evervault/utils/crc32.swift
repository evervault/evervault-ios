import Foundation

private let crcTable: [UInt32] = {
    var table = [UInt32](repeating: 0, count: 256)
    for i in 0..<256 {
        var c: UInt32 = UInt32(i)
        for _ in 0..<8 {
            if c & 1 != 0 {
                c = 0xedb88320 ^ (c >> 1)
            } else {
                c = c >> 1
            }
        }
        table[i] = c
    }
    return table
}()

internal func crc32(buffer: Data) -> UInt32 {
    var crc: UInt32 = 0xffffffff
    let len = buffer.count

    buffer.withUnsafeBytes { bufferPointer in
        let bufferAddress = bufferPointer.baseAddress?.assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: bufferAddress, count: len)

        for i in 0..<len {
            crc = crcTable[Int((crc ^ UInt32(buffer[i])) & 0xff)] ^ (crc >> 8)
        }
    }

    return crc ^ 0xffffffff
}
