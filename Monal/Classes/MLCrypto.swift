//
//  MLCrypto.swift
//  monalxmpp
//
//  Created by Anurodh Pokharel on 1/7/20.
//  Copyright © 2020 Monal.im. All rights reserved.
//

import UIKit
import CryptoKit

@objcMembers
public class MLCrypto: NSObject {
   
    public func encryptGCM (key: Data, decryptedContent:Data) -> EncryptedPayload?
    {
        if #available(iOS 13.0, *) {
            let gcmKey = SymmetricKey.init(data: key)
            
            let iv = AES.GCM.Nonce()
            do {
                let encrypted = try AES.GCM.seal(decryptedContent, using: gcmKey, nonce: iv)
                let encryptedPayload = EncryptedPayload()
                let combined = encrypted.combined
                let ciphertext = encrypted.ciphertext
                
                if let combined = combined {
                let ivData = combined.subdata(in: 0..<12)
                //combined is in the format
                //iv+body+auth
                let range = 12+ciphertext.count..<combined.count //16 is gnereally tag size apple uses
                let tagData = combined.subdata(in:range)
                
                encryptedPayload.updateValues(body:ciphertext, iv: ivData, key:key, tag:tagData)
                encryptedPayload.combined = combined
                return encryptedPayload
                } else  {
                    return nil;
                }
            } catch  {
                return nil
            }
        } else {
            assert(false);
            return nil;
        }
    }
    
    // generate 12 byte nonce
    public func genIV() -> Data?
    {
        if #available(iOS 13.0, *) {
            return Data(AES.GCM.Nonce())
        } else {
            assert(false);
            return nil;
        }
    }
    
    public func decryptGCM (key: Data, encryptedContent:Data) -> Data?
    {
        if #available(iOS 13.0, *) {
            do {
                let sealedBoxToOpen = try! AES.GCM.SealedBox(combined: encryptedContent)
                let gcmKey = SymmetricKey.init(data: key)
                let decryptedData = try AES.GCM.open(sealedBoxToOpen, using: gcmKey)
                return decryptedData
            } catch {
                return nil;
            }
        } else {
            assert(false);
            return nil
        }
    }
    
    public func decryptAESGCM(key:Data ,encryptedContent:Data ,iv:Data ,authentication:Data) -> Data?
    {
       let engine: AES_GCM_Engine;
        var decoded = Data();
       engine = OpenSSL_AES_GCM_Engine()
        guard engine.decrypt(iv: iv, key: key, encoded: encryptedContent, auth: authentication, output: &decoded) else {
            print("decoding of encrypted message failed!");
            return nil
        }
        let body = String(data: decoded, encoding: .utf8);
        return decoded
      // return nil
    }
}
