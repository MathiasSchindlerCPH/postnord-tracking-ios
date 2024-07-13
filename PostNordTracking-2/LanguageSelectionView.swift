//
//  LanguageSelectionView.swift
//  PostNordTracking-2
//
//  Created by Mathias Schindler on 13/07/2024.
//

import SwiftUI

struct LanguageSelectionView: View {
    @Binding var selectedLanguageCode: String

    let languages = ["English": "en", "Danish": "da"]

    var body: some View {
        VStack {
            Text("Select Language")
            Picker(selection: $selectedLanguageCode, label: Text("Select Language")) {
                ForEach(languages.sorted(by: <), id: \.value) { name, code in
                    Text(name).tag(code)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding()
        }
        .navigationTitle("Language Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
