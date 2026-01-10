//
//  ToastView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

enum ToastType {
    case success
    case error
    case info
    
    var color: Color {
        switch self {
        case .success:
            return Color.green
        case .error:
            return Color.red
        case .info:
            return Color.primaryAccent
        }
    }
    
    var icon: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
}

struct ToastView: View {
    let message: String
    let type: ToastType
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(type.color)
                
                Text(message)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primaryText)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.cardShadowColor, radius: 12, x: 0, y: 4)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(1000)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var toast: ToastMessage?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let toast = toast {
                ToastView(
                    message: toast.message,
                    type: toast.type,
                    isPresented: Binding(
                        get: { toast != nil },
                        set: { if !$0 { self.toast = nil } }
                    )
                )
                .onAppear {
                    // Auto-dismiss after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            self.toast = nil
                        }
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: toast != nil)
            }
        }
    }
}

struct ToastMessage: Identifiable {
    let id = UUID()
    let message: String
    let type: ToastType
}

extension View {
    func toast(_ toast: Binding<ToastMessage?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

