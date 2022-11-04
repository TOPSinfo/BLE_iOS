//
//  CBPeripheral+Name.swift
//  BLEScanner
//
//  Created by Tops on 17/03/20.
//  Copyright © 2020 GG. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBPeripheral {
    var displayName: String {
        guard let name = name, !name.isEmpty else { return "No Device Name" }
        return name
    }
}
