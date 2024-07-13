//
//  LanguageSelectionView.swift
//  PostNordTracking-2
//
//  Created by Mathias Schindler on 13/07/2024.
//

import SwiftUI

struct LanguageSelectionView: View {
    @Binding var selectedLanguageCode: String

    let languages = ["English":"en",
                     "Danish":"da",
                     "Swedish":"sv",
                     "Norwegian":"no",
                     "Finnish":"fi" ]
    let languageOrder = ["English", "Danish", "Swedish", "Norwegian", "Finnish"] // Necessary for order maintained after build.

    var body: some View {
        VStack {
            Text("Select Language")
            Picker(selection: $selectedLanguageCode, label: Text("Select Language for Tracking Info")) {
                ForEach(languageOrder, id: \.self) { key in
                    Text(key).tag(languages[key]!)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
