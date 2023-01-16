//
//  FindShares.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

final class FindShares: HTTPRequest {
    var ignorable: Bool { return true }
    var params: String
    var path: String { return "findShares" }
    
    init(_ params: String) {
        self.params = params
    }
}

struct FindSharesResult: Codable {
    var msgType: String
    var data: [SecretDistributionDoc]?
    var error: String?
}

struct SecretDistributionDoc: Codable {
    var distributionType: SecretDistributionType?
    var metaPassword: MetaPasswordRequest?
    var secretMessage: EncryptedMessage?
}
