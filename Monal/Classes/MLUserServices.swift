import Foundation
import CryptoKit
import CommonCrypto
import CryptoSwift

@objc public class UserServices:NSObject{
    private var token = "eyJhbGciOiJSUzI1NiIsIng1YyI6WyJNSUlGbFRDQ0JIMmdBd0lCQWdJUkFMN21zSmtiM1RkN0NBQUFBQUJ4WWg0d0RRWUpLb1pJaHZjTkFRRUxCUUF3UWpFTE1Ba0dBMVVFQmhNQ1ZWTXhIakFjQmdOVkJBb1RGVWR2YjJkc1pTQlVjblZ6ZENCVFpYSjJhV05sY3pFVE1CRUdBMVVFQXhNS1IxUlRJRU5CSURGUE1UQWVGdzB5TVRBMU1qQXdOekl4TkRkYUZ3MHlNVEE0TVRnd056SXhORFphTUd3eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIRXcxTmIzVnVkR0ZwYmlCV2FXVjNNUk13RVFZRFZRUUtFd3BIYjI5bmJHVWdURXhETVJzd0dRWURWUVFERXhKaGRIUmxjM1F1WVc1a2NtOXBaQzVqYjIwd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUUN1bU1uV2p2R0ZuendMdXJ1SnJoTm1za3JEd0p2Tm0ycjBjRDdxeWF0NkFxSVZ3WkJmZGNYMWpCMGxUK2pzK3pHQzNNUzdac3llbXZSaGRxcERhdkhTVmZ4S3hZREc2dHp1eHh4ZE0wOWVKWFNtSkZLTWVSVWZUVkFBc0x5WWVHOWVHMno5WG5oZ3VkK3N3dVJKTWxJZzE3bnBlQ0toRHNlL1lQaTR5YmhrcXRsOC9NLzNrKzlMVTZrbndGMjRJODNNUjdnVGtMN1doU2RPb2tybnZkWnUrR0poYVhQcGJtaEpiUi9xNlhOQWVNR3hSaGhKRHlrOEhaa005cFJyNndaMFJhQ2Qva1FLNWh4T3hkejR3YU5zNDBiYVVNQU5tcG1UMGxFY1VaMnQxUUNmL3dMcldHNjhDa0V5clNVT2pQVURvalJmVG53YTlVdmFGNTZ1eUI0akFnTUJBQUdqZ2dKYU1JSUNWakFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUhBd0V3REFZRFZSMFRBUUgvQkFJd0FEQWRCZ05WSFE0RUZnUVVMbFhFSFdWeHZRVEZGM1QvNUQ3NzJpckZMNUV3SHdZRFZSMGpCQmd3Rm9BVW1OSDRiaERyejV2c1lKOFlrQnVnNjMwSi9Tc3daQVlJS3dZQkJRVUhBUUVFV0RCV01DY0dDQ3NHQVFVRkJ6QUJoaHRvZEhSd09pOHZiMk56Y0M1d2Eya3VaMjl2Wnk5bmRITXhiekV3S3dZSUt3WUJCUVVITUFLR0gyaDBkSEE2THk5d2Eya3VaMjl2Wnk5bmMzSXlMMGRVVXpGUE1TNWpjblF3SFFZRFZSMFJCQll3RklJU1lYUjBaWE4wTG1GdVpISnZhV1F1WTI5dE1DRUdBMVVkSUFRYU1CZ3dDQVlHWjRFTUFRSUNNQXdHQ2lzR0FRUUIxbmtDQlFNd0x3WURWUjBmQkNnd0pqQWtvQ0tnSUlZZWFIUjBjRG92TDJOeWJDNXdhMmt1WjI5dlp5OUhWRk14VHpFdVkzSnNNSUlCQmdZS0t3WUJCQUhXZVFJRUFnU0I5d1NCOUFEeUFIY0FmVDd5K0kvL2lGVm9KTUxBeXA1U2lYa3J4UTU0Q1g4dWFwZG9tWDRpOE5jQUFBRjVpTjNTc3dBQUJBTUFTREJHQWlFQW43bFhhSzYxOFFQekJ0RlEwOGlpNWtQblJDK3Vlc1hLQWFwV1B4aldDOFVDSVFEeFRUeVh0TnpNbFBkV3JVeFBLSjEybmlHRm56SFNsa0VlRG9PSVJicnkyUUIzQU83QWxlNk5jbVFQa3VQRHVSdkhFcU5wYWdsN1Myb2FGRGptUjdMTDdjWDVBQUFCZVlqZDBSa0FBQVFEQUVnd1JnSWhBTmJWUnBrZTJYaTZkUy9tcTZCWUVKSFZEYnhuZmxkVklUZC9NTFBEMTRKbEFpRUF3ZU1lbWxiaDNDcS91bUZiYkR5MUlranRxeUJ5TENwbXRvOGY2bGhzRWNJd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFKN2xrZFdudEEyZjBvM3lzODM4ZlAveFFKY2xEUUM3S0p0WGJRRUZIZXdIZkphUytEZi83WGVHeG5uWFRpOCtUaG5vQm13Q0c0alpqYndTT2g2UXIvSWNtOFB1akJkSzU3ZzFsY1RPeFhsN1hUbmlMT3E1b0JweW1FdThuQy9UY2YvQ3cwWVdkMUJhS1luaVlFamw5eUJnTnJ0RENEYm5HblRNNkl6MlhuVFQrQzhDRTNjNGxKeWdxNHh6R0xhSWVUbmtHTGpDYnI4VlQwOEx6Q29WMDQ3Umg0Rm1XZzBLdmlkamRBSlVyeGgzUitkMDV1S3UvK3h5aWRudnUvOEk0VUo0c2RrbjhmQ2hHbzl5cGJRek1aRmEzaFEvaDB0V0g4S1E5eUN5dEhqc2NkeVNSc3c4WDB5ck1hSEdsSjRZYms0VmlLQ2tOWGNqTy93Z2tRam4xdUE9IiwiTUlJRVNqQ0NBektnQXdJQkFnSU5BZU8wbXFHTmlxbUJKV2xRdURBTkJna3Foa2lHOXcwQkFRc0ZBREJNTVNBd0hnWURWUVFMRXhkSGJHOWlZV3hUYVdkdUlGSnZiM1FnUTBFZ0xTQlNNakVUTUJFR0ExVUVDaE1LUjJ4dlltRnNVMmxuYmpFVE1CRUdBMVVFQXhNS1IyeHZZbUZzVTJsbmJqQWVGdzB4TnpBMk1UVXdNREF3TkRKYUZ3MHlNVEV5TVRVd01EQXdOREphTUVJeEN6QUpCZ05WQkFZVEFsVlRNUjR3SEFZRFZRUUtFeFZIYjI5bmJHVWdWSEoxYzNRZ1UyVnlkbWxqWlhNeEV6QVJCZ05WQkFNVENrZFVVeUJEUVNBeFR6RXdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFEUUdNOUYxSXZOMDV6a1FPOSt0TjFwSVJ2Snp6eU9USFc1RHpFWmhEMmVQQ252VUEwUWsyOEZnSUNmS3FDOUVrc0M0VDJmV0JZay9qQ2ZDM1IzVlpNZFMvZE40WktDRVBaUnJBekRzaUtVRHpScm1CQko1d3VkZ3puZElNWWNMZS9SR0dGbDV5T0RJS2dqRXYvU0pIL1VMK2RFYWx0TjExQm1zSytlUW1NRisrQWN4R05ocjU5cU0vOWlsNzFJMmROOEZHZmNkZHd1YWVqNGJYaHAwTGNRQmJqeE1jSTdKUDBhTTNUNEkrRHNheG1LRnNianphVE5DOXV6cEZsZ09JZzdyUjI1eG95blV4djh2Tm1rcTd6ZFBHSFhreFdZN29HOWorSmtSeUJBQms3WHJKZm91Y0JaRXFGSkpTUGs3WEEwTEtXMFkzejVvejJEMGMxdEpLd0hBZ01CQUFHamdnRXpNSUlCTHpBT0JnTlZIUThCQWY4RUJBTUNBWVl3SFFZRFZSMGxCQll3RkFZSUt3WUJCUVVIQXdFR0NDc0dBUVVGQndNQ01CSUdBMVVkRXdFQi93UUlNQVlCQWY4Q0FRQXdIUVlEVlIwT0JCWUVGSmpSK0c0UTY4K2I3R0NmR0pBYm9PdDlDZjByTUI4R0ExVWRJd1FZTUJhQUZKdmlCMWRuSEI3QWFnYmVXYlNhTGQvY0dZWXVNRFVHQ0NzR0FRVUZCd0VCQkNrd0p6QWxCZ2dyQmdFRkJRY3dBWVlaYUhSMGNEb3ZMMjlqYzNBdWNHdHBMbWR2YjJjdlozTnlNakF5QmdOVkhSOEVLekFwTUNlZ0phQWpoaUZvZEhSd09pOHZZM0pzTG5CcmFTNW5iMjluTDJkemNqSXZaM055TWk1amNtd3dQd1lEVlIwZ0JEZ3dOakEwQmdabmdRd0JBZ0l3S2pBb0JnZ3JCZ0VGQlFjQ0FSWWNhSFIwY0hNNkx5OXdhMmt1WjI5dlp5OXlaWEJ2YzJsMGIzSjVMekFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBR29BK05ubjc4eTZwUmpkOVhsUVdOYTdIVGdpWi9yM1JOR2ttVW1ZSFBRcTZTY3RpOVBFYWp2d1JUMmlXVEhRcjAyZmVzcU9xQlkyRVRVd2daUStsbHRvTkZ2aHNPOXR2QkNPSWF6cHN3V0M5YUo5eGp1NHRXRFFIOE5WVTZZWlovWHRlRFNHVTlZekpxUGpZOHEzTUR4cnptcWVwQkNmNW84bXcvd0o0YTJHNnh6VXI2RmI2VDhNY0RPMjJQTFJMNnUzTTRUenMzQTJNMWo2YnlrSllpOHdXSVJkQXZLTFdadS9heEJWYnpZbXFtd2ttNXpMU0RXNW5JQUpiRUxDUUNad01INTZ0MkR2cW9meHM2QkJjQ0ZJWlVTcHh1Nng2dGQwVjdTdkpDQ29zaXJTbUlhdGovOWRTU1ZEUWliZXQ4cS83VUs0djRaVU44MGF0blp6MXlnPT0iXX0.eyJub25jZSI6ImpyMnJhSVJNVm1KaDRDK0txZnVrT1NHVXBFbVVxTXA2VUhKbGMyVnVZMlVnUVhSMFpYTjBZWFJwYjI0eE5qSTFNVEU0T0RZeE1URTAiLCJ0aW1lc3RhbXBNcyI6MTYyNTExODg2NDM5NywiYXBrUGFja2FnZU5hbWUiOiJpbi5zZWN1cmUuc2lnbmFsIiwiYXBrRGlnZXN0U2hhMjU2IjoiZ3kzNHI2ZTMxMkU4N3NDOVd3c25lQ2ZKYS9GbVhYR052V3lLaUJ5Z21Mdz0iLCJjdHNQcm9maWxlTWF0Y2giOnRydWUsImFwa0NlcnRpZmljYXRlRGlnZXN0U2hhMjU2IjpbIm1zS3E0d0VlWFFTbVNKSzI0RTkyWW9zKzVjQmxNd0YrTUt4b05EdnJVNGM9Il0sImJhc2ljSW50ZWdyaXR5Ijp0cnVlLCJldmFsdWF0aW9uVHlwZSI6IkJBU0lDLEhBUkRXQVJFX0JBQ0tFRCJ9.eQscDiBxUhmRK5Py9x8F8QrEcJ9ywWVWrBrE1qBj7mKSbqU1j8jcUXguGagMiZnKcPJDKJ5asikJr8jSaUKwbM9PR-KPsqJk_0E1L6DUxvRjxos9rNdDmhI1nzaDc35xwr1SifL47IsYhgPdDnunS3rEyv4KjfmhbEtKoHRI_l4qd50qDGyeYsvRTDXsw2zC5bd2Wx7Hvi00nhOfBI4mtfKzWm4CxKjUiufZiXeRU5PiMZWUtiwmMfsVe0DojBEphoZ3hF6gw0nua3qApR9gkanx7OC2x_cDOk2rLNPC8lNpQxUWhRUuZz1eMotUaqvjCKq6lR_4V8G-eY9S228Q0w"

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


    func JWSGeneration(UserName:String, completion: @escaping (_ success: Bool ,_ jwsToken:String?) -> ()){
        
    var Status:Bool = false
    var jwsToken:String?
    let Authorization = "Bearer bMILoZi5k7nRThAuA9uBeeTlyNay0Poj"
    let salt = "3vGX1PaaC5RhYxTZqNtCMlQGgh0wPlRD"
    var deviceId = UIDevice.current.identifierForVendor!.uuidString
    let now = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = formatter.string(from: now)
    deviceId = deviceId.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
    let token = UserName + deviceId + dateString + salt

//    self.deviceIDentication = deviceId
//    self.username = UserName
    let PayloadData: Array<UInt8> = Array(token.utf8)
      let Payloadsalt: Array<UInt8> = Array(salt.utf8)
    do {
      
        let result = try! HMAC(key: Payloadsalt, variant: .sha256).authenticate(PayloadData)
        let hashdata = Data(result)
        var hmacHash = hexStringFromData(input: hashdata as NSData)
        hmacHash = hmacHash.lowercased()
    //        let userdata : Data = "username=\(UserName)&deviceid=\(deviceId)&token=\(hmacHash)".data(using: .utf8)!
       
        let apidata: [String: Any] = ["username":UserName,"deviceid":deviceId,"timestamp":dateString,"token":hmacHash]
        let jsonData = try? JSONSerialization.data(withJSONObject: apidata)
        let urlstring = URL(string: "https://api2.securesignal.in:8443/LMiO3U61XjUKsJWGgCPIMdFfKt36hrEh")

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

                                  //return true
                               }else{
                                Status = false
                                   // return self.status!
                               }
                           }

                         do {
                           let json = try JSONSerialization.jsonObject(with: data,options:[]) as? [String:Any]
                               print(json)
                            let status = json?["status"] as? String
    //
                           print(status)
                            if (status!.contains("SUCCESS")){
                                Status = true
                               jwsToken = json?["jws"] as? String
                              
                           }else if (status!.contains("ERROR:")){
                            Status = false
                            DispatchQueue.main.async {
                                
//                                if (status!.contains("0x2001")){
//                                    self.passwordTF?.errorLabel.text = "OTP Not Sent"
//                                }else if (status!.contains("0x3112")){
//                                    self.passwordTF?.errorLabel.text = "Unauthorized"
//                                }else if (status!.contains("0x3113")){
//                                    self.passwordTF?.errorLabel.text = "Already Logged in"
//                                }else if (status!.contains("0x3114")){
//                                    self.passwordTF?.errorLabel.text =  "Wrong OTP"
//                                }else if (status!.contains("0x3115")){
//                                    self.passwordTF?.errorLabel.text = "Account Banned"
//
//                                }else if (status!.contains("0x3116")){
//                                    self.passwordTF?.errorLabel.text = "IP address blocked"
//                                }else if (status!.contains("0x3117")){
//                                    self.passwordTF?.errorLabel.text = "Account Not Found"
//                                }
                                   
                               
                           
                               
                               // return self.status!
                           }
                           }}
                   catch {
                       print("cant parse json \(error)")
                       Status = false
                       }

                        completion(Status,jwsToken ?? nil)
                       }).resume()
    } catch {
        print(error.localizedDescription)
    }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @objc open func registerAPNS(UserName:String, pushToken:String ,completion: @escaping (_ success: Bool ,_ error:String? ) -> ()){

    var Status:Bool = false
    var errorStatus:String?
    let domain = "chat.securesignal.in"
        //Bearer TN5sBit7LEZEICw6ws8NG6NjiCHmzzdc
    let Authorization = "Bearer bM1LoZi5k7nRThAuA9uBeeTlyNay0P0j"
    let salt = "yXvzCMKF8nWBlw54BH0Y3pGEKmRM63fZ"
        //3vGX1PaaC5RhYxTZqNtCMlQGgh0wPlRD
    let nonce = self.randomString(length: 32)
    let jid = UserName + "@" + domain
    let now = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = formatter.string(from: now)
    let token = jid + UserName + pushToken + nonce + dateString
    let PayloadData: Array<UInt8> = Array(token.utf8)
      let Payloadsalt: Array<UInt8> = Array(salt.utf8)
       
    do {
      
        let result = try! HMAC(key: Payloadsalt, variant: .sha256).authenticate(PayloadData)
        let hashdata = Data(result)
        var hmacHash = hexStringFromData(input: hashdata as NSData)
        hmacHash = hmacHash.lowercased()
       
        let apidata: [String: Any] = ["jid":jid,"username":UserName,"devicetoken":pushToken,"timestamp":dateString,"nonce":nonce,"token":hmacHash]
        let jsonData = try? JSONSerialization.data(withJSONObject: apidata)
        //  https://api.securesignal.in/generatecode
        //https://x.ff6b5a92464dfdc9f4f8d44b4ad44fd4c064aa0c514190ecf6a0b.org:4403/
        let urlstring = URL(string: "https://api.securesignal.in/apnsregister")

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
                               completion(Status,error?.localizedDescription ?? "")
                               return
                           }
                           
                           if let response = response {
                               let nsHTTPResponse = response as! HTTPURLResponse
                               let statusCode = nsHTTPResponse.statusCode
                               if statusCode == 200 {
                                   do {
                                     let json = try JSONSerialization.jsonObject(with: data,options:[]) as? [String:Any]
                                       print(json)
                                      let status = json?["status"] as? String
                                      if (status!.contains("SUCCESS")){
                                          Status = true
                                          completion(Status,nil)
                                       
                                     }else if (status!.contains("ERROR:")){
                                      Status = false
                                      errorStatus = status!
                                      completion(Status,status!)
                                    
                                     }}
                             catch {
                                 print("cant parse json \(error)")
                                 Status = false
                                 }
                                   completion(Status,errorStatus ?? "")
                                  
                               }else{
                                   Status = false
                                    let jsonString = String(data: data, encoding: String.Encoding.ascii)!
                                    print (jsonString)
                                   let response = String(statusCode) + "\n" + jsonString
                                   completion(Status,response)
                               }
                           }
                       }).resume()
    } catch {
        print(error.localizedDescription)
    }
    }
    
    @objc open func userNamePresence(UserName:String, pushToken:String ,completion: @escaping (_ success: Bool ,_ error:String? ,_ otp: String?) -> ()){

    var Status:Bool = false
        var errorStatus:String?
    let Authorization = "Bearer TN5sBit7LEZEICw6ws8NG6NjiCHmzzdc"
    let salt = "3vGX1PaaC5RhYxTZqNtCMlQGgh0wPlRD"
    var deviceId = UIDevice.current.identifierForVendor!.uuidString
    let now = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = formatter.string(from: now)
    deviceId = deviceId.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
    let token = UserName + deviceId + dateString + salt
    let PayloadData: Array<UInt8> = Array(token.utf8)
      let Payloadsalt: Array<UInt8> = Array(salt.utf8)
    do {
      
        let result = try! HMAC(key: Payloadsalt, variant: .sha256).authenticate(PayloadData)
        let hashdata = Data(result)
        var hmacHash = hexStringFromData(input: hashdata as NSData)
        hmacHash = hmacHash.lowercased()
        let apidata: [String: Any] = ["username":UserName,"deviceid":deviceId,"timestamp":dateString,"pushTokenAuth":pushToken,"token":hmacHash]
        let jsonData = try? JSONSerialization.data(withJSONObject: apidata)
        //  https://api.securesignal.in/generatecode
        //https://x.ff6b5a92464dfdc9f4f8d44b4ad44fd4c064aa0c514190ecf6a0b.org:4403/
        let urlstring = URL(string: "https://api.securesignal.in/generatecode")

                var urlrequest = URLRequest(url: urlstring!)
                urlrequest.httpMethod = "POST"
                urlrequest.httpBody = jsonData
                urlrequest.setValue(Authorization, forHTTPHeaderField: "Authorization")
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
                                   do {
                                     let json = try JSONSerialization.jsonObject(with: data,options:[]) as? [String:Any]
                                       print(json)
                                      let status = json?["status"] as? String
                                       
                                      if (status!.contains("SUCCESS")){
                                          Status = true
                                          let OTP = json?["otp"] as? String
                                          if (OTP != nil){
                                              completion(Status,nil,OTP!)
                                          }else{
                                             
                                              completion(Status,nil,nil)
                                          }
                                       
                                       
                                     }else if (status!.contains("ERROR:")){
                                      Status = false
                                      errorStatus = status!
                                      completion(Status,status!,nil)
                                    
                                     }}
                             catch {
                                 print("cant parse json \(error)")
                                 Status = false
                                 }
                                   completion(Status,errorStatus ?? "",nil)
                                  
                               }else{
                                   Status = false
                                   let jsonString = String(data: data, encoding: String.Encoding.ascii)!
                                   print (jsonString)
                                  let response = String(statusCode) + "\n" + jsonString
                                   print(response)
                                   completion(Status,response,nil)
                                  
                               }
                           }

                        

                           
                       }).resume()
    } catch {
        print(error.localizedDescription)
    }
    }
    
    
    @objc open func OTPAuthentication(OTP:String,username:String, pushToken:String,completion: @escaping (_ success: Bool , _ passwd:String? , _ NonceSalt:String? ,_ error:String?) -> ()){
     
        var Status:Bool = false
        let Authorization = "Bearer TN5sBit7LEZEICw6ws8NG6NjiCHmzzdc"
        let salt = "3vGX1PaaC5RhYxTZqNtCMlQGgh0wPlRD"
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: now)
        var deviceId = UIDevice.current.identifierForVendor!.uuidString
        deviceId = deviceId.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
        let token = username + OTP + dateString + salt

 
        let PayloadData: Array<UInt8> = Array(token.utf8)
        let Payloadsalt: Array<UInt8> = Array(salt.utf8)

   

     do {
         let result = try! HMAC(key: Payloadsalt, variant: .sha256).authenticate(PayloadData)
         let hashdata = Data(result)
         var hmacHash = hexStringFromData(input: hashdata as NSData)
         hmacHash = hmacHash.lowercased()
       // let userdata : Data = "username=\(self.username!)&otp=\(OTP)&token=\(hmacHash)".data(using: .utf8)!
        let apidata: [String: Any] = ["username":username,"otp":OTP,"timestamp":dateString,"deviceid":deviceId,"pushTokenAuth":pushToken,"token":hmacHash]
         let jsonData = try? JSONSerialization.data(withJSONObject: apidata)
         let urlstring = URL(string: "https://api.securesignal.in/verifycode")

            var urlrequest = URLRequest(url: urlstring!)
                        urlrequest.httpMethod = "POST"
         urlrequest.httpBody = jsonData
         urlrequest.setValue(Authorization, forHTTPHeaderField: "Authorization")
         //urlrequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
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

                                   //return true
                                }else{
                                 Status = false
                                    // return self.status!
                                }
                            }

                          do {
                            let json = try JSONSerialization.jsonObject(with: data,options:[]) as? [String:Any]
                                print(json)
                             let status = json?["status"] as? String
    //
                            print(status)
                             if (status!.contains("SUCCESS")){
                               
                                 var Password = json?["newpass"] as? String
                                let NonceSalt = json?["salt"] as? String
                                
                                 Status = true
                                let AuthenticationSalt = String(Password!.suffix(6))
                               // let Authendata = self.AuthenicationCode! + AuthenticationSalt
                                let AuthenticationData: Array<UInt8> = Array(Password!.utf8)
                                let Payloadsalt: Array<UInt8> = Array(AuthenticationSalt.utf8)
                                let result = try! HMAC(key: Payloadsalt, variant: .sha256).authenticate(AuthenticationData)
                                let hashdata = Data(result)
                                var hmacHash = self.hexStringFromData(input: hashdata as NSData)
                                    hmacHash = hmacHash.lowercased()
                                completion(Status,hmacHash,NonceSalt,nil)
                              
                            }else if (status!.contains("ERROR:")){
                             Status = false
                                completion(Status,nil,nil,status)
                            
                            }}
                    catch {
                        print("cant parse json \(error)")
                        Status = false
                        completion(Status,nil,nil,error.localizedDescription)
                        }

                            
                        }).resume()
     } catch {
         print(error.localizedDescription)
     }
     }

   @objc open func SendUserPresence(userName:String,salt:String, completion: @escaping (_ success: Bool , _ error: String?) -> ()){
     
        var Status:Bool = false
        let Authorization = "Bearer TN5sBit7LEZEICw6ws8NG6NjiCHmzzdc"
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: now)
        var deviceId = UIDevice.current.identifierForVendor!.uuidString
        deviceId = deviceId.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
        var uuid = NSUUID().uuidString.lowercased()
        uuid = uuid.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
        let token = userName + deviceId + uuid + dateString + salt
        let PayloadData: Array<UInt8> = Array(token.utf8)
        let Payloadsalt: Array<UInt8> = Array(salt.utf8)
   
     do {
         let result = try! HMAC(key: Payloadsalt, variant: .sha256).authenticate(PayloadData)
         let hashdata = Data(result)
         var hmacHash = hexStringFromData(input: hashdata as NSData)
         hmacHash = hmacHash.lowercased()
      //   let userdata : Data = "username=\(userName)&deviceid=\(deviceId)&nonce=\(uuid)&token=\(hmacHash)".data(using: .utf8)!
         let apidata: [String: Any] = ["username":userName,"deviceid":deviceId,"nonce":uuid,"timestamp":dateString,"token":hmacHash]
         let jsonData = try? JSONSerialization.data(withJSONObject: apidata)
         let urlstring = URL(string: "https://api.securesignal.in/sendpresence")

            var urlrequest = URLRequest(url: urlstring!)
                        urlrequest.httpMethod = "POST"
         urlrequest.httpBody = jsonData
         urlrequest.setValue(Authorization, forHTTPHeaderField: "Authorization")
       //  urlrequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
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

                                   //return true
                                }else{
                                 Status = false
                                   
                                }
                            }

                          do {
                            let json = try JSONSerialization.jsonObject(with: data,options:[]) as? [String:Any]
                                print(json)
                             let status = json?["status"] as? String
    //
                            print("send presence: \(status)")
                            
                             if (status!.contains("SUCCESS")){
                                 Status = true
                                completion(Status,nil)
                            }else if (status!.contains("ERROR:")){
                             Status = false
                                completion(Status,status)
                              //  self.errorStatus = status
                            }}
                    catch {
                        print("cant parse json \(error)")
                        Status = false
                        completion(Status,error.localizedDescription)
                        }

                           
                        }).resume()
     } catch {
         print(error.localizedDescription)
     }
     }

}
