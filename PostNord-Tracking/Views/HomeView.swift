//
//  HomeView.swift
//  PostNordTracking
//
//  Created by Mathias Schindler on 27/06/2024.
//

// Test tracking-ID: 00370730254738217676 | 00370733742650018077 | 00157128965186828922
// Arbitrary ID: 001571289651868 | 001571289651869 | 001571289651870

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var selectedLanguageCode = "en"
    
    @State private var navigationPath = NavigationPath()
    @State private var showNoRecentSearchesText = false
    
    @State private var manualSearchId: String = ""
    @State private var tappedRecentSearchId: String = ""
    @State private var trackingViewSearchId: String = ""
    
    @State private var recentSearches: [[String: Any]] = UserDefaults.standard.array(forKey: "RecentSearches") as? [[String: Any]] ?? []
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH.mm"
        return formatter
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $navigationPath) {
                VStack {
                    HStack {
                        TextField(NSLocalizedString("enterTrackingIdPlaceholder", comment: "Enter tracking ID"), text: $manualSearchId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                if !manualSearchId.isEmpty {
                                    navigateToTrackingView(search: manualSearchId)
                                }
                            }
                        
                        Button(action: {
                            if !manualSearchId.isEmpty {
                                navigateToTrackingView(search: manualSearchId)
                            }
                        }) {
                            Image(systemName: "plus")
                                .imageScale(.large)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.bottom)
                    
                    // Recent Searches List
                    if !recentSearches.isEmpty {
                        VStack(alignment: .leading) {
                            /*Text(NSLocalizedString("recentSearchesTitle", comment: "Recent Searches"))
                                .font(.headline)
                                .foregroundColor(.gray)*/
                            
                            ScrollView {
                                ForEach(recentSearches.indices.reversed(), id: \.self) { index in
                                    if let parcelId = recentSearches[index]["parcelId"] as? String,
                                       let senderName = recentSearches[index]["senderName"] as? String,
                                       let eventDescription = recentSearches[index]["eventDescription"] as? String,
                                       let statusShort = recentSearches[index]["statusShort"] as? String {
                                        
                                        Button(action: {
                                            tappedRecentSearchId = parcelId
                                            navigateToTrackingView(search: tappedRecentSearchId)
                                        }) {
                                            HStack {
                                                Image(systemName: statusShort.capitalized == "Delivered" ? "checkmark.circle" : "truck.box")
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                                    .foregroundColor(statusShort.capitalized == "Delivered" ? .blue : .blue)
                                                    .padding(.trailing, 8)
                                             
                                                VStack(alignment: .leading) {
                                                    Text(senderName) // Display senderName instead of parcelId
                                                        .padding(.top, 6)
                                                        .padding(.bottom, 2)
                                                    Text(eventDescription)
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                        .lineLimit(1) // Set line limit to 1 for truncation
                                                        .truncationMode(.tail) // Use tail truncation mode to show ellipsis
                                                        .padding(.bottom, 6)
                                                    Divider()
                                                }
                                                .contentShape(Rectangle()) // To make entire row tappable, not just text within
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                             
                                Button(role: .destructive, action: {
                                    withAnimation {
                                        clearRecentSearches()
                                    }
                                }) {
                                    Label(NSLocalizedString("clearRecentSearches", comment: "Clear Recent Searches"), systemImage: "trash")
                                }
                                .padding()
                            }
                        }
                        .transition(.slide.combined(with: .opacity)) // Animation when tab "Clear Recent Searches"
                    } else {
                        VStack {
                            Text(NSLocalizedString("recentSearchesEmptyMessage", comment: "Recent searches will appear here"))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .opacity(showNoRecentSearchesText ? 1 : 0) // Fade in effect
                                .animation(.easeIn(duration: 0.5), value: showNoRecentSearchesText) // Custom duration for fade-in
                                .onAppear {
                                    // Set delay for the fade-in effect
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Adjust delay as needed
                                        withAnimation {
                                            showNoRecentSearchesText = true
                                        }
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .navigationTitle(NSLocalizedString("postTrackingTitle", comment: ""))
                .navigationDestination(for: String.self) { trackingId in
                    TrackingView(inputReferenceNumber: trackingId) { searchId, senderName, latestEventDescription, isRequestSuccessful, statusShort in
                        if isRequestSuccessful {
                            saveRecentSearch(searchId: searchId, 
                                             senderName: senderName,
                                             latestEventDescription: latestEventDescription,
                                             statusShort: statusShort)
                        }
                        manualSearchId = ""
                        trackingViewSearchId = ""
                    }
                }
                .padding()
            }
            .tabItem {
                Label(NSLocalizedString("homeTab", comment: ""), systemImage: "house")
            }
            .tag(0)
            .onChange(of: selectedTab) {
                if selectedTab == 0 {
                    // Reset navigation stack path when Home tab is selected
                    navigationPath = NavigationPath()
                }
            }
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label(NSLocalizedString("settingsTab", comment: ""), systemImage: "gear")
            }
            .tag(1)
        }
    }
    
    private func navigateToTrackingView(search: String) {
        if !manualSearchId.isEmpty {
            trackingViewSearchId = manualSearchId
        } else if !tappedRecentSearchId.isEmpty {
            trackingViewSearchId = tappedRecentSearchId
        }
        navigationPath.append(trackingViewSearchId)
    }
    
    private func saveRecentSearch(searchId: String, senderName: String, latestEventDescription: String, statusShort: String) {
        let trimmedSearchId = searchId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearchId.isEmpty else { return }
        
        let trimmedSenderName = senderName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEventDescription = latestEventDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStatusShort = statusShort.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check if searchId exists in recentSearches and remove if it does (to append at the bottom later)
        if recentSearches.contains(where: { $0["parcelId"] as? String == trimmedSearchId }) {
            recentSearches.removeAll { $0["parcelId"] as? String == trimmedSearchId }
        }
        
        // Save new search to recentSearches
        let newSearch: [String: Any] = ["parcelId": trimmedSearchId,
                                        "senderName": trimmedSenderName,
                                        "eventDescription": trimmedEventDescription,
                                        "statusShort": trimmedStatusShort] 
        recentSearches.append(newSearch)
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }


    
    private func clearRecentSearches() {
        if !recentSearches.isEmpty {
            recentSearches.removeAll()
            UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
            
            // Reset and reapply fade-in animation
            showNoRecentSearchesText = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Short delay before fade-in
                withAnimation {
                    showNoRecentSearchesText = true
                }
            }
        }
    }
}

// #Preview { HomeView() }
