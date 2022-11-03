//
//  Accept.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

class Accept: HTTPRequest, UD {
    typealias ResponseType = AcceptResult
    var params: [String : Any]?
    var path: String = "accept"
    
    init(candidate: Vault) {
        guard let member = mainUser else { return }
        
        self.params = ["member": ["vaultName": member.name(),
                                  "device": ["deviceName": member.deviceName, "deviceId": member.deviceId],
                                  "publicKey": member.publicKey(),
                                  "rsaPublicKey": member.transportPublicKey(),
                                  "signature": member.userSignature()],
                       "candidate": ["vaultName": candidate.vaultName ?? "",
                                     "device": ["deviceName": candidate.device?.deviceName, "deviceId": candidate.device?.deviceId],
                                     "publicKey": candidate.publicKey ?? "",
                                     "rsaPublicKey": candidate.transportPublicKey ?? "",
                                     "signature": candidate.signature ?? ""]]
    }
}

struct AcceptResult: Codable {
    var status: String?
}
