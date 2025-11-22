//
//  CloudSyncManager.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import Foundation
import CloudKit
import Combine

/// Manages iCloud sync status and provides monitoring capabilities
@MainActor
final class CloudSyncManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var syncStatus: SyncStatus = .unknown
    @Published var lastSyncDate: Date?
    @Published var error: CloudError?
    
    private let container = CKContainer.default()
    private var cancellables = Set<AnyCancellable>()
    
    enum SyncStatus {
        case unknown
        case available
        case syncing
        case notSignedIn
        case restricted
        case noNetwork
        case error(String)
        
        var displayText: String {
            switch self {
            case .unknown: return "Checking..."
            case .available: return "Up to date"
            case .syncing: return "Syncing..."
            case .notSignedIn: return "Not signed in to iCloud"
            case .restricted: return "iCloud unavailable"
            case .noNetwork: return "No network connection"
            case .error(let message): return "Error: \(message)"
            }
        }
        
        var icon: String {
            switch self {
            case .unknown: return "cloud"
            case .available: return "checkmark.icloud.fill"
            case .syncing: return "icloud.and.arrow.up"
            case .notSignedIn: return "xmark.icloud"
            case .restricted: return "exclamationmark.icloud"
            case .noNetwork: return "wifi.slash"
            case .error: return "exclamationmark.triangle"
            }
        }
    }
    
    enum CloudError: LocalizedError {
        case notSignedIn
        case restricted
        case networkUnavailable
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .notSignedIn:
                return "You're not signed in to iCloud. Sign in to sync your data across devices."
            case .restricted:
                return "iCloud is restricted on this device. Check your device settings."
            case .networkUnavailable:
                return "Network is unavailable. Your changes will sync when you're back online."
            case .unknown(let error):
                return "iCloud error: \(error.localizedDescription)"
            }
        }
    }
    
    init() {
        checkAccountStatus()
        
        // Monitor account changes
        NotificationCenter.default.publisher(for: .CKAccountChanged)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.checkAccountStatus()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Check if user is signed in to iCloud
    func checkAccountStatus() {
        syncStatus = .unknown
        
        Task {
            do {
                let status = try await container.accountStatus()
                
                await MainActor.run {
                    switch status {
                    case .available:
                        self.isSignedIn = true
                        self.syncStatus = .available
                        self.error = nil
                        
                    case .noAccount:
                        self.isSignedIn = false
                        self.syncStatus = .notSignedIn
                        self.error = .notSignedIn
                        
                    case .restricted:
                        self.isSignedIn = false
                        self.syncStatus = .restricted
                        self.error = .restricted
                        
                    case .couldNotDetermine:
                        self.isSignedIn = false
                        self.syncStatus = .unknown
                        
                    case .temporarilyUnavailable:
                        self.isSignedIn = false
                        self.syncStatus = .noNetwork
                        self.error = .networkUnavailable
                        
                    @unknown default:
                        self.isSignedIn = false
                        self.syncStatus = .unknown
                    }
                }
            } catch {
                await MainActor.run {
                    self.isSignedIn = false
                    self.syncStatus = .error(error.localizedDescription)
                    self.error = .unknown(error)
                }
            }
        }
    }
    
    /// Manually trigger a sync check (SwiftData handles actual syncing automatically)
    func refreshSyncStatus() {
        checkAccountStatus()
        
        // Update last sync date
        lastSyncDate = Date()
    }
    
    /// Open iOS Settings to iCloud section
    func openCloudSettings() {
        if let url = URL(string: "App-prefs:CASTLE") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Notification Name Extension
extension Notification.Name {
    static let CKAccountChanged = NSNotification.Name.CKAccountChanged
}
