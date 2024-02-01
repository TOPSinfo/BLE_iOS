//
//  BeaconMonitoringViewController.swift
//  BLE
//
//  Created by Tops on 01/02/24.
//  Copyright © 2024 Tops. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconMonitoringViewController: UIViewController {
    
    @IBOutlet weak var txtBeacon: UITextField!
    @IBOutlet weak var btnStartMonitoring: UIButton!
    
    @IBOutlet weak var lblUUID: UILabel!
    @IBOutlet weak var lblMajor: UILabel!
    @IBOutlet weak var lblMinor: UILabel!
    @IBOutlet weak var lblProximity: UILabel!
    @IBOutlet weak var lblAccuracy: UILabel!
    @IBOutlet weak var lblRssi: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    let txPower = -59 // the transmission power of the beacon, in decibels
    let n = 2.0 // the path-loss exponent
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "iBeacon"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadBeaconData),
                                               name: Notification.Name("refreshBeaconData"),
                                               object: nil)
    }

    @objc func loadBeaconData(notification: NSNotification) {
        if let dict = notification.object as? NSDictionary {
            if let beacon = dict["latestBeacon"] as? CLBeacon {
                self.lblUUID.text = beacon.uuid.uuidString
                self.lblMajor.text = beacon.major.stringValue
                self.lblMinor.text = beacon.minor.stringValue
                self.lblProximity.text = "\(beacon.proximity.rawValue)"
                self.lblAccuracy.text = "\(beacon.accuracy.round(to: 2))"
                self.lblRssi.text = "\(beacon.rssi)"
                
                if beacon.rssi != 0 {
                    let distance = pow(10, (Double(txPower - beacon.rssi) / (10 * n))) // the distance to the beacon, in meters
                    print("Distance: \(distance.round(to:2)) meters")
                    self.lblDistance.text = "\(distance.round(to:2)) meters"
                }
                
                guard let uuid = self.txtBeacon.text else { return }
                if uuid.isEmpty {
                    self.txtBeacon.text = beacon.uuid.uuidString
                }
            }
        }
    }
    
    @IBAction func btnStartMonitoringTapped(_ sender: Any) {
        guard let uuid = self.txtBeacon.text else { return }
        
        if !appDelegate.arrBeacons.contains(uuid) {
            self.view.endEditing(true)
            appDelegate.arrBeacons.append(uuid)
            
            UserDefaults.standard.set(appDelegate.arrBeacons, forKey: "BeaconsMonitoring")
            UserDefaults.standard.synchronize()
            appDelegate.startScanning(beacons: appDelegate.arrBeacons)
        }
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
