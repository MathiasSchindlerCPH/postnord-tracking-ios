//
//  ContentView.swift
//  PostNordTracking
//
//  Created by Mathias Schindler on 27/06/2024.
//

// Test tracking-ID: 00370730254738217676 | 00370733742650018077

import SwiftUI

struct ContentView: View {
    @State private var recentSearches: [String] = UserDefaults.standard.stringArray(forKey: "RecentSearches") ?? []
    
    @State private var selectedLanguageCode = "en"
    @State private var isTrackingViewActive: Bool = false
    
    @State private var manualSearchId: String = ""
    @State private var tappedRecentSearchId: String = ""
    @State private var trackingViewSearchId: String = ""
    
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
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .navigationTitle("Post Tracking")
                .navigationDestination(isPresented: $isTrackingViewActive) {
                    TrackingView(inputReferenceNumber: trackingViewSearchId, selectedLanguageCode: selectedLanguageCode)
                    .onDisappear {
                        //Only update recent searches after TrackingView closes
                        updateRecentSearches(trackingViewSearchId)
                        
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
    
    private func updateRecentSearches(_ newSearch: String) {
        // Trim leading and trailing whitespace and exit function early if trimmed search is empty/whitespaces/new lines
        let trimmedSearch = newSearch.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else { return }
        
        // Remove existing search if present
        if let index = recentSearches.firstIndex(of: trimmedSearch) {
            recentSearches.remove(at: index)
        }
        // Add new search at the top
        recentSearches.insert(trimmedSearch, at: 0)
        saveRecentSearches()
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }
    
    private func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches() // This call also clears recentSeaches from UserDefaults (bc of saveRecentSearches logic)
    }
}

/*#Preview {
    ContentView()
}*/
