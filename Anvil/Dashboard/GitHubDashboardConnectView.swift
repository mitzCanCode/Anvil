//
//  GitHubDashboardConnectView.swift
//  Anvil
//

import SwiftUI

struct GitHubDashboardConnectView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var accessToken = ""

    var body: some View {
        
        
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 52))
                .foregroundStyle(.purple)

            Text("Connect GitHub to use Dashboard")
                .font(.title2.bold())

            Text("Anvil works without an account. Add a GitHub token only to view repository and profile statistics here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            SecureField("GitHub personal access token", text: $accessToken)
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.body.monospaced())
                .padding()
                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            Button {
                Task {
                    await authViewModel.saveAccessToken(accessToken)
                    if authViewModel.hasAccessToken {
                        accessToken = ""
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(authViewModel.isLoading ? "Validating…" : "Connect GitHub")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .disabled(authViewModel.isLoading || accessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if let errorMessage = authViewModel.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Text("Anvil works without an account. Add a GitHub token to view your stats.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 6) {
                Text("Classic token permission:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("repo")
                    .font(.caption.monospaced().weight(.semibold))
                    .foregroundStyle(.primary)

                Text("Read-only. Stored securely in your device’s Keychain.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    GitHubDashboardConnectView()
        .environmentObject(AuthViewModel())
}
