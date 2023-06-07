//
//  File.swift
//  
//
//  Created by Lammert Westerhoff on 6/6/23.
//

import Foundation

/**
 * To compress - record the sign of the `y` point
 * then remove the `y` point and encode the recorded
 * sign in the first bit
 * */
internal func ecPointCompress(ecdhRawPublicKey: Data) -> Data {
    let u8full = Array(ecdhRawPublicKey)
    let len = u8full.count
    var u8 = Array(u8full.prefix((1 + len) >> 1)) // drop `y`
    u8[0] = 0x2 | (u8full[len - 1] & 0x01) // encode sign of `y` in first bit
    return Data(u8)
}
