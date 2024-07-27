//
//  TrackingView.swift
//  PostNordTracking
//
//  Created by Mathias Schindler on 27/06/2024.
//

import SwiftUI

struct TrackingView: View {
    let inputReferenceNumber: String
    
    @State private var isLoading = true
    @State private var shipmentEvents: [ShipmentEvent] = []
    @State private var errorMessage: String?
    
    private var selectedLanguageCode: String {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en" // Retrieves user's preferred language, i.e. "en-US", "da-DK", "sv-SE", etc.
        let languageCodeMapping: [String: String] = [
            "en": "en",
            "da": "da",
            "sv": "sv",
            "no": "no",
            "nb": "no", // Norwegian Bokmål
            "fi": "fi"
        ]
        let languageCode = preferredLanguage.split(separator: "-").first ?? "en"
        
        return languageCodeMapping[String(languageCode)] ?? "en" // Return the corresponding language code or default to "en"
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if !shipmentEvents.isEmpty {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(String(format: NSLocalizedString("shipmentDetailsFor", comment: "Shipment details for "), inputReferenceNumber))
                            .font(.headline)
                            .padding(.bottom, 8)
                        Divider()
                        
                        ForEach(shipmentEvents) { event in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(event.eventTime)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("\(event.locationName), \(event.locationCountry)")
                                    .font(.subheadline)
                                
                                Text(event.eventDescription)
                                    .font(.body)
                            }
                            .padding(.vertical, 8)
                            Divider()
                        }
                    }
                    .padding()
                }
            } else {
                VStack {
                    Text(String(format: NSLocalizedString("noShipmentDataFoundMessage", comment: "No shipment data found for tracking ID\n"), inputReferenceNumber))
                        .foregroundColor(.gray)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(NSLocalizedString("trackingDetailsTitle", comment: "Tracking Details"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let languageCode = selectedLanguageCode
            
            APIManager.fetchShipmentDetails(for: inputReferenceNumber, locale: languageCode) { result in
                switch result {
                case .success(let events):
                    DispatchQueue.main.async {
                        self.shipmentEvents = events
                        self.isLoading = false
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.shipmentEvents = []
                        self.isLoading = false
                    }
                }
            }
        }
    }
}
