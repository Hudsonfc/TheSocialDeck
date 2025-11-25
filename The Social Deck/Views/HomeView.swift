//
//  HomeView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack {
                Text("Home")
                    .font(.largeTitle)
                    .foregroundColor(.black)
            }
        }
    }
}

#Preview {
    HomeView()
}
