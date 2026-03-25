//
//  JoinRoomView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct JoinRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    @State private var roomCode: String = ""
    @State private var navigateToRoom = false
    @State private var showError = false
    @State private var isValidCode: Bool = false
    @State private var validationMessage: String = ""
    @State private var showErrorRecovery = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)
                    
                    VStack(spacing: 8) {
                        Text("Join Room")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        
                        Text("Enter the room code to join")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                    .multilineTextAlignment(.center)
                    
                    // Room Code Input Section
                    VStack(spacing: 16) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.primaryAccent)
                            .padding(.bottom, 8)
                        
                        // Room Code Input
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Enter Code", text: $roomCode)
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.primaryText)
                                .autocapitalization(.allCharacters)
                                .disableAutocorrection(true)
                                .textInputAutocapitalization(.characters)
                                .padding(.horizontal, 20)
                                .frame(height: 60)
                                .background(isValidCode && !roomCode.isEmpty ? Color.green.opacity(0.1) : (validationMessage.isEmpty ? Color.tertiaryBackground : Color.red.opacity(0.1)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isValidCode && !roomCode.isEmpty ? Color.green : (validationMessage.isEmpty ? Color.clear : Color.red), lineWidth: 2)
                                )
                                .cornerRadius(16)
                                .onChange(of: roomCode) { newValue in
                                    validateRoomCode(newValue)
                                }
                            
                            if !validationMessage.isEmpty {
                                Text(validationMessage)
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(isValidCode ? Color.green : Color.red)
                                    .padding(.horizontal, 4)
                            } else if !roomCode.isEmpty {
                                Text("Room code must be 4 uppercase letters/numbers")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(Color.gray)
                                    .padding(.horizontal, 4)
                            }
                        }
                            .padding(.horizontal, 40)
                    }
                    
                    // Join Button
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        Task {
                            await onlineManager.joinRoom(roomCode: roomCode)
                            
                            if onlineManager.currentRoom != nil {
                                HapticManager.shared.success()
                                navigateToRoom = true
                            } else if onlineManager.errorMessage != nil {
                                HapticManager.shared.error()
                                showError = true
                            }
                        }
                    }) {
                        if onlineManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.primaryAccent)
                                .cornerRadius(16)
                        } else {
                        Text("Join Room")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                                .background(roomCode.isEmpty ? Color.gray : Color.primaryAccent)
                            .cornerRadius(16)
                        }
                    }
                    .disabled(onlineManager.isLoading || roomCode.isEmpty || !isValidCode)
                    .padding(.horizontal, 40)
                    
                    VStack(spacing: 12) {
                        Text("Room Preview")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.tertiaryBackground)
                            .frame(height: 160)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.secondaryText.opacity(0.6))
                                    Text("Room preview will appear here")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondaryText)
                                }
                            )
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .background(
            NavigationLink(
                destination: LobbyView(),
                isActive: $navigateToRoom
            ) {
                EmptyView()
            }
        )
        .alert(currentErrorTitle, isPresented: $showError) {
            Button("OK", role: .cancel) { }
            Button("Retry") {
                Task {
                    await onlineManager.joinRoom(roomCode: roomCode)
                    if onlineManager.currentRoom != nil {
                        HapticManager.shared.success()
                        navigateToRoom = true
                    } else if onlineManager.errorMessage != nil {
                        showError = true
                    }
                }
            }
        } message: {
            Text(getErrorMessage(onlineManager.errorMessage))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryText)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func validateRoomCode(_ code: String) {
        let uppercaseCode = code.uppercased()
        let allowedCharacters = CharacterSet.alphanumerics
        
        // Update to uppercase
        if code != uppercaseCode {
            roomCode = uppercaseCode
            return
        }
        
        // Check length and characters
        if code.isEmpty {
            isValidCode = false
            validationMessage = ""
        } else if code.count < 4 {
            isValidCode = false
            validationMessage = "Code must be 4 characters"
        } else if code.count > 4 {
            isValidCode = false
            validationMessage = "Code must be exactly 4 characters"
        } else if code.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            isValidCode = false
            validationMessage = "Code can only contain letters and numbers"
        } else {
            isValidCode = true
            validationMessage = "Valid code format"
        }
        
        HapticManager.shared.selection()
    }
    
    private func getErrorMessage(_ error: String?) -> String {
        guard let error = error else {
            return "Failed to join room"
        }

        if error.hasPrefix("Room Full:") {
            return "This room is full. Ask the host to increase the player limit or join another room."
        }
        
        // Provide more helpful error messages
        if error.lowercased().contains("not found") || error.lowercased().contains("room not found") {
            return "Room not found. Please check the room code and try again."
        } else if error.lowercased().contains("full") {
            return "This room is full. The maximum number of players has been reached."
        } else if error.lowercased().contains("already") {
            return "You're already in this room or another room. Leave your current room first."
        } else if error.lowercased().contains("progress") || error.lowercased().contains("in progress") {
            return "Cannot join room. A game is currently in progress."
        }
        
        return error
    }

    private var currentErrorTitle: String {
        if onlineManager.errorMessage?.hasPrefix("Room Full:") == true {
            return "Room Full"
        }
        return "Error"
    }
}

#Preview {
    NavigationView {
        JoinRoomView()
    }
}

