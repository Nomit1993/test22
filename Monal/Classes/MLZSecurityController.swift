//
//  MLZSecurityController.swift
//  Monal
//
//  Created by mohanchandaluri on 13/06/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

import UIKit
import ZDetection
import CoreLocation
import MapKit
class MLZSecurityController: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
    @IBOutlet weak var mapView: MKMapView!
    var annotation: MKPointAnnotation?
    var expectedThreat: ZThreatType?
   @IBOutlet weak var statusView: UITextView?
    @IBOutlet weak var tableView: UITableView?
    var locationManager = LocationManager()
    var statusText: String?
    let license = "U2FsdGVkX1-IAN70CvnM5fkAvxV73MmCHcCDiZ68OpWrLgxlxW2J3mRSR0GGjvvwHofG5HH7Bm47kvLaDNumyY93Lm11pQBBly0rkydU69iMiaUcYPuiNeO8xmdAX-9BKWnFAcXirfXNWhtT7VulHy9cCi1eMJkvbGcR0p-MxA0c7mqUVRiLOKizf7E1zWV4Ci1eHQjnK6vVK4vh1R7nx-_HPH5yJSRW1WJin4wr9tN3x70eD3wDPvVY72Z-Cj5eEcj-zknVwHX_NlImUj7vvYesucXsHiZlm0ceYuEhzx_WqCmqIEUGbLkdj9BV3ej7KiaDt0OVizA_qebVdvM7-trXFpd2saIUVOQeD17b0OJeP-40yB7d1U0l-1Que-Zk7MtNqWuh4X5NGAnYt3qzwQ7UJkYkUOOfKT4eQv2ry7Jv2gljqRPnoLMdtdGzwk2kNbjifPmuu9i3ynB9pBo0UAOhDj1XJv0W9N4mOXb5-_3eXtoLRfgXlGGrYuOTBjn9".data(using: .utf8)
    var licenseKeyError: NSError?
    var setSafeTrackingIdsError: NSError?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Security Stats"
        self.statusView?.clipsToBounds = true
        self.statusView?.layer.cornerRadius = 5
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = 5
        
      //  mapView?.isUserInteractionEnabled = false
        locationManager.didUpdateLocations = {(clLocation) in
            if let location = clLocation.last
            {
                print(location)
                self.addMarker(to: location)
            }
        }
        tableView?.isScrollEnabled = false
        tableView!.register(UINib(nibName: "MLSecurityViewCell", bundle: nil), forCellReuseIdentifier: "SecurityViewCell")
        NotificationCenter.default.addObserver(forName: Notification.Name("com.zimperium.zdetection.locationupdate"),
                                    object: nil, queue: OperationQueue.main, using: {(notification: Notification) in
                                     guard let userInfo = notification.userInfo,
                let newLocation = userInfo["newLocation"] as! CLLocation? else {
                    print("Location: can't get the location.")
                    return
                }

                let str = "Location: \(String(describing: newLocation))"
                self.statusView?.text = self.statusView!.text + str + "\n"
        })
        //MLSecurityViewCell
        
//        MARK: Set License Key
        if let zDefendLicense = license {
            ZDetection.setLicenseKey(zDefendLicense, error: &licenseKeyError)
        }

        //MARK: Set Tracking Ids
        ZDetection.setSafeTrackingIds("zIAPDemo1", tag2: "zIAPDemo2", error: &setSafeTrackingIdsError)

        //MARK: Set Data Folder
        do {
            try ZDetection.setDataFolder("Zimperium")
        } catch {
            print(error)
        }

        //MARK: Disable Location
        ZDetection.disableLocation()

        //MARK: Is Rooted or Jailbroken
        DispatchQueue.global(qos: .background).async {
            let jailBroken = ZDetection.isRootedOrJailbroken()
            print("Jailbroken = \(jailBroken)")
            DispatchQueue.main.async {
                self.statusView?.text.append("IsRootedOrJailbroken = \(jailBroken)"+"\n")
            }
        }

        //MARK: Detection State Callback
        ZDetection.addStateCallback{ (old: ZDetectionState?, new: ZDetectionState?) in
            print("DetectionState: old=\(String(describing: old?.stringify())), new=\(String(describing: new?.stringify()))")
            if let newState = new {
                self.statusView?.text.append("New State: "+newState.stringify()+"\n")
            }
            if let oldState = old {
                self.statusView?.text.append("Old State: "+oldState.stringify()+"\n")
            }
        }

        print("Start detectCriticalThreats.")

        //MARK: Detect Critical Threats
        ZDetection.detectCriticalThreats{ (threat: ZThreat?) in
            print("Threat detected: \(String(describing: threat?.getType()))")
            print("\nThreat Name: \(String(describing: threat?.humanThreatName()))")
            print("\nThreat ID: \(String(describing: threat?.threatInternalId))")


            let alert = UIAlertController(title: threat?.humanThreatName(), message: threat?.humanThreatSummary().string, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        //MARK: Threat Disposition
        let disposition: ZThreatDisposition = ZThreatDisposition()
    
        self.statusView?.text.append("Is Device Compromised = "+disposition.isCompromised().description+"\n")
        self.statusView?.text.append("Is Device Rooted = "+disposition.isRooted().description+"\n")
        self.statusView?.text.append("Is Device OSVulnerable = "+disposition.isOsVulnerable().description+"\n")
        self.statusView?.text.append("Is Device BlueBorneVulnerable = "+disposition.isBlueBorneVulnerable().description+"\n")

        if let activeThreats = disposition.getActiveThreats() {
            self.statusView?.text.append("Get Active Threats = " + activeThreats.description + "\n")
            self.statusView?.text.append("Get Active Threats Count = " + String(activeThreats.count) + "\n")

            for threat in activeThreats {
                if let zThreat = threat as? ZThreat {
                    self.statusView?.text.append("\nThreat detected: \(zThreat.humanThreatName())")
                    self.statusView?.text.append("\nThreat ID: \(String(describing: zThreat.threatInternalId()))")
                    self.statusView?.text.append("\nThreat Severity: \(String(describing: zThreat.threatSeverity()))")
                }
            }
        }

        //MARK: ZDetection Info
        let zdetectionInfo: ZDetectionInfo = ZDetectionInfo()
        self.statusView?.text.append("Customer Name=\(zdetectionInfo.customerName())\n")
        self.statusView?.text.append("Privacy Date=\(zdetectionInfo.privacyPolicyDate())\n")
        self.statusView?.text.append("TRM Date=\(zdetectionInfo.threatPolicyDate())\n")
        self.statusView?.text.append("Device ID=\(zdetectionInfo.deviceID())\n")
        self.statusView?.text.append("MDM ID=\(zdetectionInfo.mdmID())\n")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addMarker(to location: CLLocation)
    {
        if(self.annotation == nil)
        {
            self.annotation = MKPointAnnotation()
            self.mapView?.addAnnotation(annotation!)
        }
        UIView.animate(withDuration: 0.3) {
            self.annotation?.coordinate = location.coordinate
        }
        let center = location.coordinate
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView?.setRegion(region, animated: true)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopListening()
    }
    //MARK: SIMULATE ATTACKS
    @IBAction func suspiciousAppAttack(sender: UIButton) {
        self.expectedThreat = SUSPICIOUS_IPA

        let attack: ZSimulatedAttack = ZSimulatedAttack()
        attack.setAttackerGatewayIP("192.0.2.0")
        attack.setAttackerGatewayMac("02:00:5E:10:00:00:00:00")
        attack.setAttackerIP("192.0.2.24")
        attack.setAttackerMAC("02:00:5E:10:00:00:00:FF")
        ZDetection.createZDetectionTester().testSuspiciouAppThreat(attack)
       
    }
    
    @IBAction func deviceCompromised(sender: UIButton) {
        self.expectedThreat = DEVICE_ROOTED
        ZDetection.createZDetectionTester().testThreat(with: self.expectedThreat!)
        
    }
    
    @IBAction func deviceARPMITM(sender: UIButton) {
        self.expectedThreat = ARP_MITM;
        let attack: ZSimulatedAttack = ZSimulatedAttack()
        attack.setAttackerGatewayIP("192.0.2.0")
        attack.setAttackerGatewayMac("02:00:5E:10:00:00:00:00")
        attack.setAttackerIP("192.0.2.24")
        attack.setAttackerMAC("02:00:5E:10:00:00:00:FF")
        ZDetection.createZDetectionTester().testARPMITMThreat(attack)
    }
    
    @IBAction func deviceRogueAccessPoint(sender: UIButton) {
        self.expectedThreat = ROGUE_ACCESS_POINT;
        let attack: ZSimulatedAttack = ZSimulatedAttack()
        attack.setAttackerGatewayIP("192.0.2.0")
        attack.setAttackerGatewayMac("02:00:5E:10:00:00:00:00")
        attack.setAttackerIP("192.0.2.24")
        attack.setAttackerMAC("02:00:5E:10:00:00:00:FF")
        ZDetection.createZDetectionTester().testRogueAccessPointThreat(attack)
    }
    
    @IBAction func deviceSSLStrip(sender: UIButton) {
        self.expectedThreat = SSL_STRIP;

        let attack: ZSimulatedAttack = ZSimulatedAttack()
        attack.setAttackerGatewayIP("192.0.2.0")
        attack.setAttackerGatewayMac("02:00:5E:10:00:00:00:00")
        attack.setAttackerIP("192.0.2.24")
        attack.setAttackerMAC("02:00:5E:10:00:00:00:FF")
        ZDetection.createZDetectionTester().testSSLStripThreat(attack)
    }
    
    //MARK: CHECK DEVICE INTEGRITY
    @IBAction func checkDeviceIntegrity(_ sender: Any) {
        print("Running Device Integrity...")
        self.statusView?.text.append("Running Device Integrity...\n")
        DispatchQueue.global(qos: .background).async {
            ZDetection.checkDeviceIntegrity({
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Device Check", message: "Device integrity check completed.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SecurityViewCell", for: indexPath) as! MLSecurityViewCell
        let disposition: ZThreatDisposition = ZThreatDisposition()
        if (indexPath.row == 0){
            cell.Title.text = "Device Compromised"
            cell.status =  disposition.isCompromised()
            
        }else if (indexPath.row == 1){
            cell.Title.text = "Device Rooted"
            cell.status  = disposition.isRooted()
        }else if (indexPath.row == 2){
            cell.Title.text = "Device OSVulnerable"
            cell.status  = disposition.isOsVulnerable()
        }else if (indexPath.row == 3){
            cell.Title.text = "Device BlueBorneVulnerable"
            cell.status  = disposition.isBlueBorneVulnerable()
        }
        cell.isUserInteractionEnabled = false
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
//            let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
//            //label.textColor = UIColor.red
//        let disposition: ZThreatDisposition = ZThreatDisposition()
//        let labelFont = UIFont(name: "HelveticaNeue-Bold", size: 25)
//        let attributes :Dictionary = [NSAttributedString.Key.font : labelFont]
//
//        // Create attributed string
//
//
//        if (disposition.isCompromised() == true || disposition.isRooted() == true || disposition.isOsVulnerable() == true || disposition.isBlueBorneVulnerable() == true){
//            var attrString = NSAttributedString(string: "Secured", attributes:attributes)
//            label.attributedText = attrString
//        }else{
//            var attrString = NSAttributedString(string: "Secured", attributes:attributes)
//            label.attributedText = attrString
//        }
//
//            return label
//        }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let disposition: ZThreatDisposition = ZThreatDisposition()
//        if (disposition.isCompromised() == true || disposition.isRooted() == true || disposition.isOsVulnerable() == true || disposition.isBlueBorneVulnerable() == true){
//            return "SAI is not Secured"
//        }
//        return "SAI is very Secured"
//
//
//    }
    
}

