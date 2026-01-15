//
//  ControllerManager.swift
import Foundation
import GameController
import Combine

protocol ControllerManagerProtocol {
    var isConnected: Bool { get }
    var onButtonAPressed: PassthroughSubject<Void, Never> { get }
    var onButtonXPressed: PassthroughSubject<Void, Never> { get }
    var onButtonYPressed: PassthroughSubject<Void, Never> { get }
    var onButtonBPressed: PassthroughSubject<Void, Never> { get }
    var onMenuButtonPressed: PassthroughSubject<Void, Never> { get }
    var onDPadLeft: PassthroughSubject<Void, Never> { get }
    var onDPadRight: PassthroughSubject<Void, Never> { get }
    var onDPadUp: PassthroughSubject<Void, Never> { get }
    var onDPadDown: PassthroughSubject<Void, Never> { get }
    
    func startMonitoring()
    func stopMonitoring()
}

final class ControllerManager: ControllerManagerProtocol {
    static let shared = ControllerManager()
    
    private var controller: GCController?
    private var notificationObservers: [NSObjectProtocol] = []
    
    var isConnected: Bool {
        return controller != nil
    }
    
    let onButtonAPressed = PassthroughSubject<Void, Never>()
    let onButtonXPressed = PassthroughSubject<Void, Never>()
    let onButtonYPressed = PassthroughSubject<Void, Never>()
    let onButtonBPressed = PassthroughSubject<Void, Never>()
    let onMenuButtonPressed = PassthroughSubject<Void, Never>()
    let onDPadLeft = PassthroughSubject<Void, Never>()
    let onDPadRight = PassthroughSubject<Void, Never>()
    let onDPadUp = PassthroughSubject<Void, Never>()
    let onDPadDown = PassthroughSubject<Void, Never>()
    
    private var lastDPadPressTime: [GCControllerDirectionPad: Date] = [:]
    private let dPadThrottleInterval: TimeInterval = 0.2 // Prevent rapid firing
    
    private init() {
        setupControllerNotifications()
    }
    
    func startMonitoring() {
        // Check for already connected controllers
        if let connectedController = GCController.controllers().first {
            connectController(connectedController)
        }
    }
    
    func stopMonitoring() {
        disconnectController()
        notificationObservers.forEach { NotificationCenter.default.removeObserver($0) }
        notificationObservers.removeAll()
    }
    
    private func setupControllerNotifications() {
        // Listen for controller connections
        let connectedObserver = NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let controller = notification.object as? GCController {
                self?.connectController(controller)
            }
        }
        notificationObservers.append(connectedObserver)
        
        // Listen for controller disconnections
        let disconnectedObserver = NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let controller = notification.object as? GCController,
               controller == self?.controller {
                self?.disconnectController()
            }
        }
        notificationObservers.append(disconnectedObserver)
    }
    
    private func connectController(_ controller: GCController) {
        self.controller = controller
        setupControllerInputs(controller)
        print("🎮 Controller connected: \(controller.vendorName ?? "Unknown")")
    }
    
    private func disconnectController() {
        self.controller = nil
        print("🎮 Controller disconnected")
    }
    
    private func setupControllerInputs(_ controller: GCController) {
        // Handle extended gamepad (Xbox, PlayStation, etc.)
        if let extendedGamepad = controller.extendedGamepad {
            setupExtendedGamepad(extendedGamepad)
        }
        // Handle micro gamepad (Apple TV remote, etc.)
        else if let microGamepad = controller.microGamepad {
            setupMicroGamepad(microGamepad)
        }
    }
    
    private func setupExtendedGamepad(_ gamepad: GCExtendedGamepad) {
        // A Button (Confirm/Launch)
        gamepad.buttonA.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.onButtonAPressed.send()
            }
        }
        
        // X Button (Details)
        gamepad.buttonX.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.onButtonXPressed.send()
            }
        }
        
        // Y Button (Search)
        gamepad.buttonY.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.onButtonYPressed.send()
            }
        }
        
        // B Button (Back)
        gamepad.buttonB.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.onButtonBPressed.send()
            }
        }
        
        // Menu Button
        gamepad.buttonMenu.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.onMenuButtonPressed.send()
            }
        }
        
        // D-Pad Left/Right/Up/Down for navigation
        gamepad.dpad.valueChangedHandler = { [weak self] dpad, xValue, yValue in
            guard let self = self else { return }
            
            let lastPressTime = self.lastDPadPressTime[dpad] ?? Date.distantPast
            let now = Date()
            
            if now.timeIntervalSince(lastPressTime) < self.dPadThrottleInterval {
                return // Throttle rapid presses
            }
            
            if xValue < -0.5 {
                // Left
                self.lastDPadPressTime[dpad] = now
                self.onDPadLeft.send()
            } else if xValue > 0.5 {
                // Right
                self.lastDPadPressTime[dpad] = now
                self.onDPadRight.send()
            } else if yValue > 0.5 {
                // Up
                self.lastDPadPressTime[dpad] = now
                self.onDPadUp.send()
            } else if yValue < -0.5 {
                // Down
                self.lastDPadPressTime[dpad] = now
                self.onDPadDown.send()
            }
        }
        
        // Left Thumbstick (alternative navigation)
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] thumbstick, xValue, yValue in
            guard let self = self else { return }
            
            let lastPressTime = self.lastDPadPressTime[thumbstick] ?? Date.distantPast
            let now = Date()
            
            if now.timeIntervalSince(lastPressTime) < self.dPadThrottleInterval {
                return
            }
            
            if xValue < -0.5 {
                self.lastDPadPressTime[thumbstick] = now
                self.onDPadLeft.send()
            } else if xValue > 0.5 {
                self.lastDPadPressTime[thumbstick] = now
                self.onDPadRight.send()
            } else if yValue > 0.5 {
                self.lastDPadPressTime[thumbstick] = now
                self.onDPadUp.send()
            } else if yValue < -0.5 {
                self.lastDPadPressTime[thumbstick] = now
                self.onDPadDown.send()
            }
        }
    }
    
    private func setupMicroGamepad(_ gamepad: GCMicroGamepad) {
        // A Button
        gamepad.buttonA.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.onButtonAPressed.send()
            }
        }
        
        // X Button
        gamepad.buttonX.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.onButtonXPressed.send()
            }
        }
        
        // D-Pad
        gamepad.dpad.valueChangedHandler = { [weak self] dpad, xValue, yValue in
            guard let self = self else { return }
            
            let lastPressTime = self.lastDPadPressTime[dpad] ?? Date.distantPast
            let now = Date()
            
            if now.timeIntervalSince(lastPressTime) < self.dPadThrottleInterval {
                return
            }
            
            if xValue < -0.5 {
                self.lastDPadPressTime[dpad] = now
                self.onDPadLeft.send()
            } else if xValue > 0.5 {
                self.lastDPadPressTime[dpad] = now
                self.onDPadRight.send()
            } else if yValue > 0.5 {
                self.lastDPadPressTime[dpad] = now
                self.onDPadUp.send()
            } else if yValue < -0.5 {
                self.lastDPadPressTime[dpad] = now
                self.onDPadDown.send()
            }
        }
    }
}

