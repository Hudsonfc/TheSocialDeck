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
        ("Time Extension", "⏰", "Timer extended by 3 seconds!", "Save Perk", .green),
        ("Freeze Timer", "⏰", "Timer frozen for 2 seconds!", "Save Perk", .green),
        ("Cooling", "❄️", "Heat reduced by 30%!", "Save Perk", .green),
        
        // Destroy perks
        ("Time Reduction", "💥", "Timer reduced by 2 seconds!", "Destroy Perk", .red),
        ("Force Pass", "💥", "Must pass immediately!", "Destroy Perk", .red),
        ("Double Heat", "💥", "Heat level doubled!", "Destroy Perk", .red),
        ("Speed Time", "⚡", "Timer speeds up 2x for 3 seconds!", "Destroy Perk", .red),
        
        // Neutral perks
        ("Swap Players", "🔄", "Swap with random player!", "Neutral Perk", .orange),
        ("Choose Player", "👆", "Choose who to pass to!", "Neutral Perk", .orange)
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
                                    
                                    Text(perk.icon)
                                        .font(.system(size: 28))
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

