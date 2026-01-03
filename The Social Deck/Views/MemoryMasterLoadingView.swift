//
//  MemoryMasterLoadingView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct MemoryMasterLoadingView: View {
    let deck: Deck
    let difficulty: MemoryMasterDifficulty
    
    @State private var navigateToPlay: Bool = false
    @State private var progress: Double = 0
    @State private var hasStartedLoading: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Game artwork
                Image(deck.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 275)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
                
                // Loading text
                VStack(spacing: 12) {
                    Text("Get Ready!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    Text("Preparing your game...")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                }
                
                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .frame(width: 200 * progress, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
                .frame(width: 200)
                
                Spacer()
            }
            
            // X button to exit
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Only start loading if we haven't started yet (prevents re-triggering when coming back from PlayView)
            if !hasStartedLoading {
                hasStartedLoading = true
            startLoading()
            }
        }
        .background(
            NavigationLink(
                destination: MemoryMasterPlayView(
                    manager: MemoryMasterGameManager(difficulty: difficulty),
                    deck: deck
                ),
                isActive: $navigateToPlay
            ) {
                EmptyView()
            }
        )
    }
    
    private func startLoading() {
        // Animate progress bar
        withAnimation(.easeInOut(duration: 0.5)) {
            progress = 0.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.4)) {
                progress = 0.6
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: 0.3)) {
                progress = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            navigateToPlay = true
        }
    }
}
