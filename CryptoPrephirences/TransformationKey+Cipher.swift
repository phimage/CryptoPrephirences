//
//  CryptoPreference.swift
//  CryptoPrephirences
/*
The MIT License (MIT)

Copyright (c) 2015 Eric Marchand (phimage)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation
import Prephirences
import CryptoSwift

public extension TransformationKey {

    public static func Cipher(cipher: CryptoSwift.Cipher) -> TransformationKey {
        return TransformationKey.ClosureTuple((
            transform: { obj in
                guard let object = obj else {
                    return nil
                }
                let data = Prephirences.archive(object)
                if let encrypted = try? data.encrypt(cipher) {
                    return encrypted
                }
                return nil // rethrows not supported in subscript yet
            }, revert: { obj in
                guard let data = obj as? NSData else {
                    return obj
                }
                if let decrypted = try? data.decrypt(cipher) {
                    return Prephirences.unarchive(decrypted)
                }
                return nil // rethrows not supported in subscript yet
            }
        ))
    }

}