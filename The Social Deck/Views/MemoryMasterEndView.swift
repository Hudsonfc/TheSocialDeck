//
//  MemoryMasterEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct MemoryMasterEndView: View {
    let deck: Deck
    let elapsedTime: TimeInterval
    let moves: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti: Bool = false
    @State private var navigateToHomeView: Bool = false
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Checkmark icon
                if showConfetti {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .padding(.bottom, 40)
                }
                
                // Completion text and stats
                VStack(spacing: 24) {
                    Text("Game Complete!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 16) {
                        // Time
                        HStack(spacing: 12) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            Text("Time: \(formatTime(elapsedTime))")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        }
                        
                        // Moves
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            Text("Moves: \(moves)")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Home button
                Button(action: {
                    navigateToHomeView = true
                }) {
                    Text("Home")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showConfetti = true
            }
        }
        .background(
            NavigationLink(
                destination: HomeView(),
                isActive: $navigateToHomeView
            ) {
                EmptyView()
            }
        )
    }
}

#Preview {
    NavigationView {
        MemoryMasterEndView(
            deck: Deck(
                title: "Memory Master",
                description: "Test your memory",
                numberOfCards: 12,
                estimatedTime: "5 min",
                imageName: "Art 1.4",
                type: .memoryMaster,
                cards: [],
                availableCategories: []
            ),
            elapsedTime: 45.5,
            moves: 18
        )
    }
}

