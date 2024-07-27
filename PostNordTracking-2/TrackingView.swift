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
    @State private var showingDetailedInfoModal = false
    
    @State private var shipmentEvents: [ShipmentEvent] = []
    @State private var errorMessage: String?
    
    @State private var statusSummary: String = ""
    @State private var senderName: String = ""
    @State private var receiverAddress: String = ""
    @State private var collectionMethod: String = ""
    @State private var shipmentWeight: String = ""
    
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
                        HStack {
                            Text(String(format: NSLocalizedString("shipmentDetailsFor", comment: "Shipment details for "), inputReferenceNumber))
                                .font(.headline)
                                .padding(.bottom, 8)
                            Spacer()
                            Button(action: {
                                showingDetailedInfoModal.toggle()
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 20)) // Adjust size as needed
                                    .foregroundColor(.blue) // Adjust color as needed
                                    .padding(.trailing, 5) // Adjust right padding as needed
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
        .sheet(isPresented: $showingDetailedInfoModal) {
            DetailedInfoModalView(statusSummary:statusSummary, senderName:senderName, shipmentWeight: shipmentWeight, receiverAddress: receiverAddress, collectionMethod: collectionMethod)
        }
    }
}

struct DetailedInfoModalView: View {
    @Environment(\.dismiss) var dismiss // To handle closing the modal
    
    var statusSummary: String
    var senderName: String
    var shipmentWeight: String
    var receiverAddress: String
    var collectionMethod: String
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text(NSLocalizedString("shipmentStatusModal", comment: "Status"))
                                .font(.subheadline)
                        }
                        Text(statusSummary)
                            .font(.body)
                        Divider()
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                            Text(NSLocalizedString("senderNameModal", comment: "Sender"))
                                .font(.subheadline)
                        }
                        Text(senderName)
                            .font(.body)
                        Divider()
                        
                        HStack {
                            Image(systemName: "bag")
                                .foregroundColor(.blue)
                            Text(NSLocalizedString("collectionMethodModal", comment: "Collection Method"))
                                .font(.subheadline)
                        }
                        Text(collectionMethod)
                            .font(.body)
                        Divider()
                        
                        HStack {
                            Image(systemName: "house")
                                .foregroundColor(.blue)
                            Text(NSLocalizedString("receiverAddressModal", comment: "Receiver Address"))
                                .font(.subheadline)
                        }
                        Text(receiverAddress)
                            .font(.body)
                        Divider()
                        
                        HStack {
                            Image(systemName: "scalemass")
                                .foregroundColor(.blue)
                            Text(NSLocalizedString("shipmentWeightModal", comment: "Weight"))
                                .font(.subheadline)
                        }
                        Text(shipmentWeight)
                            .font(.body)
                        Divider()
                        
                        Spacer()
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Detailed Info") // Optional title for navigation bar
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark") // Use xmark system icon for close button
                            .foregroundColor(.blue) // Adjust color as needed
                    }
                }
            }
        }
    }
}
