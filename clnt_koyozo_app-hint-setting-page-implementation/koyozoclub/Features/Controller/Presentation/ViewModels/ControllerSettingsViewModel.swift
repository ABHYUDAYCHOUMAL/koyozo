//
//  ControllerSettingsViewModel.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 17/01/26.
//

//
//  ControllerSettingsViewModel.swift
import Foundation
import SwiftUI
import Combine

class ControllerSettingsViewModel: ViewModelProtocol {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var selectedSection: ControllerSettingSection = .knowYourController
    @Published var expandedFAQIds: Set<UUID> = []
    
    private let fetchFAQsUseCase: FetchFAQsUseCase
    
    init(fetchFAQsUseCase: FetchFAQsUseCase? = nil) {
        self.fetchFAQsUseCase = fetchFAQsUseCase ?? FetchFAQsUseCase()
    }
    
    // Know Your Controller data
    let modeChangeSteps = [
        "Hold M + Home (2s). Turbo light will changes color = new mode.",
        "Confirm Turbo Light = Mode.",
        "Confirm Home Light = Connection (USB/Bluetooth).",
        "Controller remembers last mode even after power off."
    ]
    
    let modesTable = FAQTable(
        headers: ["Mode", "Turbo LED (Mode Indicator)", "Home LED (Connection Status)"],
        rows: [
            ["iOS", "Purple (#A615EA)", "BT Connected: Blue (Solid)"],
            ["Android HID", "Green (#35D200)", "BT Reconnecting: Blue (breathing)"],
            ["Dinput Mode", "Blue (#0B81DD)", "BT Searching: Blue (fast flashing)"],
            ["Switch Mode", "Red (#EC354C)", "USB: Purple (Solid)"],
            ["Virtual Mapping", "Orange (#EC7E14)", "Error: Red (solid)"]
        ]
    )
    
    let bluetoothConnectionSteps = [
        "Switch to the correct mode (M + Home).",
        "Double-press M → controller enters Bluetooth mode.",
        "Check Home Light:"
    ]
    
    let bluetoothConnectionSubSteps = [
        "Blue Breathing = reconnecting",
        "Blue Fast Flashing = searching",
        "Blue Solid = connected"
    ]
    
    let bluetoothConnectionFinalSteps = [
        "Enter Search Mode (first-time pairing): Hold Home (5s) → Home light flashes Blue rapidly.",
        "On your device, open Bluetooth Settings.",
        "Select the correct controller name.",
        "Once connected, Home light stays Blue Solid.",
        "⚠️ If not paired within 60s → controller falls back to USB."
    ]
    
    let connectionStates = [
        "USB → Purple Solid",
        "Bluetooth Searching → Blue Fast Flashing",
        "Bluetooth Reconnecting → Blue Breathing",
        "Bluetooth Connected → Blue Solid",
        "Error → Red Solid"
    ]
    
    // Troubleshooting FAQs - HARDCODED (not from API)
    let troubleshootingFAQs: [FAQItem] = [
        FAQItem(
            question: "Bluetooth not pairing",
            answer: .steps([
                "Double-press M → Home light turns Blue.",
                "Check Home light:",
                "  • Blue Breathing = reconnecting",
                "  • Blue Fast Flashing = searching",
                "Hold Home (5s) → enter Search Mode (light flashes rapidly).",
                "On your device, go to Bluetooth Settings → select controller name.",
                "Once connected, Home light stays Blue Solid.",
                "Last Step: Reset controller (Left Back + Right Back + Left Shoulder + Home, 5s)."
            ])
        ),
        FAQItem(
            question: "USB not recognized",
            answer: .steps([
                "Remove your phone's case cover.",
                "Disconnect & reconnect cable firmly.",
                "On Android, enable OTG in settings.",
                "Clean phone's charging port.",
                "Make sure controller is in the correct mode.",
                "Last Step: Reset controller (hold combo above)."
            ])
        ),
        FAQItem(
            question: "Mode confusion",
            answer: .stepsWithTable([
                "Check Turbo light color:",
                "  • Purple = iOS / PlayStation",
                "  • Green = Android",
                "  • Blue = Xbox / PC",
                "  • Red = Switch / Emulators",
                "Switch mode: Hold M + Home (2s).",
                "Confirm color matches your device.",
                "Last Step: Reset controller if stuck."
            ], nil)
        ),
        FAQItem(
            question: "Calibration Issues (Joystick Drift / Gyro Offset)",
            answer: .steps([
                "Hold Right Shoulder + Start + Home (2s) → Home light turns Red.",
                "Rotate both joysticks 3× times.",
                "Press any trigger 3 times.",
                "Place controller flat on surface.",
                "Press Home → Home light turns Purple = calibration complete.",
                "Last Step: Reset controller if calibration fails."
            ])
        ),
        FAQItem(
            question: "Frozen or Unresponsive",
            answer: .steps([
                "Hold Left Back + Right Back + Left Shoulder + Home (5s).",
                "Controller will reset and restart.",
                "Reconnect via USB or Bluetooth."
            ])
        )
    ]
    
    // General FAQs - will be fetched from API
    @Published var generalFAQs: [FAQItem] = []
    
    func toggleFAQ(_ id: UUID) {
        if expandedFAQIds.contains(id) {
            expandedFAQIds.remove(id)
        } else {
            expandedFAQIds.insert(id)
        }
    }
    
    func isFAQExpanded(_ id: UUID) -> Bool {
        expandedFAQIds.contains(id)
    }
    
    // Fetch General FAQs from API
    func fetchGeneralFAQs() {
        Task {
            isLoading = true
            do {
                let allFAQs = try await fetchFAQsUseCase.execute()
                
                await MainActor.run {
                    // All FAQs from API go to General FAQ section
                    generalFAQs = allFAQs
                    isLoading = false
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load FAQs: \(error.localizedDescription)"
                    isLoading = false
                    // Keep empty array on error
                    generalFAQs = []
                }
            }
        }
    }
}
