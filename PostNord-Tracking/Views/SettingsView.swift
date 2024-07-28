//
//  SettingsView.swift
//  PostNordTracking-2
//
//  Created by Mathias Schindler on 13/07/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        Button(action: openSettings) {
                            HStack {
                                Text(NSLocalizedString("changeLanguageOption", comment: "Change Language"))
                                    .font(.body)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle()) // To make entire row tappable, not just text within
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                VStack {
                    Text("Version \(getAppVersion())")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 16)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle(NSLocalizedString("settingsSectionTitle", comment: "Settings"))
            .background(Color(.systemGroupedBackground))
        }
    }

    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }

    private func getAppVersion() -> String {
        if let infoDictionary = Bundle.main.infoDictionary,
           let version = infoDictionary["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }
}
