//
//  CryptoPrephirences.swift
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

public class CryptoPrephirences {

    public let preferences: PreferencesType
    public let cipher: CipherProtocol
    public var returnNotDecrytable = false

    public init(preferences: PreferencesType, cipher: CipherProtocol) {
        self.preferences = preferences
        self.cipher = cipher
    }

}

extension CryptoPrephirences: PreferencesType {

    public func objectForKey(key: String) -> AnyObject? {
        guard let value = self.preferences.objectForKey(key) else {
            return nil
        }
        guard let data = value as? NSData, decrypted = try? data.decrypt(cipher), object = Prephirences.unarchive(decrypted) else {
            return self.returnNotDecrytable ? value : nil
        }
        return object
    }

    public func dictionary() -> [String : AnyObject] {
        var result = [String : AnyObject]()
        
        for (key, value) in self.preferences.dictionary() {
            
            guard let data = value as? NSData, decrypted = try? data.decrypt(cipher), object = Prephirences.unarchive(decrypted) else {
                if self.returnNotDecrytable {
                    result[key] = value
                }
                continue
            }
            result[key] = object
        }
        
        return result
    }

}

public class MutableCryptoPrephirences: CryptoPrephirences {

    public var mutablePreferences: MutablePreferencesType {
        return self.preferences as! MutablePreferencesType
    }

    public init(preferences: MutablePreferencesType, cipher: CipherProtocol) {
        super.init(preferences: preferences, cipher: cipher)
    }

}

extension MutableCryptoPrephirences: MutablePreferencesType {

    public func setObject(value: AnyObject?, forKey key: String) {
        guard let object = value else {
            self.removeObjectForKey(key)
            return
        }
        let data = Prephirences.archive(object)
        if let encrypted = try? data.encrypt(cipher) {
            self.mutablePreferences.setObject(encrypted, forKey: key)
        }
    }

    public func removeObjectForKey(key: String) {
        self.mutablePreferences.removeObjectForKey(key)
    }

}
