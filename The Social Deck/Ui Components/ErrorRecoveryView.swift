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
                    .foregroundColor(.primaryText)
                
                Text(errorMessage)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
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
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.secondaryBackground)
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
                        .background(Color.buttonBackground)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

