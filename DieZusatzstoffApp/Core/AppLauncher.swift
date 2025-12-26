//
//  AppLauncher.swift
//  Zusatz
//
//  Created by Andreas Pelczer on 24.12.25.
//
import SwiftUI

@main
struct DieZusatzstoffApp: App {
    // Falls du Core Data oder Persistence nutzt, kannst du es hier lassen,
    // für unser 2-Wochen-Projekt reicht die MainScannerView.
    
    var body: some Scene {
        WindowGroup {
            MainScannerView()
        }
    }
}
