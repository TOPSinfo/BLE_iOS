//
//  PeripheralConnectedViewController.swift
//  BLEScanner
//
//  Created by Tops on 17/03/20.
//  Copyright © 2020 GG. All rights reserved.
//
//

import UIKit
import CoreBluetooth

class PeripheralConnectedViewController: UIViewController {
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var rssiLabel: UILabel!
	
    var peripheral: CBPeripheral!
    var centralManager: CBCentralManager!
    
	private var rssiReloadTimer: Timer?
	private var services: [CBService] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		peripheral.delegate = self
		title = peripheral.name
        tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 80.0
		tableView.contentInset.top = 5
		
		rssiReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PeripheralConnectedViewController.refreshRSSI), userInfo: nil, repeats: true)
        self.navigationController?.navigationBar.backgroundColor = .blue

	}
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        rssiReloadTimer?.invalidate()
    }
    
    // Setup Bluetooth central manager
    func setup(with centralManager: CBCentralManager, peripheral: CBPeripheral) {
        self.centralManager = centralManager
        self.peripheral = peripheral
    }
    
// Refresh RSSI Values
	@objc private func refreshRSSI(){
		peripheral.readRSSI()
	}
    
	@objc private func disconnectButtonPressed(_ sender: AnyObject) {
        rssiReloadTimer?.invalidate()
        centralManager.cancelPeripheralConnection(peripheral)
		navigationController?.popToRootViewController(animated: true)
	}
}

// MARK: UITableViewDataSource

extension PeripheralConnectedViewController: UITableViewDataSource{
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return services.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell") as! ServiceTableViewCell
		cell.serviceNameLabel.text = "\(services[indexPath.row].uuid)"
        cell.serviceCharacteristicsButton.addTarget(self, action: #selector(serviceTapped(_:)), for: .touchUpInside)
        cell.serviceCharacteristicsButton.tag = indexPath.row
        
		return cell
	}
    
    @objc func serviceTapped(_ sender:UIButton){
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CharacteriticVC") as! CharacteriticVC
        
        vc.service = services[sender.tag]
        vc.peripheral = self.peripheral
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
}
// MARK: CBPeripheralDelegate
extension PeripheralConnectedViewController: CBPeripheralDelegate {
	func centralManager(_ central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let error = error {
            print("Error connecting peripheral: \(error.localizedDescription)")
        }
	}

	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		if let error = error {
			print("Error discovering services: \(error.localizedDescription)")
		}
		
		peripheral.services?.forEach({ (service) in
            
//            if service.uuid.uuidString.lowercased() == "e059d434-277a-42c5-ba47-0056736d3f7b" {
            services.append(service)
//            }
			tableView.reloadData()
			peripheral.discoverCharacteristics(nil, for: service)
		})
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		if let error = error {
			print("Error discovering service characteristics: \(error.localizedDescription)")
		}
		
		service.characteristics?.forEach({ characteristic in
            if let descriptors = characteristic.descriptors {
                print(descriptors)
            }
            
			print(characteristic.properties)
		})
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                peripheral.readValue(for: characteristic)
                print(characteristic.properties)
            }
        }
	}
	
	func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
		switch RSSI.intValue {
		case -90 ... -60:
			rssiLabel.textColor = .btOrange
			break
		case -200 ... -90:
			rssiLabel.textColor = .btRed
			break
		default:
			rssiLabel.textColor = .btGreen
		}
		
		rssiLabel.text = "\(RSSI)dB"
	}
    

}
