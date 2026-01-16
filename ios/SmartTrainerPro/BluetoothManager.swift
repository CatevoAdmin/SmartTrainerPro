import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var centralManager: CBCentralManager!
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var connectionStatus: String = "Disconnected"
    
    // FTMS Service UUID
    let fitnessMachineServiceUUID = CBUUID(string: "1826")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        print("Starting scan for FTMS devices...")
        centralManager.scanForPeripherals(withServices: [fitnessMachineServiceUUID], options: nil)
        connectionStatus = "Scanning..."
    }
    
    func stopScanning() {
        centralManager.stopScan()
        connectionStatus = "Scan Stopped"
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
        connectionStatus = "Connecting to \(peripheral.name ?? "Device")..."
    }
    
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
            startScanning()
        case .poweredOff:
            print("Bluetooth is powered off")
            connectionStatus = "Bluetooth Off"
        case .unauthorized:
            print("Bluetooth is unauthorized")
            connectionStatus = "Unauthorized"
        case .unknown, .resetting, .unsupported:
            print("Bluetooth state unknown/resetting/unsupported")
            connectionStatus = "Error"
        @unknown default:
            break
        }
    }
    
    // FTMS Characteristics
    let indoorBikeDataCharacteristicUUID = CBUUID(string: "2AD2")
    
    // Heart Rate Service & Characteristics
    let heartRateServiceUUID = CBUUID(string: "180D")
    let heartRateMeasurementCharacteristicUUID = CBUUID(string: "2A37")
    
    @Published var currentPower: Int = 0
    @Published var currentCadence: Int = 0
    @Published var currentHeartRate: Int = 0
    
    // ... existing init ...

    // ... existing startScanning/stopScanning/connect/disconnect ...
    
    // MARK: - CBCentralManagerDelegate
    
    // ... existing state updates ...
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            print("Discovered: \(peripheral.name ?? "Unknown")")
            DispatchQueue.main.async {
                self.discoveredPeripherals.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Device")")
        connectedPeripheral = peripheral
        DispatchQueue.main.async {
            self.connectionStatus = "Connected to \(peripheral.name ?? "Device")"
        }
        peripheral.delegate = self
        peripheral.discoverServices([fitnessMachineServiceUUID, heartRateServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async {
            self.connectionStatus = "Failed to Connect"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        connectedPeripheral = nil
        DispatchQueue.main.async {
            self.connectionStatus = "Disconnected"
        }
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == fitnessMachineServiceUUID {
                print("Discovered FTMS Service")
                peripheral.discoverCharacteristics([indoorBikeDataCharacteristicUUID, fitnessMachineControlPointCharacteristicUUID], for: service)
            } else if service.uuid == heartRateServiceUUID {
                print("Discovered Heart Rate Service")
                peripheral.discoverCharacteristics([heartRateMeasurementCharacteristicUUID], for: service)
            }
        }
    }
    
    // FTMS Control Point
    let fitnessMachineControlPointCharacteristicUUID = CBUUID(string: "2AD9")
    var controlPointCharacteristic: CBCharacteristic?
    
    // Safety Limits
    @Published var wattageCeiling: Int = 150 // Default safe limit
    @Published var targetPower: Int = 0
    @Published var hasControl: Bool = false
    
    // ... existing decoding methods ...
    
    // MARK: - Control Methods
    
    func requestControl() {
        guard let characteristic = controlPointCharacteristic, let peripheral = connectedPeripheral else { return }
        // OpCode 0x00: Request Control
        let command: [UInt8] = [0x00]
        let data = Data(command)
        peripheral.writeValue(data, for: characteristic, type: .write)
        print("Sent Request Control")
    }
    
    func setTargetPower(_ power: Int) {
        // Safety Check: Enforce Ceiling
        let safePower = min(power, wattageCeiling)
        
        guard let characteristic = controlPointCharacteristic, let peripheral = connectedPeripheral else { return }
        
        // Update local state
        DispatchQueue.main.async {
            self.targetPower = safePower
        }
        
        // OpCode 0x05: Set Target Power
        // Parameter: SInt16 (Power in Watts)
        var command: [UInt8] = [0x05]
        let powerValue = Int16(safePower)
        withUnsafeBytes(of: powerValue) { command.append(contentsOf: $0) }
        
        let data = Data(command)
        peripheral.writeValue(data, for: characteristic, type: .write)
        print("Sent Set Target Power: \(safePower)W")
    }
    
    // MARK: - Delegate Updates
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == indoorBikeDataCharacteristicUUID {
                print("Discovered Indoor Bike Data Characteristic")
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == fitnessMachineControlPointCharacteristicUUID {
                print("Discovered Control Point Characteristic")
                controlPointCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic) // Enable indications
            } else if characteristic.uuid == heartRateMeasurementCharacteristicUUID {
                print("Discovered Heart Rate Characteristic")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == indoorBikeDataCharacteristicUUID, let data = characteristic.value {
            decodeIndoorBikeData(data)
        } else if characteristic.uuid == fitnessMachineControlPointCharacteristicUUID, let data = characteristic.value {
            handleControlPointResponse(data)
        } else if characteristic.uuid == heartRateMeasurementCharacteristicUUID, let data = characteristic.value {
            decodeHeartRateData(data)
        }
    }
    
    private func decodeHeartRateData(_ data: Data) {
        // Human Heart Rate Measurement
        // Flags: 1st byte (Bit 0 tells us if it's UInt8 or UInt16)
        guard data.count >= 2 else { return }
        
        let flags = data[0]
        let isUInt16 = (flags & 0x01) != 0
        
        var heartRate: Int = 0
        
        if isUInt16 {
            if data.count >= 3 {
                let value = data.subdata(in: 1..<3).withUnsafeBytes { $0.load(as: UInt16.self) }
                heartRate = Int(value)
            }
        } else {
            heartRate = Int(data[1])
        }
        
        DispatchQueue.main.async {
            self.currentHeartRate = heartRate
        }
    }
    
    private func handleControlPointResponse(_ data: Data) {
        // Response OpCode is 0x80
        guard data.count >= 3 else { return }
        let opCode = data[0]
        if opCode == 0x80 {
            let requestOpCode = data[1]
            let result = data[2]
            
            print("Control Point Response: Req \(requestOpCode) -> Result \(result)")
            
            if requestOpCode == 0x00 && result == 0x01 {
                // Request Control Success
                DispatchQueue.main.async {
                    self.hasControl = true
                }
            }
        }
    }
    
    private func decodeIndoorBikeData(_ data: Data) {
        // ... (existing decoding logic)
        // FTMS Indoor Bike Data Decoding
        // Flags are 16 bits (2 bytes)
        guard data.count >= 2 else { return }
        
        let flags = data.prefix(2).withUnsafeBytes { $0.load(as: UInt16.self) }
        var offset = 2
        
        // Bit 0: More Data (Ignored for now)
        // Bit 1: Average Speed (UInt16, 0.01 km/h) -> if 0, not present
        let speedPresent = (flags & 0x02) != 0
        // Bit 2: Instantaneous Cadence (UInt16, 0.5 rpm)
        let cadencePresent = (flags & 0x04) != 0
        
        if speedPresent {
            offset += 2
        }
        
        if cadencePresent {
            if data.count >= offset + 2 {
                let cadenceValue = data.subdata(in: offset..<offset+2).withUnsafeBytes { $0.load(as: UInt16.self) }
                let cadence = Int(Double(cadenceValue) * 0.5)
                DispatchQueue.main.async {
                    self.currentCadence = cadence
                }
                offset += 2
            }
        }
        
        // Bit 3: Average Cadence (Ignored)
        // Bit 4: Total Distance (Ignored)
        // Bit 5: Resistance Level (Ignored)
        // Bit 6: Instantaneous Power (SInt16, 1 Watt)
//        let powerPresent = (flags & 0x40) != 0
        
        // Reset offset to 2
        offset = 2
        
        if (flags & 0x02) != 0 { offset += 2 } // Speed
        
        if (flags & 0x04) != 0 {
            // Cadence
            if data.count >= offset + 2 {
                let val = data.subdata(in: offset..<offset+2).withUnsafeBytes { $0.load(as: UInt16.self) }
                let cadence = Int(Double(val) * 0.5)
                DispatchQueue.main.async { self.currentCadence = cadence }
                offset += 2
            }
        }
        
        if (flags & 0x08) != 0 { offset += 2 } // Avg Cadence
        if (flags & 0x10) != 0 { offset += 3 } // Total Distance
        if (flags & 0x20) != 0 { offset += 2 } // Resistance Level
        
        if (flags & 0x40) != 0 {
            // Power
            if data.count >= offset + 2 {
                let val = data.subdata(in: offset..<offset+2).withUnsafeBytes { $0.load(as: Int16.self) }
                DispatchQueue.main.async { self.currentPower = Int(val) }
                offset += 2
            }
        }
    }
}
