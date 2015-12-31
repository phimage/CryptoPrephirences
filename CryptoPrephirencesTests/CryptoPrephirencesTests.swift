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
        var prephirences = NSUserDefaults.standardUserDefaults()
        
        let key = "key"
        let value = NSUUID()
        
        prephirences[key, .Cipher(cipher)] = value
        
        let get = prephirences[key, .Cipher(cipher)]
        if let uuid = get as? NSUUID {
            XCTAssertEqual(uuid, value)
        } else {
            XCTFail("failed to retrieve good object type: \(get)")
        }

        // check stored type
        guard let data = prephirences[key] as? NSData else {
            XCTFail("object is not data")
            return
        }
        // check if really encyrpted
        let unarchived = Prephirences.unarchive(data)
        XCTAssertNil(unarchived)
    }
    
    func testGetNil() {
        var prephirences = NSUserDefaults.standardUserDefaults()
        let key = "\(NSUUID())"
        XCTAssertNil(prephirences[key, .Cipher(cipher)])
    }
    
    func testSetNil() {
        var prephirences = NSUserDefaults.standardUserDefaults()
        let key = "\(NSUUID())"
        prephirences[key, .Cipher(cipher)] = nil

        XCTAssertNil(prephirences[key, .Cipher(cipher)])
    }
    
    func testDico() {
        let temp = NSTemporaryDirectory()
        let filePath = "\(temp)/cryptotest"
        
        let dicoPref: MutableDictionaryPreferences = ["key": "value", "key2": "value2"]

        
        do {
            try dicoPref.saveToEncryptedFile(filePath, cipher: cipher)
        } catch let e {
            XCTFail("failed \(e)")
        }
        
        let newDicoPref: MutableDictionaryPreferences = [:]
        do {
            try newDicoPref.loadFromEncryptedFile(filePath, cipher: cipher)
            XCTAssertEqualPrepherences(newDicoPref, dicoPref)
        } catch let e {
            XCTFail("failed \(e)")
        }
        
        do {
            let initDicoPref = try DictionaryPreferences(filePath: filePath, cipher: cipher)
            XCTAssertEqualPrepherences(initDicoPref, dicoPref)
        } catch let e {
            XCTFail("failed \(e)")
        }
    }

    func XCTAssertEqualPrepherences(left: PreferencesType,_ right: PreferencesType) {
        let ld = left.dictionary()
        let rd = right.dictionary()
        XCTAssertEqual(Array(ld.keys), Array(rd.keys), "not same keys")
        
        for (key, lvalue) in ld {
            guard let rvalue = rd[key] else {
                XCTFail("not defined value for \(key)")
                return
            }
            if let rve = rvalue as? NSObject, lve = lvalue as? NSObject {
                XCTAssertEqual(rve, lve)
            }
            else {
                XCTFail("cannot test with not Equable object")
            }
        }
        
    }
}
