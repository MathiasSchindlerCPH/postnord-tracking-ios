//
//  LanguageSelectionView.swift
//  PostNordTracking-2
//
//  Created by Mathias Schindler on 13/07/2024.
//

import SwiftUI

struct LanguageSelectionView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    // Move the language change section to the top
                    Section {
                        Button(action: openSettings) {
                            HStack {
                                Text(NSLocalizedString("Change Language", comment: ""))
                                    .font(.body)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                // App version section at the bottom
                VStack {
                    Text("Version \(getAppVersion())")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 16)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle(NSLocalizedString("Settings", comment: ""))
            .background(Color(.systemGroupedBackground))
        }
    }

    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }

    private func getAppVersion() -> String {
        // Get the app version from the app's info dictionary
        if let infoDictionary = Bundle.main.infoDictionary,
           let version = infoDictionary["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }
}
