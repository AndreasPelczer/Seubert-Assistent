//
//  ScanResult.swift
//  Zusatz
//
//  Created by Andreas Pelczer on 24.12.25.
//
import Foundation

struct ScanResult: Identifiable {
    let id = UUID()
    let content: String
    let timestamp = Date()
}
