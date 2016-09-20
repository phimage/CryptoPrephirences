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
preferences["aKey", .cipher(cipher)] = "myValueToEncrypt"
```
It's build on top [Prephirences](https://github.com/phimage/Prephirences) and [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)

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

#### Store any NSCoding object compliant
You can store one preference using
```swift
var preferences = UserDefaults.standard
preferences["aKey", .cipher(cipher)] = value
preferences.set(value, forKey: "aKey", withCipher: cipher)
```
#### Get the decrypted value
```swift
let value = preferences[key, .cipher(cipher)]
let value = preferences.object(forKey: key, withCipher: cipher)
```
### Encrypted Plist file
Using this method key and values will be encrypted.

You can read and write your preferences to an encrypted file using :

```swift
try anyPreferences.saveTo(filePath: "/path/to/file", withCipher:cipher)

try mutablePreferences.loadFrom(filePath: "/path/to/file", withCipher: cipher)
```
You can also initialize a `DictionaryPreferences` with `cipher`
```swift
let pref = try DictionaryPreferences(filePath: filePath, withCipher: cipher)
```

### Encrypted all values
You can use the `CryptoPrephirences`, which work as a proxy of another `Prephirences` and encrypt/decrypt using the given `cipher`

```swift
var cryptoPreferences = MutableCryptoPrephirences(preferences: mutablePreferences, cipher: cipher)
// or for read-only CryptoPrephirences(preferences: anyPreferences, cipher: cipher)
```
