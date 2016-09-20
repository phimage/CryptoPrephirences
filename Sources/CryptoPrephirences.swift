//
//  CryptoPrephirences.swift
//  CryptoPrephirences
/*
The MIT License (MIT)

Copyright (c) 2015-2016 Eric Marchand (phimage)

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

open class CryptoPrephirences {

    open let preferences: PreferencesType
    open let cipher: Cipher
    open var returnNotDecrytable = false

    public init(preferences: PreferencesType, cipher: Cipher) {
        self.preferences = preferences
        self.cipher = cipher
    }

}

extension CryptoPrephirences: PreferencesType {

    public func object(forKey key: String) -> Any? {
        guard let value = self.preferences.object(forKey: key) else {
            return nil
        }
        guard let data = value as? Data, let decrypted = try? data.decrypt(cipher: cipher), let object = Prephirences.unarchive(decrypted) else {
            return self.returnNotDecrytable ? value : nil
        }
        return object
    }

    public func dictionary() -> [String : Any] {
        var result = [String : Any]()
        
        for (key, value) in self.preferences.dictionary() {
            
            guard let data = value as? Data, let decrypted = try? data.decrypt(cipher: cipher), let object = Prephirences.unarchive(decrypted) else {
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

open class MutableCryptoPrephirences: CryptoPrephirences {

    public var mutablePreferences: MutablePreferencesType {
        return self.preferences as! MutablePreferencesType
    }

    public init(preferences: MutablePreferencesType, cipher: Cipher) {
        super.init(preferences: preferences, cipher: cipher)
    }

}

extension MutableCryptoPrephirences: MutablePreferencesType {

    public func set(_ value: Any?, forKey key: String) {
        guard let object = value else {
            self.removeObject(forKey: key)
            return
        }
        let data = Prephirences.archive(object)
        if let encrypted = try? data.encrypt(cipher: cipher) {
            self.mutablePreferences.set(encrypted, forKey: key)
        }
    }

    public func removeObject(forKey key: String) {
        self.mutablePreferences.removeObject(forKey: key)
    }

}

public extension MutablePreferencesType {
    
    public func set(_ value: Any?, forKey key: String, withCipher cipher: Cipher) {
        guard let object = value else {
            self.removeObject(forKey: key)
            return
        }
        let data = Prephirences.archive(object)
        if let encrypted = try? data.encrypt(cipher: cipher) {
            self.set(encrypted, forKey: key)
        }
    }

}

extension CryptoPrephirences {
    
    public func object(forKey key: String, withCipher cipher: Cipher) -> Any? {
        guard let value = self.preferences.object(forKey: key) else {
            return nil
        }
        guard let data = value as? Data, let decrypted = try? data.decrypt(cipher: cipher), let object = Prephirences.unarchive(decrypted) else {
            return self.returnNotDecrytable ? value : nil
        }
        return object
    }
}

