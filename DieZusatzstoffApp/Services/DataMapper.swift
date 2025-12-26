//
//  DataMapper.swift
//  Zusatz
//
//  Created by Andreas Pelczer on 25.12.25.
//
import Foundation

struct AdditiveMapper {
    static let all: [Int: String] = [
        1: "Konservierungsstoffe", 2: "Farbstoff", 3: "Antioxidationsmittel",
        4: "Geschmacksverstärker", 5: "Süßungsmittel", 7: "Phosphat",
        13: "mit Nitritpökelsalz" // usw. nach deiner Liste
    ]
}

struct AllergenMapper {
    static let all: [String: String] = [
        "a": "Ei", "b": "Lactose", "c1": "Weizen", "g": "Soja",
        "h": "Sellerie", "i": "Senf", "n": "Sulfite" // usw.
    ]
}
