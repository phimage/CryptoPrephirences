//
//  CryptoPrephirencesTests.swift
//  CryptoPrephirencesTests
//
//  Created by phimage on 31/12/15.
//  Copyright © 2015 phimage. All rights reserved.
//

import XCTest
@testable import CryptoPrephirences
import Prephirences
import CryptoSwift



class CryptoPrephirencesTests: XCTestCase {
    var cipher: Cipher!

    override func setUp() {
        super.setUp()
        
        guard let aes = try? AES(key: "secret0key000000", iv:"0123456789012345", blockMode: .CBC) else {
            XCTFail("failed to create cipher")
            return
        }
        cipher = aes
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSetGet() {
        var prephirences = UserDefaults.standard
        
        let key = "key"
        let value = UUID()
        
        prephirences[key, .cipher(cipher)] = value
        
        let get = prephirences[key, .cipher(cipher)]
        if let uuid = get as? UUID {
            XCTAssertEqual(uuid, value)
        } else {
            XCTFail("failed to retrieve good object type: \(get)")
        }

        // check stored type
        guard let data = prephirences[key] as? Data else {
            XCTFail("object is not data")
            return
        }
        // check if really encyrpted
        let unarchived = Prephirences.unarchive(data)
        XCTAssertNil(unarchived)
    }
    
    func testGetNil() {
        var prephirences = UserDefaults.standard
        let key = "\(UUID())"
        XCTAssertNil(prephirences[key, .cipher(cipher)])
    }
    
    func testSetNil() {
        var prephirences = UserDefaults.standard
        let key = "\(UUID())"
        prephirences[key, .cipher(cipher)] = nil

        XCTAssertNil(prephirences[key, .cipher(cipher)])
    }
    
    func testDico() {
        let temp = NSTemporaryDirectory()
        let filePath = "\(temp)/cryptotest"
        
        let dicoPref: MutableDictionaryPreferences = ["key": "value", "key2": "value2"]

        
        do {
            try dicoPref.saveTo(filePath: filePath, withCipher: cipher)
        } catch let e {
            XCTFail("failed \(e)")
        }
        
        let newDicoPref: MutableDictionaryPreferences = [:]
        do {
            try newDicoPref.loadFrom(filePath: filePath, withCipher: cipher)
            XCTAssertEqualPreferences(newDicoPref, dicoPref)
        } catch let e {
            XCTFail("failed \(e)")
        }
        
        do {
            let initDicoPref = try DictionaryPreferences(filePath: filePath, withCipher: cipher)
            XCTAssertEqualPreferences(initDicoPref, dicoPref)
        } catch let e {
            XCTFail("failed \(e)")
        }
    }
    
    func testCryptoPrephirences() {
        let dicoPref: MutableDictionaryPreferences = [:]
        var cryptoPreferences = MutableCryptoPrephirences(preferences: dicoPref, cipher: cipher)
        
        let tmp: MutableDictionaryPreferences = ["key": "value", "key2": "value2"]
        cryptoPreferences.set(dictionary: tmp.dictionary())
        
        XCTAssertEqualPreferences(cryptoPreferences, tmp)

        // modify
        cryptoPreferences["key3"] = "value3"
        XCTAssertEqual("value3", cryptoPreferences["key3"] as? String ?? "dummy")

        // check all data encrypted into original preferences
        for (key, value) in dicoPref.dictionary() {
            guard let _ = value as? NSData else {
                XCTFail("not encrypted value for \(key)")
                return
            }
        }
    }

    func XCTAssertEqualPreferences(_ left: PreferencesType,_ right: PreferencesType) {
        let ld = left.dictionary()
        let rd = right.dictionary()
        XCTAssertEqual(Array(ld.keys), Array(rd.keys), "not same keys")
        
        for (key, lvalue) in ld {
            guard let rvalue = rd[key] else {
                XCTFail("not defined value for \(key)")
                return
            }
            if let rve = rvalue as? NSObject, let lve = lvalue as? NSObject {
                XCTAssertEqual(rve, lve)
            }
            else {
                XCTFail("cannot test with not Equable object")
            }
        }
    }
}
