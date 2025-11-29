//
//  SplashView.swift
//  onthisday
//
//  Created by Kevin Rapkin on 11/28/25.
//


import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                // Logo image in the center
                Image("OnThisDayLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

                Text("Kevin Rapkin, Z15183142")
                    .font(.title2.weight(.medium))
            }
        }
    }
}
