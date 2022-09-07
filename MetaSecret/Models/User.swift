//
//  User.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation

final class User: Codable {
    let userName: String
    
    let publicKey: Data
    let privateKey: Data
    
    let publicRSAKey: Data
    let privateRSAKey: Data
    
    let deviceName: String
    let deviceID: String
    
    private(set) var signature: Data? = nil
    
    init(userName: String, deviceName: String, deviceID: String, publicKey: Data, privateKey: Data, publicRSAKey: Data, privateRSAKey: Data) {
        self.userName = userName
        self.deviceName = deviceName
        self.deviceID = deviceID
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.publicRSAKey = publicRSAKey
        self.privateRSAKey = privateRSAKey
    }
    
    func addSignature(_ signature: Data) {
        self.signature = signature
    }
}
