//
//  BluetoothManager.swift
//  MacroControllerPad
//
//  Created by KimJunsoo on 3/26/25.
//

import Foundation
import CoreBluetooth

protocol BluetoothManagerDelegate: AnyObject {
    func didDiscoverMac(peripheral: CBPeripheral, rssi: NSNumber)
    func didConnectMac(peripheral: CBPeripheral)
    func didDisconnectMac(peripheral: CBPeripheral, error: Error?)
    func didReceiveData(_ data: Data, from peripheral: CBPeripheral)
}

class BluetoothManager: NSObject {
    static let shared = BluetoothManager()
    private var centralManager: CBCentralManager!
    private var connectedMac: CBPeripheral?
    private var discoveredMacs: [CBPeripheral] = []
    
    private let macroServiceUUID = CBUUID(string: "00001234-0000-1000-8000-00805F9B34FB") // 매크로 서비스 UUID
    private let commandCharacteristicUUID = CBUUID(string: "00001235-0000-1000-8000-00805F9B34FB") // 명령 전송 특성 UUID
    private let responseCharacteristicUUID = CBUUID(string: "00001236-0000-1000-8000-00805F9B34FB") // 응답 수신 특성 UUID
    
    private var commandCharacteristic: CBCharacteristic?
    weak var delegate: BluetoothManagerDelegate?
    private(set) var isScanning: Bool = false
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn, !isScanning else { return }
        
        print("Bluetooth 스캔 시작...")
        
        centralManager.scanForPeripherals(withServices: [macroServiceUUID], options: nil)
        isScanning = true
    }
    
    func stopScanning() {
        guard isScanning else { return }
        
        print("Bluetooth 스캔 중지")
        centralManager.stopScan()
        isScanning = false
    }
    
    func connectToMac(_ peripheral: CBPeripheral) {
        print("Mac에 연결 시도: \(peripheral.name ?? "알 수 없는 기기")")
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnectFromMac() {
        guard let connectedMac = connectedMac else { return }
        
        print("Mac 연결 중지: \(connectedMac.name ?? "알 수 없는 기기")")
        centralManager.cancelPeripheralConnection(connectedMac)
    }
    
    func sendCommand(_ commandData: Data) -> Bool {
        guard let connectedMac = connectedMac, let commandCharacteristic = commandCharacteristic else {
            print("명령을 보낼 수 없음: 연결된 Mac 없음")
            return false
        }
        
        print("Mac으로 명령 전송 중...")
        connectedMac.writeValue(commandData, for: commandCharacteristic, type: .withResponse)
        return true
    }
    
    func launchXcode() -> Bool {
        let command = ["action": "launchApp", "appName": "Xcode"]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: command, options: []) else {
            print("명령 데이터 생성 실패")
            return false
        }
        
        return sendCommand(jsonData)
    }
    
    func getDiscoveredMacs() -> [CBPeripheral] {
        return discoveredMacs
    }
    
    private func isPeripheralDiscovered(_ peripheral: CBPeripheral) -> Bool {
        return discoveredMacs.contains(peripheral)
    }
    
    private func addDiscoveredMac(_ peripheral: CBPeripheral) {
        if !isPeripheralDiscovered(peripheral) {
            discoveredMacs.append(peripheral)
        }
    }
}

// MARK: CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth 켜짐")
            // 자동으로 스캔 시작 (필요시)
            // startScanning()
        case .poweredOff:
            print("Bluetooth 꺼짐")
        case .resetting:
            print("Bluetooth 리셋 중")
        case .unauthorized:
            print("Bluetooth 권한 없음")
        case .unsupported:
            print("Bluetooth 지원되지 않음")
        case .unknown:
            print("Bluetooth 상태 알 수 없음")
        @unknown default:
            print("Bluetooth 알 수 없는 상태")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let peripheralName = peripheral.name ?? "알 수 없는 기기"
        print("Mac 발견: \(peripheralName), RSSI: \(RSSI)")
        
        peripheral.delegate = self
        addDiscoveredMac(peripheral)
        delegate?.didDiscoverMac(peripheral: peripheral, rssi: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Mac 연결됨: \(peripheral.name ?? "알 수 없는 기기")")
        connectedMac = peripheral
        
        peripheral.discoverServices([macroServiceUUID])
        
        delegate?.didConnectMac(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        if let error = error {
            print("Mac 연결 실패: \(error.localizedDescription)")
        } else {
            print("Mac 연결 실패")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("Mac 연결 해제: \(peripheral.name ?? "알 수 없는 기기")")
        
        
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    
}
