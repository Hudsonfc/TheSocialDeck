//
//  ErrorRecoveryView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ErrorRecoveryView: View {
    let errorMessage: String
    let retryAction: () -> Void
    let dismissAction: (() -> Void)?
    
    init(errorMessage: String, retryAction: @escaping () -> Void, dismissAction: (() -> Void)? = nil) {
        self.errorMessage = errorMessage
        self.retryAction = retryAction
        self.dismissAction = dismissAction
    }
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(Color.red)
            }
            
            VStack(spacing: 12) {
                Text("Error")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text(errorMessage)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            HStack(spacing: 12) {
                if let dismissAction = dismissAction {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        dismissAction()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                            .cornerRadius(12)
                    }
                }
                
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    retryAction()
                }) {
                    Text("Retry")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

