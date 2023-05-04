//
//  DeviceTableViewCell.swift
//  BLEScanner
//
//  Created by Tops on 17/03/20.
//  Copyright © 2020 GG. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol DeviceCellDelegate: class {
    func didTapConnect(_ cell: DeviceTableViewCell, peripheral: CBPeripheral)
}

class DeviceTableViewCell: UITableViewCell {
	@IBOutlet weak private var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceIdentifierLabel: UILabel!
    @IBOutlet weak private var deviceRssiLabel: UILabel!
	@IBOutlet weak private var connectButton: UIButton!
	
	weak var delegate: DeviceCellDelegate?
	private var displayPeripheral: DisplayPeripheral!
    
    func populate(displayPeripheral: DisplayPeripheral) {
        self.displayPeripheral = displayPeripheral
        deviceNameLabel.text = displayPeripheral.peripheral.displayName//displayName
        deviceIdentifierLabel.text = displayPeripheral.peripheral.identifier.uuidString
        deviceRssiLabel.text = "\(displayPeripheral.lastRSSI)dB"
        connectButton.isHidden = !displayPeripheral.isConnectable
    }
	
	@IBAction private func connectButtonPressed(_ sender: AnyObject) {
		delegate?.didTapConnect(self, peripheral: displayPeripheral.peripheral)
	}
}
