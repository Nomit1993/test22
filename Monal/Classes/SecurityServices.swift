//
//  SecurityServices.swift
//  Monal
//
//  Created by mohanchandaluri on 14/06/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

import Foundation
import ZDetection
import CoreLocation

@objc public class securityServices:NSObject{
    let license = "U2FsdGVkX1-IAN70CvnM5fkAvxV73MmCHcCDiZ68OpWrLgxlxW2J3mRSR0GGjvvwHofG5HH7Bm47kvLaDNumyY93Lm11pQBBly0rkydU69iMiaUcYPuiNeO8xmdAX-9BKWnFAcXirfXNWhtT7VulHy9cCi1eMJkvbGcR0p-MxA0c7mqUVRiLOKizf7E1zWV4Ci1eHQjnK6vVK4vh1R7nx-_HPH5yJSRW1WJin4wr9tN3x70eD3wDPvVY72Z-Cj5eEcj-zknVwHX_NlImUj7vvYesucXsHiZlm0ceYuEhzx_WqCmqIEUGbLkdj9BV3ej7KiaDt0OVizA_qebVdvM7-trXFpd2saIUVOQeD17b0OJeP-40yB7d1U0l-1Que-Zk7MtNqWuh4X5NGAnYt3qzwQ7UJkYkUOOfKT4eQv2ry7Jv2gljqRPnoLMdtdGzwk2kNbjifPmuu9i3ynB9pBo0UAOhDj1XJv0W9N4mOXb5-_3eXtoLRfgXlGGrYuOTBjn9".data(using: .utf8)
    
    var licenseKeyError: NSError?
    var setSafeTrackingIdsError: NSError?
    
    @objc open func Services(returnCompletion: @escaping (String) -> () ){
        if let zDefendLicense = license {
            ZDetection.setLicenseKey(zDefendLicense, error: &licenseKeyError)
        }

        var SecurityStatus:String = ""
        //MARK: Set Data Folder
        do {
            try ZDetection.setDataFolder("Zimperium")
        } catch {
            print(error)
        }
        
        do {
           let Status =  try ZDetection.createZDetectionTester().removeAllSimulatedThreats()
            
        } catch let error {
            print("error :\(error.localizedDescription)")
        }
        //MARK: Disable Location
        ZDetection.disableLocation()
      //  let disposition: ZThreatDisposition = ZThreatDisposition()
        DispatchQueue.global(qos: .background).async {
            let jailBroken = ZDetection.isRootedOrJailbroken()
            print("Jailbroken = \(jailBroken)")
            if (jailBroken == true){
                returnCompletion("Device is jailBroken or Rooted")
            }else{
                ZDetection.detectCriticalThreats{ (threat: ZThreat?) in
                    print("Threat detected: \(String(describing: threat?.getType()))")
                    print("\nThreat Name: \(String(describing: threat?.humanThreatName()))")
                    print("\nThreat ID: \(String(describing: threat?.threatInternalId))")

                    SecurityStatus = ("\nThreat name: \(String(describing: threat?.humanThreatName()))")
                   
                }
                returnCompletion(SecurityStatus)

            }
            }
      
        
       
        //MARK: Detection State Callback
        ZDetection.addStateCallback{ (old: ZDetectionState?, new: ZDetectionState?) in
            print("DetectionState: old=\(String(describing: old?.stringify())), new=\(String(describing: new?.stringify()))")
            if let newState = new {
//                self.statusView?.text.append("New State: "+newState.stringify()+"\n")
            }
            if let oldState = old {
               // self.statusView?.text.append("Old State: "+oldState.stringify()+"\n")
            }
        }

     

    }
    
}
