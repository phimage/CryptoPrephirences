//
//  DictionaryPreferences+Cipher.swift
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

public enum CryptoPrephirencesError: Error {
    case failedToDeserializePropertyList
}

public extension Plist {

    public static func readFrom(_ filePath: String, withCipher cipher: CryptoSwift.Cipher, options opt: PropertyListSerialization.ReadOptions = .mutableContainersAndLeaves, format: UnsafeMutablePointer<PropertyListSerialization.PropertyListFormat>? = nil, readOptionsMask: NSData.ReadingOptions = []) throws -> Dictionary<String,Any>  {
        let encrypted = try Data(contentsOf: URL(fileURLWithPath: filePath), options: readOptionsMask)
        let decrypted = try encrypted.decrypt(cipher: cipher)
        
        guard let dictionary = try PropertyListSerialization.propertyList(from: decrypted,
            options: opt,  format: format) as? Dictionary<String,AnyObject> else {
                throw CryptoPrephirencesError.failedToDeserializePropertyList
        }
        return dictionary
    }

    public static func writeTo(_ filePath: String, withCipher cipher: CryptoSwift.Cipher, dictionary: Dictionary<String,Any>, format: PropertyListSerialization.PropertyListFormat = PropertyListSerialization.PropertyListFormat.xml, options opt: PropertyListSerialization.WriteOptions = 0, writeOptionMask: NSData.WritingOptions = .atomicWrite) throws {
        
        let decrypted = try PropertyListSerialization.data(fromPropertyList: dictionary, format: format, options: opt)

        let encrypted = try decrypted.encrypt(cipher: cipher)
        try encrypted.write(to: URL(fileURLWithPath: filePath), options: writeOptionMask)
    }
}

public extension DictionaryPreferences {

    public convenience init(filePath: String, withCipher cipher: CryptoSwift.Cipher) throws {
        let dictionary = try Plist.readFrom(filePath, withCipher: cipher)
        self.init(dictionary: dictionary)
    }
    
}

extension PreferencesType {
    
    public func saveTo(filePath: String, withCipher cipher: CryptoSwift.Cipher) throws {
        try Plist.writeTo(filePath, withCipher: cipher, dictionary: self.dictionary())
    }
 
}

extension MutablePreferencesType {
    
    public func loadFrom(filePath: String, withCipher cipher: CryptoSwift.Cipher) throws {
        let dictionary = try Plist.readFrom(filePath, withCipher: cipher)
        self.set(dictionary: dictionary)
    }

}
