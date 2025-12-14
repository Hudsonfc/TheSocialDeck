//
//  PerksBreakdownView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct PerksBreakdownView: View {
    @Environment(\.dismiss) private var dismiss
    
    let allPerks: [(name: String, icon: String, description: String, type: String, color: Color)] = [
        // Save perks
        ("Time Extension", "plus.circle.fill", "Timer extended by 3 seconds!", "Save Perk", Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0)),
        ("Freeze Timer", "snowflake", "Timer frozen for 2 seconds!", "Save Perk", Color(red: 0x5A/255.0, green: 0xC9/255.0, blue: 0xFF/255.0)),
        ("Cooling", "thermometer.snowflake", "Heat reduced by 30%!", "Save Perk", Color(red: 0x87/255.0, green: 0xCE/255.0, blue: 0xEB/255.0)),
        
        // Destroy perks
        ("Time Reduction", "minus.circle.fill", "Timer reduced by 2 seconds!", "Destroy Perk", Color(red: 0xFF/255.0, green: 0x3B/255.0, blue: 0x30/255.0)),
        ("Force Pass", "arrow.right.circle.fill", "Must pass immediately!", "Destroy Perk", Color(red: 0xFF/255.0, green: 0x6B/255.0, blue: 0x00/255.0)),
        ("Double Heat", "flame.fill", "Heat level doubled!", "Destroy Perk", Color(red: 0xFF/255.0, green: 0x45/255.0, blue: 0x00/255.0)),
        ("Speed Time", "bolt.fill", "Timer speeds up 2x for 3 seconds!", "Destroy Perk", Color(red: 0xFF/255.0, green: 0xD7/255.0, blue: 0x00/255.0)),
        
        // Neutral perks
        ("Swap Players", "arrow.triangle.2.circlepath", "Swap with random player!", "Neutral Perk", Color(red: 0xAF/255.0, green: 0x52/255.0, blue: 0xDE/255.0)),
        ("Choose Player", "hand.point.up.fill", "Choose who to pass to!", "Neutral Perk", Color(red: 0xFF/255.0, green: 0x95/255.0, blue: 0x00/255.0))
    ]
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    }
                    
                    Spacer()
                    
                    Text("All Perks")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    Spacer()
                    
                    // Invisible button for centering
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.clear)
                    }
                    .disabled(true)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(allPerks, id: \.name) { perk in
                            HStack(spacing: 16) {
                                // Icon
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    perk.color.opacity(0.2),
                                                    perk.color.opacity(0.05)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: perk.icon)
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundColor(perk.color)
                                }
                                
                                // Content
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Text(perk.name)
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                        
                                        // Type badge
                                        Text(perk.type)
                                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(perk.color)
                                            .cornerRadius(8)
                                    }
                                    
                                    Text(perk.description)
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                }
                                
                                Spacer()
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(perk.color.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationView {
        PerksBreakdownView()
    }
}

