//
//  Welcome.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/6/25.
//

import SwiftUI

struct Welcome: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image("OnboardingLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 108, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 16, y: 6)

            VStack(spacing: 12) {
                Text("Countie")
                    .font(.largeTitle)
                    .bold()
                Text("Good things take time.")
                    .foregroundStyle(.secondary)
                Text("We'll keep it track for you.")
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .padding(28)
    }
}

#Preview {
    Welcome()
}
