//
//  MLPushServices.swift
//  Monal
//
//  Created by mohanchandaluri on 18/01/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

import Foundation
import WebKit
import CryptoSwift
import CommonCrypto
import CryptoKit
@objc public class PushServices:NSObject{
    
    public func sha256(token: String) -> String{
        let data = Data(token.utf8)
        return hexStringFromData(input: digest(input:data as NSData ))
       }

       
       private func digest(input : NSData) -> NSData {
           let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
           var hash = [UInt8](repeating: 0, count: digestLength)
           CC_SHA256(input.bytes, UInt32(input.length), &hash)
           return NSData(bytes: hash, length: digestLength)
       }
       
    func hexStringFromData(input: NSData) -> String {
           var bytes = [UInt8](repeating: 0, count: input.length)
           input.getBytes(&bytes, length: input.length)
           
           var hexString = ""
           for byte in bytes {
               hexString += String(format:"%02X", UInt8(byte))
           }
           
           return hexString
       }

    func getPostString(params:[String:Any]) -> String{
           var data = [String]()
           for(key, value) in params
           {
               data.append(key + "=\(value)")
           }
           return data.map { String($0) }.joined(separator: "&")
       }

    @objc open func registerPushservice(jid:String,username:String,pushToken:String ,completion: @escaping (_ success: Bool ,_ error:String? ) -> ()){

    var Status:Bool = false
    let key = "ogmibL34oY8wMRX9Dgi9Im2ZKPUplTAb"
    var errorStatus:String?
    var uuid = NSUUID().uuidString.lowercased()
     uuid = uuid.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
    let now = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = formatter.string(from: now)
    let token = jid + username + pushToken + uuid + dateString
    let PayloadData: Array<UInt8> = Array(token.utf8)
    let Payloadsalt: Array<UInt8> = Array(key.utf8)

do {
    let result = try! HMAC(key: Payloadsalt, variant: .sha256).authenticate(PayloadData)
    let hashdata = Data(result)
    var hmacHash = hexStringFromData(input: hashdata as NSData)
    hmacHash = hmacHash.lowercased()
    let apidata: [String: Any] = ["jid":jid,"username":username,"devicetoken":pushToken,"timestamp":dateString,"nonce":uuid,"token":hmacHash]
    let Authorization = "Bearer bG0YRiJJWVJw5Em1lelf0sIEjtatJ3gL"
    let jsonData = try? JSONSerialization.data(withJSONObject: apidata)
    let urlstring = URL(string: "https://api2.securesignal.in:8443/apnsregister")

            var urlrequest = URLRequest(url: urlstring!)
            urlrequest.httpMethod = "POST"
            urlrequest.httpBody = jsonData
            urlrequest.setValue(Authorization, forHTTPHeaderField: "Authorization")
   // urlrequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                   let session = URLSession.shared
                   let task = session.dataTask(with: urlrequest, completionHandler: { data, response, error in

                       guard let data = data, error == nil else {
                           print("error=\(error)")
                          Status = false
                           print(Status)

                           return
                       }
                       if let response = response {
                           let nsHTTPResponse = response as! HTTPURLResponse
                           let statusCode = nsHTTPResponse.statusCode
                           if statusCode == 200 {
                           Status = true
                           }else{
                            Status = false
                              
                           }
                       }
                      
                     do {
                         
                         let json = try JSONSerialization.jsonObject(with: data,options:[]) as? [String:Any]
                         print(json)
                         let status = json?["status"] as? String
//                       print(status)
                         if (status!.contains("SUCCESS")){
                            Status = true
                            completion(Status,nil)
                         }else if (status!.contains("ERROR:")){
                             Status = false
                             errorStatus = status!
                             completion(Status,status!)
                        //DispatchQueue.main.async {
                       }

                     }
               catch {
                   print("cant parse json \(error)")
                   Status = false
                   }

                       completion(Status,errorStatus ?? "")
                   }).resume()
} catch {
    print(error.localizedDescription)
}
}
    
}
