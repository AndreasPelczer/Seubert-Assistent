//
//  CategoryChip.swift
//  Zusatz
//
//  Created by Andreas Pelczer on 25.12.25.
//
import SwiftUI

struct CategoryChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    var activeColor: Color = .blue
    let action: () -> Void // Die Action muss als Letztes definiert sein

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon { Text(icon) }
                Text(title)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? activeColor : Color(UIColor.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}
