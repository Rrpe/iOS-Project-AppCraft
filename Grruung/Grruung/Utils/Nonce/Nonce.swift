//
//  Nonce.swift
//  Grruung
//
//  Created by mwpark on 6/9/25.
//

import Foundation
import CryptoKit

// 애플 로그인시 Nonce를 사용하여 보안하는 것이 권장되므로 추가함.
// 랜덤 문자열 생성
func randomNonceString(length: Int = 32) -> String {
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms = (0..<16).map { _ in UInt8.random(in: 0...255) }
        for random in randoms {
            if remainingLength == 0 { break }
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }

    return result
}

// SHA256 해시
func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
}
