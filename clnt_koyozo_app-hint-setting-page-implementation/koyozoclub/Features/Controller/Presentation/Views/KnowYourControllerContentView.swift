//
//  KnowYourControllerContentView.swift
import SwiftUI

struct KnowYourControllerContentView: View {
    let modeChangeSteps: [String]
    let modesTable: FAQTable
    let bluetoothSteps: [String]
    let bluetoothSubSteps: [String]
    let bluetoothFinalSteps: [String]
    let connectionStates: [String]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Steps to change mode
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Steps to change mode")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    ForEach(Array(modeChangeSteps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Text("\(index + 1).")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(step)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                
                // Modes & Platforms table
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Modes & Platforms (Turbo Light Colors)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    ControllerInfoTableView(table: modesTable)
                }
                
                // Steps to connect via Bluetooth
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Steps to connect via bluetooth")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    // First set of steps
                    ForEach(Array(bluetoothSteps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Text("\(index + 1).")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(step)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    // Sub-steps (bullet points)
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        ForEach(bluetoothSubSteps, id: \.self) { subStep in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Text("•")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(subStep)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.leading, Spacing.lg)
                        }
                    }
                    
                    // Final steps (continue numbering)
                    ForEach(Array(bluetoothFinalSteps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Text("\(index + 1).")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            
                            if step.contains("⚠️") {
                                Text(step)
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)
                                    .fixedSize(horizontal: false, vertical: true)
                            } else {
                                Text(step)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                
                // Connection states
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Connection states")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    ForEach(connectionStates, id: \.self) { state in
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Text("•")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            Text(state)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(Spacing.lg)
        }
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()
        
        KnowYourControllerContentView(
            modeChangeSteps: [
                "Hold M + Home (2s). Turbo light will changes color = new mode.",
                "Confirm Turbo Light = Mode."
            ],
            modesTable: FAQTable(
                headers: ["Mode", "Turbo LED", "Home LED"],
                rows: [
                    ["iOS", "Purple (#A615EA)", "BT Connected: Blue"],
                    ["Android HID", "Green (#35D200)", "BT Reconnecting: Blue"]
                ]
            ),
            bluetoothSteps: [
                "Switch to the correct mode (M + Home).",
                "Double-press M → controller enters Bluetooth mode.",
                "Check Home Light:"
            ],
            bluetoothSubSteps: [
                "Blue Breathing = reconnecting",
                "Blue Fast Flashing = searching",
                "Blue Solid = connected"
            ],
            bluetoothFinalSteps: [
                "Enter Search Mode (first-time pairing): Hold Home (5s).",
                "On your device, open Bluetooth Settings."
            ],
            connectionStates: [
                "USB → Purple Solid",
                "Bluetooth Searching → Blue Fast Flashing"
            ]
        )
    }
}
