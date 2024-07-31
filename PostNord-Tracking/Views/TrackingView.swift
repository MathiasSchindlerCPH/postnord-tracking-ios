//
//  TrackingView.swift
//  PostNordTracking
//
//  Created by Mathias Schindler on 27/06/2024.
//

import SwiftUI

struct TrackingView: View {
    let inputReferenceNumber: String
    var onDetailsFetched: ((String, String, String) -> Void)? // Modify this line
    
    @State private var isLoading = true
    @State private var showingDetailedInfoModal = false
    
    @State private var shipmentEvents: [ShipmentEvent] = []
    @State private var errorMessage: String?
    
    @State private var statusSummary: String = ""
    @State private var senderName: String = ""
    @State private var receiverAddress: String = ""
    @State private var collectionMethod: String = ""
    @State private var shipmentWeight: String = ""
    
    private var selectedLanguageCode: String {
        let appLanguageCode = Locale.current.language.languageCode?.identifier ?? "en" // Load language from app settings, nb: not on OS-level
        let languageCodeMapping: [String: String] = [
            "en": "en",
            "da": "da",
            "sv": "sv",
            "no": "no",
            "nb": "no", // nb = Norwegian Bokmål
            "fi": "fi"
        ]
        
        return languageCodeMapping[appLanguageCode] ?? "en" // Return the corresponding language code or default to "en"
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if !shipmentEvents.isEmpty {
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(String(format: NSLocalizedString("shipmentDetailsFor", comment: "Shipment details for "), inputReferenceNumber))
                                .font(.headline)
                                .padding(.bottom, 8)
                            Spacer()
                            Button(action: {
                                showingDetailedInfoModal.toggle()
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                    .padding(.trailing, 5)
                            }

                        }
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
                .refreshable {
                    await fetchShipmentDetails()
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
            Task {
                await fetchShipmentDetails()
            }
        }
        .sheet(isPresented: $showingDetailedInfoModal) {
            DetailedInfoModalView(
                statusSummary: statusSummary,
                senderName: senderName,
                shipmentWeight: shipmentWeight,
                receiverAddress: receiverAddress,
                collectionMethod: collectionMethod,
                inputReferenceNumber: inputReferenceNumber // Pass the reference number here
            )
        }
        .onDisappear {
            if let onDetailsFetched = onDetailsFetched {
                let latestEventDescription = shipmentEvents.first?.eventDescription ?? "No events"
                onDetailsFetched(inputReferenceNumber, senderName, latestEventDescription)
            }
        }
    }
    
    private func fetchShipmentDetails() async {
        let languageCode = selectedLanguageCode
                    
        APIManager.fetchShipmentDetails(for: inputReferenceNumber, locale: languageCode) { result in
            switch result {
            case .success(let (statusSummary, shipmentWeight, senderName, receiverAddress, collectionMethod, events)):
                DispatchQueue.main.async {
                    self.collectionMethod = collectionMethod
                    self.receiverAddress = receiverAddress
                    self.shipmentWeight = shipmentWeight
                    self.statusSummary = statusSummary
                    self.senderName = senderName
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

