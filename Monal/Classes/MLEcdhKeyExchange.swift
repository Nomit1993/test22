//
//  MLEcdhKeyExchange.swift
//  monalxmpp
//
//  Created by mohanchandaluri on 13/12/21.
//  Copyright © 2021 Monal.im. All rights reserved.
//

import Foundation
import CommonCrypto
import Security
import UIKit
import SignalProtocolObjC
import CryptoSwift
@objcMembers
public class MLECDHKeyExchange:NSObject{
    let aesGcmBlockLength = 16
    let ivData = Data(bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    var jsonbodystring:NSString?
    var publickeybase64encoded:String = ""
    var publicKeySec, privateKeySec,publicKeySecretreive: SecKey?
    var publicKey, privateKey: SecKey?
    var botpublickey:SecKey?
    let tagPrivate = "myPrivate"
    let tagPublic  = "myPublic"
    let tagSymmetricData = "sessionkey"
    let tagBotPublic = "BOTPUBLICKEY"
    var keySourceStr = ""
    let keyattribute = [
               kSecAttrKeyType as String: kSecAttrKeyTypeEC,
               kSecAttrKeySizeInBits as String : 256
               ] as CFDictionary
          

    var error: Unmanaged<CFError>?
    let attributesECPub: [String:Any] = [
         kSecAttrKeyType as String: kSecAttrKeyTypeEC,
         kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
         kSecAttrKeySizeInBits as String: 256,
         kSecAttrIsPermanent as String: false
     ]

    @objc open func decodekey(PublicString:String){
//        let json = PublicString.data(using: .utf8)!
//        let datasave: Datasave = try! JSONDecoder().decode(Datasave.self, from: json)
        let Receivedpublickey = PublicString
        print(Receivedpublickey)
        let pubKeyECData = Data(base64Encoded: Receivedpublickey, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
        let pubKeyECStriped = pubKeyECData![(pubKeyECData?.count)!-65..<(pubKeyECData?.count)!]
        publicKeySecretreive = SecKeyCreateWithData(pubKeyECStriped as! CFData,attributesECPub as CFDictionary, &error)
        print(publicKeySecretreive)
        self.StoreInKeychain(tag: tagBotPublic, key: publicKeySecretreive!)
        var botpublicKeyretreive: SecKey?
         botpublicKeyretreive = GetKeyTypeInKeyChain(tag: tagBotPublic)
        
        if (botpublicKeyretreive != nil ){
            self.retreivekeys { (keyData, error) in
                if (error != nil) {
                  let key = ""
                }else{
                    let sessionkey = keyData
                }
            }
        }
    }
    
    @objc open func generatePrivatekey() -> Data? {

        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes {
            (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, 32, mutableBytes)
        }
        if result == errSecSuccess {
            
            return keyData
            //keyData.toHexString()
            
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    
    @objc open func generateIV() -> Data? {

        var keyData = Data(count: 12)
        let result = keyData.withUnsafeMutableBytes {
            (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, 12, mutableBytes)
        }
        if result == errSecSuccess {
            return keyData
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    

    @objc open func requestKey(groupJid:String)->(String){
       
        let requestdata:[String:Any] = ["muc-id":groupJid,"type":"request_for_muc_key"];
         let jsonbodydata = try! JSONSerialization.data(withJSONObject: requestdata, options: JSONSerialization.WritingOptions.prettyPrinted)
         let jsonbodystring = NSString(data: jsonbodydata, encoding: String.Encoding.utf8.rawValue)! as String
       return (jsonbodystring) as  String
    }
    
    @objc open func sendkey(groupJid:String,key:String)->(String){
       
        let requestdata:[String:Any] = ["muc-key":key,"muc-id":groupJid,"type":"request_to_save_muc_key"];
         let jsonbodydata = try! JSONSerialization.data(withJSONObject: requestdata, options: JSONSerialization.WritingOptions.prettyPrinted)
         let jsonbodystring = NSString(data: jsonbodydata, encoding: String.Encoding.utf8.rawValue)! as String
       return (jsonbodystring) as  String
    }
    
    @objc open func typeCast_Body(group_body:String) ->(String){
        let bodydata:[String:Any] = ["body":group_body,"type":"Decrypt_Message"];
         let jsonbodydata = try! JSONSerialization.data(withJSONObject: bodydata, options: JSONSerialization.WritingOptions.prettyPrinted)
         let jsonbodystring = NSString(data: jsonbodydata, encoding: String.Encoding.utf8.rawValue)! as String
       return (jsonbodystring) as  String
    }

    @objc open func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    @objc open func keygeneration() {
        
        var privateencoded:String?
        deleteAllKeysInKeyChain()
        SecKeyGeneratePair(keyattribute, &publicKeySec, &privateKeySec)
        print(privateKeySec as Any)
      
        if let cfprivatedata = SecKeyCopyExternalRepresentation(privateKeySec!, &error) {
           let privatedata:Data = cfprivatedata as Data
            print(privatedata.base64EncodedString())
            privateencoded = privatedata.base64EncodedString()
        }
        print(privateencoded)
        self.StoreInKeychain(tag: tagPrivate, key: privateKeySec!)
        self.StoreInKeychain(tag: tagPublic, key: publicKeySec!)
         

     
    }
    
    @objc open func PublicKeyExportFormat(Pk:SecKey)->(String){
        if let cfdata = SecKeyCopyExternalRepresentation(Pk, &error) {
              let data:Data = cfdata as Data
           print(data)
              let b64Key2 = data.base64EncodedString()
               print("iOS Default: " + b64Key2)
               let exportImportManager = CryptoExportImportManager()
           
           if let exportableDERKey = exportImportManager.exportPublicKeyToDER(data, keyType: kSecAttrKeyTypeEC as String, keySize: 256, privatekey: false) {
               print("Converted: " + exportableDERKey.base64EncodedString())
                   publickeybase64encoded = exportableDERKey.base64EncodedString()
               } else {
                   return "error"
               }

           }
       let botdata: [String: Any] = ["body":[ "type":"TYPE_PUBLIC_KEY" , "data":publickeybase64encoded]]
       let salt = "abc123"
       let jsonData = try! JSONSerialization.data(withJSONObject: botdata, options: JSONSerialization.WritingOptions.prettyPrinted)
       let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String

        let checksumderive = jsonString + salt
        print(checksumderive)
        let checksumdata = sha256(string: checksumderive)
   
        var checksum = ""
     for index in 0..<Int(CC_SHA256_DIGEST_LENGTH) {
      checksum += String(format: "%02x", checksumdata![index])
     }
       let bodydata:[String:Any] = ["body":["type":"TYPE_PUBLIC_KEY","data":publickeybase64encoded],"checksum":checksum]
       let jsonbodydata = try! JSONSerialization.data(withJSONObject: bodydata, options: JSONSerialization.WritingOptions.prettyPrinted)
       let jsonbodystring = NSString(data: jsonbodydata, encoding: String.Encoding.utf8.rawValue)! as String
       print(jsonbodystring)
   
        return jsonbodystring
    }
    
    @objc open func publickey_request(Threadname:String,account:String)->(String){
        let salt = "abc123"
        let requestdata:[String:Any] = ["body":["from":account,"to":Threadname,"type":"TYPE_PUBLIC_KEY_REQUEST"]];
        let requestjson = try! JSONSerialization.data(withJSONObject: requestdata, options: JSONSerialization.WritingOptions.prettyPrinted)
         let requeststring = NSString(data: requestjson, encoding: String.Encoding.utf8.rawValue)! as String
        let checksumderived = requeststring + salt
         let checksumdata = sha256(string: checksumderived)
        var checksum = ""
                 for index in 0..<Int(CC_SHA256_DIGEST_LENGTH) {
                  checksum += String(format: "%02x", checksumdata![index])
                 }
        let bodydata:[String:Any] = ["body":["from":account,"to":Threadname,"type":"TYPE_PUBLIC_KEY_REQUEST"],"checksum":checksum];
         let jsonbodydata = try! JSONSerialization.data(withJSONObject: bodydata, options: JSONSerialization.WritingOptions.prettyPrinted)
         let jsonbodystring = NSString(data: jsonbodydata, encoding: String.Encoding.utf8.rawValue)! as String
       return (jsonbodystring) as  String
    }

    func MD5(messageData: Data) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
       // let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }


 @objc open func sha256(string: String) -> Data? {
            let len = Int(CC_SHA256_DIGEST_LENGTH)
              let data = string.data(using:.utf8)!
              var hash = Data(count:len)

              let _ = hash.withUnsafeMutableBytes {hashBytes in
                  data.withUnsafeBytes {dataBytes in
                      CC_SHA256(dataBytes, CC_LONG(data.count), hashBytes)
                  }
              }
              return hash
      
  }
    
@objc open func Encryptdatabase(password:String,database:Data,EncryptionKey:String)-> (Data){
        let Password: Array<UInt8> = password.bytes
        let saltGen = "cNwnWH8BJPcyFvWNl6y1"
        let salt: [UInt8] = Array(saltGen.utf8)
        do{
         /* Generate a key from a `password`. Optional if you already have a key */
            let key = try PKCS5.PBKDF2(
                password: Password,
                salt: salt,
                iterations: 4096,
                keyLength: 32, /* AES-256 */
                variant: .sha256
            ).calculate()
            
            let iv: Array<UInt8> = [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]

            /* AES cryptor instance */
            let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)

            /* Encrypt Data */
         
            let encryptedBytes = try aes.encrypt(database.bytes)
            let encryptedData = Data(encryptedBytes)
            return encryptedData
        }catch{
            print(error)
        }
      
      
        return Data()
    }
    
    @objc open func aesEncrypt(messageData: NSData) -> String? {
   
        var cipherData:Data?
                do {
                    
                    let iv: Array<UInt8> = [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]
                    var key:Data?
                    key = UserDefaults.standard.object(forKey: tagSymmetricData) as? Data
                    if (key == nil){
                        var botpublicKeyretreive: SecKey?
                         botpublicKeyretreive = GetKeyTypeInKeyChain(tag: tagBotPublic)
                        if botpublicKeyretreive != nil{
                            self.retreivekeys { (keyData, error) in
                                if (error != nil) {
                                   key = nil
                                }else{
                                   key = keyData
                                }
                            }
                        }
                    }
                    if key == nil{
                        return "Unable to fetch the Encryption Keys"
                    }
                    let keybytes = [UInt8](key!)
                    let keyarray = key!.withUnsafeBytes {
                        [UInt8](UnsafeBufferPointer(start: $0, count: key!.count))
                    }
                    let messagedata = messageData as Data
                    let messagedataArray = messagedata.withUnsafeBytes {
                                       [UInt8](UnsafeBufferPointer(start: $0, count: messageData.count))
                                   }
                    let messageBytes = [UInt8] (messageData as Data)
                    do {
                    
                    let gcm = GCM(iv: iv, mode: .combined)
                    let aes = try AES(key: keyarray, blockMode: gcm, padding: .noPadding)
                        let encrypted = try aes.encrypt(messagedataArray)
                        let dataencrypted = NSData(bytes: encrypted, length: encrypted.count)
                            cipherData = dataencrypted as Data
                    
                    } catch {
                        print(error)
                    }
                    
                  let base64cryptString = cipherData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                    let botdata: [String: Any] = ["body":["type":"TYPE_DH_ENCRYPTED","data":base64cryptString]]
                              let salt = "abc123"

                              let jsonData = try! JSONSerialization.data(withJSONObject: botdata, options: JSONSerialization.WritingOptions.prettyPrinted)
                              let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String

                            let checksumderive = jsonString + salt
                              print(checksumderive)
                          let checksumdata = sha256(string: checksumderive)
                          
                            var checksum = ""
                            for index in 0..<Int(CC_SHA256_DIGEST_LENGTH) {
                             checksum += String(format: "%02x", checksumdata![index])
                            }
                    
                              let bodydata:[String:Any] = ["checksum":checksum,"body":["type":"TYPE_DH_ENCRYPTED","data":base64cryptString]]
                              let jsonbodydata = try! JSONSerialization.data(withJSONObject: bodydata, options: [])
                              let jsonbodystring = NSString(data: jsonbodydata, encoding: String.Encoding.utf8.rawValue)! as String
                              print(jsonbodystring)
                          
                          return (jsonbodystring) as  String

                }catch let error {
                 
                                    return "error"
                                }
                          return ""
                }
    
    
    
   
    
    @objc open func decryptmessage(Encrypteddata:String)->String{
        
        let encryteddata: NSData = NSData(base64Encoded: Encrypteddata, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
        let encrypted = encryteddata as Data
        let iv: Array<UInt8> = [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]
        var key:Data?
        var botpublicKeyretreive: SecKey?
               botpublicKeyretreive = GetKeyTypeInKeyChain(tag: tagBotPublic)
              if (botpublicKeyretreive != nil ){
                  self.retreivekeys { (keyData, error) in
                if (error != nil) {
                    return;
                }else{
                   key = keyData
                }
            }
        }
        if key == nil{
            return ""
        }
        
        let keyarray = key!.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: key!.count))
        }
      
        let messagedataArray = encrypted.withUnsafeBytes {
                                              [UInt8](UnsafeBufferPointer(start: $0, count: encrypted.count))
                                          }
        do {
            // In combined mode, the authentication tag is appended to the encrypted message. This is usually what you want.
            let gcm = GCM(iv: iv, mode: .combined)
            let aes = try AES(key: keyarray, blockMode: gcm, padding: .noPadding)
            //
            let decrypted = try aes.decrypt(messagedataArray)
//          let decrypted = try AES(key: keyarray, blockMode: CBC(iv: iv), padding: .zeroPadding).decrypt(messagedataArray)
            let decrypteddata = NSData(bytes: decrypted, length: decrypted.count)
            let data = decrypteddata as Data
            let roomMessage = String(data: data, encoding: String.Encoding.utf8)
            
            return roomMessage!
        } catch {
            print(error)
           return "error_Decrypt"
        }
        return ""
    }
//

    
    
    
    @objc open func aesMessageEncrypt(messageData: Data,key:Data,iv:Data,AAD:Data) -> Data? {
   
        var cipherData:Data?
                do {

                   
                                       let ivarray = iv.withUnsafeBytes {
                                           [UInt8](UnsafeBufferPointer(start: $0, count: iv.count))
                                       }
                   
                                       let keyarray = key.withUnsafeBytes {
                                           [UInt8](UnsafeBufferPointer(start: $0, count: key.count))
                                       }
                   
                                       let AADbytes = AAD.withUnsafeBytes {
                                           [UInt8](UnsafeBufferPointer(start: $0, count: AAD.count))
                                       }
                   
                    let messagedataArray = messageData.withUnsafeBytes {
                                       [UInt8](UnsafeBufferPointer(start: $0, count: messageData.count))
                                   }
                 
                    do {
                        let gcm = GCM(iv: ivarray, additionalAuthenticatedData:AADbytes , mode: .combined)
                        let aes = try AES(key:keyarray, blockMode: gcm, padding: .noPadding)
                        let encrypted = try aes.encrypt(messagedataArray)
                        let dataencrypted = NSData(bytes: encrypted, length: encrypted.count)
                            cipherData = dataencrypted as Data
                        
                       
                        return cipherData
                        
                    } catch {
                        print(error)
                    }
                    return nil
               
                }
//
                }
    
    
    
   
    
    @objc open func aesMessageDecrypt(Encrypteddata:Data,iv:Data,key:Data,AAD:Data)->String{
        
 
        
     
                           let ivarray = iv.withUnsafeBytes {
                               [UInt8](UnsafeBufferPointer(start: $0, count: iv.count))
                           }
      
                           let keyarray = key.withUnsafeBytes {
                               [UInt8](UnsafeBufferPointer(start: $0, count: key.count))
                           }
                        let messagedataArray = Encrypteddata.withUnsafeBytes {
                           [UInt8](UnsafeBufferPointer(start: $0, count: Encrypteddata.count))
                       }
        let AADbytes = AAD.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: AAD.count))
        }
       
        do {
            // In combined mode, the authentication tag is appended to the encrypted message. This is usually what you want.
            let gcm = GCM(iv: ivarray, additionalAuthenticatedData:AADbytes , mode: .combined)
            let aes = try AES(key: keyarray, blockMode: gcm, padding: .noPadding)
            //
            let decrypted = try aes.decrypt(messagedataArray)

            let decrypteddata = NSData(bytes: decrypted, length: decrypted.count)
            let data = decrypteddata as Data
            let roomMessage = String(data: data, encoding: String.Encoding.utf8)
            
            return roomMessage!
        } catch {
            print(error)
           return "error_Decrypt"
        }
        return ""
    }
 @objc open func deleteAllKeysInKeyChain() {
           
           let query : [String: AnyObject] = [
               String(kSecClass)             : kSecClassKey
           ]
        let status = SecItemDelete(query as CFDictionary)
           
           switch status {
               case errSecItemNotFound:
                   print("No key in keychain")
               case noErr:
                   print("All Keys Deleted!")
               default:
                   print("SecItemDelete error! \(status.description)")
           }
       }
    //
    //
   
    func StoreInKeychain(tag: String, key: SecKey) {
     
          let storeattribute = [
                  String(kSecClass)              : kSecClassKey,
                  String(kSecAttrKeyType)        : kSecAttrKeyTypeEC,
                  String(kSecValueRef)           : key,
                  String(kSecReturnPersistentRef): true
            ] as [String : Any]

//: [CFString: Any]
       
        let addParams: [String: Any] = [
            kSecValueRef as String: key,
            kSecReturnData as String: true,
            kSecClass as String: kSecClassKey,
            kSecAttrAccessible as String   : kSecAttrAccessibleAlwaysThisDeviceOnly,
            kSecAttrApplicationTag as String: tag
                  ]



        let status = SecItemAdd(addParams as CFDictionary, nil)

        if status != noErr {
            print("SecItemAdd Error!\(status)")
            return
        }else{
            print("key saved successfully")
        }
        
   
    }
    
    @objc open func GetMyPrivateandPublickey()->Bool{
         privateKey = GetKeyTypeInKeyChain(tag:tagPrivate)
        publicKey = GetKeyTypeInKeyChain(tag:tagPublic)
        if ((privateKey != nil)&&(publicKey != nil)){
            return true
        }else{
            
        }
        
        return false
    }
    
    
    @objc open func GetBotpublickey()->Bool{
            botpublickey = GetKeyTypeInKeyChain(tag:tagBotPublic)
        
           if (botpublickey == nil){
               return false
           }
    
          return true
       }
    
    @objc open func GetKeysFromKeychain() {
        privateKey = GetKeyTypeInKeyChain(tag:tagPrivate)
        publicKey = GetKeyTypeInKeyChain(tag:tagPublic)
        
        if (((privateKey != nil)&&(publicKey != nil)) == true){
            do{
                var data = try sharedsecret(Privatekey: privateKey!, publickey: publicKey!)
                print(data)
            } catch let error {
                print("Error: \(error)")
            }
        }
        
        
       }
    
    @objc open  func retreivekeys(completionBlock: @escaping (Data, NSError?) -> Void) -> Void{
        var mypublicKey, myprivateKey,botpublicKeyretreive: SecKey?
        var keydata:Data?
        myprivateKey = GetKeyTypeInKeyChain(tag:tagPrivate)
        mypublicKey = GetKeyTypeInKeyChain(tag:tagPublic)
        botpublicKeyretreive = GetKeyTypeInKeyChain(tag: tagBotPublic)
  //if (myprivateKey != nil && mypublicKey != nil && botpublicKeyretreive != nil){
         do {
            keydata = try sharedsecret(Privatekey: myprivateKey!, publickey: botpublicKeyretreive!)
            completionBlock(keydata!, nil)
                 
             } catch let error {
                completionBlock(keydata ?? Data(),error as NSError)
                      // return error as Error as! Data
            }
    
  //}
     }
  
 
   
    @objc open func addKeychainItem(key: String, data: Data) {
        let err = SecItemAdd([
            kSecClass:          kSecClassGenericPassword,
            kSecAttrService:    "my_service",
            kSecAttrAccount:    key,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData:      data
        ] as NSDictionary, nil)
        switch err {
            case errSecSuccess, errSecDuplicateItem:
                break
            default:
                fatalError()
        }
    }

     open func readKeychainItem(key: String)  throws ->Data? {
        var result: CFTypeRef? = nil
        let err = SecItemCopyMatching([
            kSecClass:          kSecClassGenericPassword,
            kSecAttrService:    "my_service",
            kSecAttrAccount:    key,
            kSecReturnData:     true
        ] as NSDictionary, &result)
        
      //  var dataTypeRef: AnyObject? = nil
//
//        let status: OSStatus = SecItemCopyMatching(err as! CFDictionary, &dataTypeRef)
//
//        if status == noErr {
//            return result as! Data?
//        } else {
//            return nil
//        }
//        do{
//            try sharedsecret(Privatekey: privateKey!, publickey: publicKey!)
//        } catch let error {
//            print("Error: \(error)")
//        }
        guard err == errSecSuccess else {
            throw error!.takeRetainedValue() as Error
        }
//        let password = String(bytes: (result as! Data), encoding: .utf8)!
//        let protectedState = UIApplication.shared.isProtectedDataAvailable ? "Unprotected" : "Protected"
//        return "\(protectedState): '\(password)'"
        return result as? Data
    }

    func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]

        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

  func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
    
    @objc open func generatePublickeymessage()->String{
        let publicKeySec = self.GetKeyTypeInKeyChain(tag: "myPublic")
        let PKExport = self.PublicKeyExportFormat(Pk: publicKeySec!)
        return PKExport;
        
    }
    @objc open func GetKeyTypeInKeyChain(tag : String) -> SecKey? {
           let query = [
               String(kSecClass)             : kSecClassKey,
               String(kSecAttrKeyType)       : kSecAttrKeyTypeEC,
               kSecAttrApplicationTag as String: tag,
               String(kSecReturnRef)         : true
           ] as [String : Any]
//
           var result : AnyObject?

        let status = SecItemCopyMatching(query as CFDictionary, &result)
           
           if status == errSecSuccess {
      
               return result as! SecKey?
           }
  
           
           return nil
       }

    
    func sharedsecret(Privatekey:SecKey,publickey:SecKey) throws ->Data {
      
          let exchangeOptions: [String: Any] = [:]
         guard let shared = SecKeyCopyKeyExchangeResult(Privatekey, SecKeyAlgorithm.ecdhKeyExchangeCofactor, publickey, exchangeOptions as CFDictionary, &error) else {
                    throw error!.takeRetainedValue() as Error
                }
        
        UserDefaults.standard.set(shared, forKey: tagSymmetricData)
       return shared as Data
    }
}


    

 
struct Datasave:Codable{
    var checksum:String?
    var body:Publickeydata?
    enum codingkeys:String,CodingKey{
        case checksum = "checksum"
        case body = "body"
    }
}
struct Publickeydata:Codable{
    var data:String?
    var from:String?
    var to:String?
    var type:String?
    enum codingkeys:String,CodingKey{
        case data = "data"
        case from = "from"
        case to = "to"
        case type = "type"
    }
 }






