//
//  TrackingViewModal.swift
//  PostNord-Tracking
//
//  Created by Mathias Schindler on 31/07/2024.
//

import SwiftUI

struct DetailedInfoModalView: View {
    @Environment(\.dismiss) var dismiss // Handles closing the modal
    
    var statusSummary: String
    var senderName: String
    var shipmentWeight: String
    var receiverAddress: String
    var collectionMethod: String
    var inputReferenceNumber: String // New property to store the reference number
    
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
                        InfoSection(icon: "tag", title: NSLocalizedString("shipmentTrackingIdModal", comment: "Status"), content: inputReferenceNumber)
                        
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
