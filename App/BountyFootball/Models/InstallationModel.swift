//
//  InstallationModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 22/06/2024.
//

import Foundation
import ParseSwift

struct InstallationModel: ParseInstallation {
    
    var userId: String?
    
    var deviceType: String?
    
    var installationId: String?
    
    var deviceToken: String?
    
    var badge: Int?
    
    var timeZone: String?
    
    var channels: [String]?
    
    var appName: String?
    
    var appIdentifier: String?
    
    var appVersion: String?
    
    var parseVersion: String?
    
    var localeIdentifier: String?
    
    var originalData: Data?
    
    var objectId: String?
    
    var createdAt: Date?
    
    var updatedAt: Date?
    
    var ACL: ParseSwift.ParseACL?
    
    
}
