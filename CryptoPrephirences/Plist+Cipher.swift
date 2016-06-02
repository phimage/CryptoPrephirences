//
//  DictionaryPreferences+Cipher.swift
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

public enum CryptoPrephirencesError: ErrorType {
    case FailedToDeserializePropertyList
}

public extension Plist {

    public static func readFrom(filePath: String, cipher: CryptoSwift.CipherProtocol, options opt: NSPropertyListReadOptions = .MutableContainersAndLeaves, format: UnsafeMutablePointer<NSPropertyListFormat> = nil, readOptionsMask: NSDataReadingOptions = []) throws -> Dictionary<String,AnyObject>  {
        let encrypted = try NSData(contentsOfFile: filePath, options: readOptionsMask)
        let decrypted = try encrypted.decrypt(cipher)
        
        guard let dictionary = try NSPropertyListSerialization.propertyListWithData(decrypted,
            options: opt,  format: format) as? Dictionary<String,AnyObject> else {
                throw CryptoPrephirencesError.FailedToDeserializePropertyList
        }
        return dictionary
    }

    public static func writeTo(filePath: String, cipher: CryptoSwift.CipherProtocol, dictionary: Dictionary<String,AnyObject>, format: NSPropertyListFormat = NSPropertyListFormat.XMLFormat_v1_0, options opt: NSPropertyListWriteOptions = 0, writeOptionMask: NSDataWritingOptions = .AtomicWrite) throws {
        
        let decrypted = try NSPropertyListSerialization.dataWithPropertyList(dictionary, format: format, options: opt)

        let encrypted = try decrypted.encrypt(cipher)
        try encrypted.writeToFile(filePath, options: writeOptionMask)
    }
}

public extension DictionaryPreferences {

    public convenience init(filePath: String, cipher: CryptoSwift.CipherProtocol) throws {
        let dictionary = try Plist.readFrom(filePath, cipher: cipher)
        self.init(dictionary: dictionary)
    }
    
}

extension PreferencesType {
    
    public func saveToEncryptedFile(filePath: String, cipher: CryptoSwift.CipherProtocol) throws {
        try Plist.writeTo(filePath, cipher: cipher, dictionary: self.dictionary())
    }
 
}

extension MutablePreferencesType {
    
    public func loadFromEncryptedFile(filePath: String, cipher: CryptoSwift.CipherProtocol) throws {
        let dictionary = try Plist.readFrom(filePath, cipher: cipher)
        self.setObjectsForKeysWithDictionary(dictionary)
    }

}
