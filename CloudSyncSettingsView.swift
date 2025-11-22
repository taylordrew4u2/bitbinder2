//
//  CloudSyncSettingsView.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import SwiftUI

struct CloudSyncSettingsView: View {
    @StateObject private var cloudManager = CloudSyncManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Status Section
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: cloudManager.syncStatus.icon)
                            .font(.title2)
                            .foregroundStyle(statusColor)
                            .frame(width: 44, height: 44)
                            .accessibilityHidden(true)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("iCloud Sync")
                                .font(.headline)
                            
                            Text(cloudManager.syncStatus.displayText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if case .syncing = cloudManager.syncStatus {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Status")
                }
                
                // Last Sync Section
                if cloudManager.isSignedIn {
                    Section {
                        HStack {
                            Text("Last Checked")
                            Spacer()
                            if let lastSync = cloudManager.lastSyncDate {
                                Text(lastSync, style: .relative)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Never")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                // Information Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(
                            icon: "icloud",
                            title: "Automatic Sync",
                            description: "Your jokes, set lists, and recordings sync automatically across all devices signed in with the same Apple ID."
                        )
                        
                        Divider()
                        
                        InfoRow(
                            icon: "lock.shield",
                            title: "Private & Secure",
                            description: "All data is encrypted and stored in your private iCloud account. Only you can access it."
                        )
                        
                        Divider()
                        
                        InfoRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Real-time Updates",
                            description: "Changes made on one device appear on all your other devices within seconds."
                        )
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("How it Works")
                }
                
                // Actions Section
                Section {
                    // Refresh button
                    Button {
                        cloudManager.refreshSyncStatus()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Check Sync Status")
                        }
                    }
                    
                    // Open Settings button
                    if !cloudManager.isSignedIn {
                        Button {
                            cloudManager.openCloudSettings()
                        } label: {
                            HStack {
                                Image(systemName: "gear")
                                Text("Open iCloud Settings")
                            }
                        }
                    }
                } header: {
                    Text("Actions")
                }
                
                // Error Section
                if let error = cloudManager.error {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                    .accessibilityHidden(true)
                                
                                Text(error.localizedDescription)
                                    .font(.subheadline)
                            }
                            
                            if case .notSignedIn = error {
                                Button("Sign In to iCloud") {
                                    cloudManager.openCloudSettings()
                                }
                                .buttonStyle(.bordered)
                                .padding(.top, 8)
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Issue")
                    }
                }
                
                // Requirements Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        RequirementRow(
                            icon: "person.circle",
                            text: "Signed in to iCloud",
                            isMet: cloudManager.isSignedIn
                        )
                        
                        RequirementRow(
                            icon: "wifi",
                            text: "Internet connection",
                            isMet: true // Simplified - actual network check would be more complex
                        )
                        
                        RequirementRow(
                            icon: "externaldrive.badge.icloud",
                            text: "iCloud Drive enabled",
                            isMet: cloudManager.isSignedIn
                        )
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Requirements")
                } footer: {
                    Text("All requirements must be met for iCloud sync to work properly.")
                }
            }
            .navigationTitle("iCloud Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                cloudManager.checkAccountStatus()
            }
        }
    }
    
    private var statusColor: Color {
        switch cloudManager.syncStatus {
        case .available:
            return .green
        case .syncing:
            return .blue
        case .notSignedIn, .restricted:
            return .orange
        case .noNetwork:
            return .gray
        case .error:
            return .red
        case .unknown:
            return .gray
        }
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct RequirementRow: View {
    let icon: String
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)
                .accessibilityHidden(true)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: isMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isMet ? .green : .red)
                .accessibilityLabel(isMet ? "Met" : "Not met")
        }
    }
}

#Preview {
    CloudSyncSettingsView()
}
