//
//  ControllerSettingSection.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 17/01/26.
//

//
//
//  ControllerSettingSection.swift
import Foundation

enum ControllerSettingSection: String, CaseIterable, Identifiable {
    // Commented out sections - can be enabled later
    // case mode = "Mode"
    // case connectionType = "Connection type"
    // case controllerTesting = "Controller testing"
    
    case knowYourController = "Know your controller"
    case troubleShooting = "Trouble shooting"
    // case screenMapping = "Screen mapping"
    case generalFAQ = "General FAQ"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
}
