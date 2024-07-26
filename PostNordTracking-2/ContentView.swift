//
//  ContentView.swift
//  PostNordTracking
//
//  Created by Mathias Schindler on 27/06/2024.
//

// Test tracking-ID: 00370730254738217676 | 00370733742650018077 | 00157128965186828922

import SwiftUI

struct ContentView: View {
    @State private var selectedLanguageCode = "en"
    @State private var isTrackingViewActive: Bool = false
    
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
        TabView {
            NavigationStack {
                VStack {
                    HStack {
                        TextField("Enter tracking ID", text: $manualSearchId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            if !manualSearchId.isEmpty {
                                navigateToTrackingView(search: manualSearchId)
                            }
                        }) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.bottom)
                    
                    // Recent Searches List
                    if !recentSearches.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recent Searches")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            ScrollView {
                                ForEach(recentSearches.indices.reversed(), id: \.self) { index in
                                    if let parcelId = recentSearches[index]["parcelId"] as? String,
                                       let lastSearchedOn = recentSearches[index]["lastSearchedOn"] as? Int {
                                        
                                        Button(action: {
                                            tappedRecentSearchId = parcelId
                                            navigateToTrackingView(search: tappedRecentSearchId)
                                        }) {
                                            VStack(alignment: .leading) {
                                                Text(parcelId)
                                                    .padding(.top, 6)
                                                    .padding(.bottom, 2)
                                                Text(formatTimestamp(lastSearchedOn))
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                    .padding(.bottom, 6)
                                                Divider()
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                             
                                Button(role: .destructive, action: {
                                    clearRecentSearches()
                                }) {
                                    Label("Clear Recent Searches", systemImage: "trash")
                                }
                                .padding()
                            }
                        }
                    } else {
                        VStack {
                            Text("Recent searches will appear here")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .navigationTitle("Post Tracking")
                .navigationDestination(isPresented: $isTrackingViewActive) {
                    TrackingView(inputReferenceNumber: trackingViewSearchId, selectedLanguageCode: selectedLanguageCode)
                    .onDisappear {
                        //Only update recent searches after TrackingView closes
                        saveRecentSearch(searchId: trackingViewSearchId)
                        
                        // Reset manualSearchId and trackingViewSearchId after closing trackingView
                        manualSearchId = ""
                        trackingViewSearchId = ""
                    }
                }
                .padding()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            NavigationView {
                LanguageSelectionView(selectedLanguageCode: $selectedLanguageCode)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
    
    private func navigateToTrackingView(search: String) {
        if !manualSearchId.isEmpty {
            trackingViewSearchId = manualSearchId
        } else if !tappedRecentSearchId.isEmpty {
            trackingViewSearchId = tappedRecentSearchId
        }
        isTrackingViewActive = true
    }
    
    private func saveRecentSearch(searchId: String) {
        let trimmedSearchId = searchId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearchId.isEmpty else { return }

        let searchedOn = Int(Date().timeIntervalSince1970)
        
        // Check if searchId exists in recentSearches and remove if it does (to append at the bottom later)
        if recentSearches.contains(where: { $0["parcelId"] as? String == trimmedSearchId }) {
            recentSearches.removeAll { $0["parcelId"] as? String == trimmedSearchId }
        }
        
        // Save new search to recentSearches
        let newSearch: [String: Any] = ["parcelId": trimmedSearchId, "lastSearchedOn": searchedOn]
        recentSearches.append(newSearch)
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }
    
    private func clearRecentSearches() {
        if !recentSearches.isEmpty {
            recentSearches.removeAll()
            UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
        }
    }
    
    private func formatTimestamp(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return dateFormatter.string(from: date)
    }
}

/*#Preview {
    ContentView()
}*/
