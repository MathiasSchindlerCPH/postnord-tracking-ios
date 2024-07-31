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
                collectionMethod: collectionMethod
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

struct DetailedInfoModalView: View {
    @Environment(\.dismiss) var dismiss // Handles closing the modal
    
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
                        InfoSection(icon: "info.circle", title: NSLocalizedString("shipmentStatusModal", comment: "Status"), content: statusSummary)
                        InfoSection(icon: "person.fill", title: NSLocalizedString("senderNameModal", comment: "Sender"), content: senderName)
                        InfoSection(icon: "bag", title: NSLocalizedString("collectionMethodModal", comment: "Collection Method"), content: collectionMethod)
                        InfoSection(icon: "house", title: NSLocalizedString("receiverAddressModal", comment: "Receiver Address"), content: receiverAddress)
                        InfoSection(icon: "scalemass", title: NSLocalizedString("shipmentWeightModal", comment: "Weight"), content: shipmentWeight)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle(NSLocalizedString("detailedViewModal", comment: "Detailed Info"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct InfoSection: View {
    var icon: String
    var title: String
    var content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.subheadline)
            }
            Text(content)
                .font(.body)
                .padding(.bottom, 10)
            
            Divider()
        }
        .padding(.top, 5)
    }
}
