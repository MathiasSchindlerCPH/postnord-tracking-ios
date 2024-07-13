//
//  TrackingView.swift
//  PostNordTracking
//
//  Created by Mathias Schindler on 27/06/2024.
//

import SwiftUI

struct TrackingView: View {
    let inputReferenceNumber: String
    let selectedLanguageCode: String
    
    @State private var isLoading = true
    @State private var shipmentEvents: [ShipmentEvent] = []
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if !shipmentEvents.isEmpty {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Shipment details for \(inputReferenceNumber)")
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
                    Text("No shipment data found for tracking ID\n\(inputReferenceNumber).")
                        .foregroundColor(.gray)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Tracking Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            APIManager.fetchShipmentDetails(for: inputReferenceNumber, locale: selectedLanguageCode) { result in
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
