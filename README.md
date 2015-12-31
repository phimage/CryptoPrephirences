# CryptoPrephirences

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-ios_osx_tvos-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift)
[![Issues](https://img.shields.io/github/issues/phimage/CryptoPrephirences.svg?style=flat
           )](https://github.com/phimage/CryptoPrephirences/issues)
[![Cocoapod](http://img.shields.io/cocoapods/v/CryptoPrephirences.svg?style=flat)](http://cocoadocs.org/docsets/Prephirences/)
[![Join the chat at https://gitter.im/phimage/Prephirences](https://img.shields.io/badge/GITTER-join%20chat-00D06F.svg)](https://gitter.im/phimage/Prephirences?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[<img align="left" src="logo.png" hspace="20">](#logo) CryptoPrephirences allows you to protect your preferences against unauthorized access and modification.

```swift
prephirences["aKey", .Cipher(cipher)] = "myValueToEncrypt"
```
It's build on top Prephirences and CryptoSwift

## Installation

### Support CocoaPods

* Podfile

```
use_frameworks!

pod "CryptoPrephirences"
```

## Usage

 To Encrypt and decrypt data, you will need a `CryptoSwift.Cipher`, see CryptoSwift documentation to create one.

### Encrypt/Decryp each key/value independently
You can store one preference using

```swift
var prephirences = NSUserDefaults.standardUserDefaults()
```
#### Store any NSCoding object compliant
```swift
prephirences["aKey", .Cipher(cipher)] = value
```
#### Get the decrypted value
```swift
let value = prephirences[key, .Cipher(cipher)]
```

### Encrypted Plist file
Using this method key and values will be encrypted.

You can read and write your preferences to an encrypted file using :

```
try anyPrephirences.saveToEncryptedFile(filePath: "/path/to/file", cipher:cipher)

try mutablePrephirences.loadFromEncryptedFile(filePath: "/path/to/file", cipher: cipher)
```
You can also initialize a `DictionaryPreferences`
```swift
let pref = try DictionaryPreferences(filePath: filePath, cipher: cipher)
```

### Encrypted all values
WIP
