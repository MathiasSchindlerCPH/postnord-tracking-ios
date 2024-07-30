//
//  SettingsView.swift
//  PostNordTracking-2
//
//  Created by Mathias Schindler on 13/07/2024.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @State private var showMailComposer = false
    @State private var mailComposeResult: Result<MFMailComposeResult, Error>? = nil

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        Button(action: openSettings) {
                            HStack {
                                Text(NSLocalizedString("changeLanguageOption", comment: "Change Language"))
                                    .font(.body)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle()) // To make entire row tappable, not just text within
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Section {
                        Button(action: {
                            showMailComposer.toggle()
                        }) {
                            HStack {
                                Text(NSLocalizedString("reportIssueOption", comment: "Report an Issue"))
                                    .font(.body)
                                Spacer()
                                Image(systemName: "envelope")
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(!MFMailComposeViewController.canSendMail())
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                VStack {
                    Text("Version \(getAppVersion())")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 16)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle(NSLocalizedString("settingsSectionTitle", comment: "Settings"))
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showMailComposer) {
                MailView(isShowing: $showMailComposer, result: $mailComposeResult)
            }
        }
    }

    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }

    private func getAppVersion() -> String {
        if let infoDictionary = Bundle.main.infoDictionary,
           let version = infoDictionary["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentationMode: PresentationMode
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentationMode: Binding<PresentationMode>, isShowing: Binding<Bool>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentationMode = presentationMode
            _isShowing = isShowing
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                isShowing = false
                presentationMode.dismiss()
            }
            if let error = error {
                self.result = .failure(error)
            } else {
                self.result = .success(result)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, isShowing: $isShowing, result: $result)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["customersupport@posttracking.dk"])
        vc.setSubject(NSLocalizedString("reportIssueEmailSubject", comment: "Report an Issue"))
        vc.setMessageBody("", isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
