//
//  CharacteristicsDetailVC.swift
//  BLEScanner
//
//  Created by Tops on 17/03/20.
//  Copyright © 2020 GG. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicsDetailVC: UIViewController {
    var peripheral: CBPeripheral!
    var charecter : [CBCharacteristic] = []
    
    var readChar : CBCharacteristic!
    var writeChar : CBCharacteristic!
    var selectedUUID: String = ""
    var characteristic: CBCharacteristic?
    @IBOutlet weak var tv_DeatilVC : UITextView!
    @IBOutlet weak var btn_read : UIButton!
    @IBOutlet weak var btn_write : UIButton!
    @IBOutlet weak var txtValueWrite: UITextField!
    
    var timer : Timer!
    let batteryLevelCharacteristicUUID = CBUUID(string: "2A19")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheral.delegate = self
//        self.btn_read.isHidden = true
//        self.btn_write.isHidden = true
        self.navigationController?.navigationBar.backgroundColor = .blue
    }

    override func viewWillAppear(_ animated: Bool) {
        self.btn_read.isHidden = true
        self.btn_write.isHidden = true
        self.txtValueWrite.isHidden = true
        
        for i in charecter {
            if i.uuid.uuidString == selectedUUID {
                let isReadPermission = self.characteristic?.properties.contains(.read) ?? false
                if isReadPermission {
                    self.btn_read.isHidden = false
                    readChar = i
                     timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
                }
            }
            if i.uuid.uuidString == selectedUUID {
                let isWritePermission = self.characteristic?.properties.contains(.write) ?? false
                if isWritePermission {
                    self.btn_write.isHidden = false
                    self.txtValueWrite.isHidden = false
                    writeChar = i
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let time = self.timer {
            time.invalidate()
        }
    }
    
    // MARK: - Read Characteristic Value
    func readSelectedCharacteristicValue() {
        if let char = self.characteristic {
            if let value = char.value {
                if let character = self.characteristic {
                    if character.uuid == batteryLevelCharacteristicUUID {
                        if let batteryLevel = character.value?.first {
                            self.tv_DeatilVC.text = "\(character.uuid) ==> \(batteryLevel)%"
                        }
                    } else {
                        print("\(character.uuid) ==> \(String(data: value, encoding: .utf8) ?? "")")
                        self.tv_DeatilVC.text = "\(character.uuid) ==> \(String(data: value, encoding: .utf8) ?? "")"
                    }
                }
            } else {
                if char.uuid == batteryLevelCharacteristicUUID {
                    self.tv_DeatilVC.text = "\(char.uuid) ==> 0%"
                }
            }
        }
    }
    
    // Created timer to read device values
    @objc func fireTimer() {
//        if let reader = readChar {
//            peripheral.readValue(for: readChar)
//            print("Timer fired!")
//        }
        self.readSelectedCharacteristicValue()
    }
    
    // Button to read data from device
    @IBAction func readData(_ sender:UIButton) {
//        if let reader = readChar {
//            peripheral.readValue(for: readChar)
//        }
        self.readSelectedCharacteristicValue()
    }
    
    // To clear data
    @IBAction func clearData(_ sender:UIButton) {
        if writeChar == nil {
            return
        }
        
        if writeChar.uuid.uuidString == selectedUUID {
            if writeChar.properties.contains(CBCharacteristicProperties.write) {
                var parameter = NSInteger(1)
                let data = NSData(bytes: &parameter, length: 1)
                peripheral.writeValue(data as Data, for: writeChar, type: .withResponse)
                return
            }
            
            if writeChar.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                var parameter = NSInteger(1)
                let data = NSData(bytes: &parameter, length: 1)
                peripheral.writeValue(data as Data, for: writeChar, type: .withoutResponse)
                return
            }
        }
    }
    
    // to write data  from device
    @IBAction func writeData(_ sender:UIButton) {
        if let text = self.txtValueWrite.text?.trim(), !text.isEmpty {
            self.view.endEditing(true)
            if self.writeChar != nil {
                if self.writeChar.uuid.uuidString == self.selectedUUID {
                    if self.writeChar.properties.contains(CBCharacteristicProperties.write) {
//                      var parameter = UInt8(1)//NSInteger(1)
//                      let data = NSData(bytes: &parameter, length: 1)
                        let data = Data(text.utf8)
                        self.peripheral.writeValue(data as Data, for: self.writeChar, type: .withResponse)
                        return
                    }
                    
                    if self.writeChar.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
//                      var parameter = UInt8(1)
//                      let data = NSData(bytes: &parameter, length: 1)
                        let data = Data(text.utf8)
                        self.peripheral.writeValue(data as Data, for: self.writeChar, type: .withoutResponse)
                        return
                    }
                } else {
                    if self.writeChar.properties.contains(CBCharacteristicProperties.write) {
//                      var parameter = NSInteger(1)
//                      let data = NSData(bytes: &parameter, length: 1)
                        let data = Data(text.utf8)
                        self.peripheral.writeValue(data as Data, for: self.writeChar, type: .withResponse)
                        return
                    }
                    
                    if self.writeChar.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
//                      var parameter = NSInteger(1)
//                      let data = NSData(bytes: &parameter, length: 1)
                        let data = Data(text.utf8)
                        self.peripheral.writeValue(data as Data, for: self.writeChar, type: .withoutResponse)
                        return
                    }
                }
            }
        }
    }
}

//MARK: CBPeripheral delegate method
extension CharacteristicsDetailVC : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print("ERROR didUpdateValue \(e)")
            let str = "ERROR didUpdateValue \(e)"
            self.tv_DeatilVC.text = e.localizedDescription
            self.txtValueWrite.text = ""
            return
        }
        guard let data = characteristic.value else { return }
        
        if data.hexEncodedString().count >= 8 {
            //Get Count From Hex
            let countHex = data.hexEncodedString().prefix(4)
            let countPref = countHex.prefix(2)
            let countSuf = countHex.suffix(2)
            let countSwipedData = countSuf + countPref
            
            var Count = ""
            if let value = UInt16(countSwipedData, radix: 16) {
                print(value)
                Count = "\(value)"
            } else if let value = Int(countSwipedData, radix: 16) {
                print(value)
                Count = "\(value)"
            } else if let value = String.init(data:data, encoding: .utf8) {
                Count = "\(value)"
            }
  
            // Get RPM from Hex
            let RPMHex = data.hexEncodedString().suffix(4)
            let RMPPref = RPMHex.prefix(2)
            let RPMSuf = RPMHex.suffix(2)
            let RPMSwipedData = RPMSuf + RMPPref
            
            var RPM = ""
            if let value = UInt16(RPMSwipedData, radix: 16) {
                print(value)
                RPM = "\(value)"
            } else if let value = Int(RPMSwipedData, radix: 16) {
                print(value)
                RPM = "\(value)"
            } else if let value = String.init(data:data, encoding: .utf8) {
                RPM = "\(value)"
            }
            
            let name = String(data: data, encoding: .utf8)
            self.tv_DeatilVC.text = "Count : \(Count)\nRPM : \(RPM)\nName : \(name ?? "")"
        } else {
            
             var str = ""
            if let value = UInt16(data.hexEncodedString(), radix: 16) {
                print(value)
                str = "\(value)"
            } else if let value = Int(data.hexEncodedString(), radix: 16) {
                print(value)
                str = "\(value)"
            } else if let value = String.init(data:data, encoding: .utf8) {
                str = "\(value)"
            }
            self.tv_DeatilVC.text = "Written value : \(str)"
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print("ERROR didUpdateValue \(e)")
            let str = "ERROR didUpdateValue \(e)"
            self.tv_DeatilVC.text = str
            return
        }
        guard let data = characteristic.value else { return }
        
        if data.hexEncodedString().count >= 8 {
            
            //Get Count From Hex
            let countHex = data.hexEncodedString().prefix(4)
            let countPref = countHex.prefix(2)
            let countSuf = countHex.suffix(2)
            let countSwipedData = countSuf + countPref
            
            var Count = ""
            if let value = UInt16(countSwipedData, radix: 16) {
                print(value)
                Count = "\(value)"
            } else if let value = Int(countSwipedData, radix: 16) {
                print(value)
                Count = "\(value)"
            } else if let value = String.init(data:data, encoding: .utf8) {
                Count = "\(value)"
            }
            
            let RPMHex = data.hexEncodedString().suffix(4)
            let RMPPref = RPMHex.prefix(2)
            let RPMSuf = RPMHex.suffix(2)
            let RPMSwipedData = RPMSuf + RMPPref
            
            var RPM = ""
            if let value = UInt16(RPMSwipedData, radix: 16) {
                print(value)
                RPM = "\(value)"
            } else if let value = Int(RPMSwipedData, radix: 16) {
                print(value)
                RPM = "\(value)"
            } else if let value = String.init(data:data, encoding: .utf8) {
                RPM = "\(value)"
            }
            
            let name = String(data: data, encoding: .utf8)
            self.tv_DeatilVC.text = "Count : \(Count)\n\nRPM : \(RPM)\n\nName : \(name ?? "")"
        } else {
            let batteryPercentage = data.hexEncodedString()
            self.tv_DeatilVC.text = "Battery Percentage : \(batteryPercentage)"
        }
    }
}

// MARK: Data conversion
extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef"
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            let utf8Digits = Array(hexDigits.utf8)
            return String(unsafeUninitializedCapacity: 2 * self.count) { (ptr) -> Int in
                var p = ptr.baseAddress!
                for byte in self {
                    p[0] = utf8Digits[Int(byte / 16)]
                    p[1] = utf8Digits[Int(byte % 16)]
                    p += 2
                }
                return 2 * self.count
            }
        } else {
            let utf16Digits = Array(hexDigits.utf16)
            var chars: [unichar] = []
            chars.reserveCapacity(2 * self.count)
            for byte in self {
                chars.append(utf16Digits[Int(byte / 16)])
                chars.append(utf16Digits[Int(byte % 16)])
            }
            return String(utf16CodeUnits: chars, count: chars.count)
        }
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
