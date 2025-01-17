//
//  LoginSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit
import CryptoKit
import PromiseKit

protocol LoginSceneProtocol {
    func showPendingPopup()
    func showAwaitingAlert()
    func routeNext()
    func alreadyExisted()
    func failed(with error: Error)
    func closePopUp()
}

final class LoginSceneViewModel: CommonViewModel {
    private var tempTimer: Timer? = nil
    private var userService: UsersServiceProtocol
    private var signingManager: Signable
    private var jsonManager: JsonSerealizable
    private var authService: AuthorizationProtocol
    private var vaultService: VaultAPIProtocol
    
    var delegate: LoginSceneProtocol? = nil
    
    //MARK: - INIT
    init(userService: UsersServiceProtocol, signingManager: Signable, jsonManager: JsonSerealizable, authService: AuthorizationProtocol, vaultService: VaultAPIProtocol) {
        self.signingManager = signingManager
        self.userService = userService
        self.jsonManager = jsonManager
        self.authService = authService
        self.vaultService = vaultService
    }
    
    override func loadData() -> Promise<Void> {
        isLoadingData = true
        return firstly {
            checkStatus()
        }.ensure {
            self.isLoadingData = false
        }.asVoid()
    }
    
    //MARK: - REGISTRATION
    func preRegistrationChecking(_ userName: String) -> Promise<Void> {
        isLoadingData = true
        
        guard let userSecurityBox = signingManager.generateKeys(for: userName) else {
            return Promise(error: MetaSecretErrorType.generateUser)
        }
        
        let user = UserSignature(vaultName: userName,
                                 signature: userSecurityBox.signature,
                                 publicKey: userSecurityBox.keyManager.dsa.publicKey,
                                 transportPublicKey: userSecurityBox.keyManager.transport.publicKey,
                                 device: Device())

        return firstly {
            vaultService.getVault(user)
        }.then { result in
            if result.data?.vaultInfo == .Unknown {
                self.userService.deviceStatus = .Pending
                self.userService.userSignature = user
                self.userService.securityBox = userSecurityBox
                self.delegate?.alreadyExisted()
                return Promise().asVoid()
            } else if result.data?.vaultInfo == .NotFound {
                return self.register(user, userSecurityBox, isOwner: true)
            } else {
                self.userService.userSignature = nil
                self.userService.securityBox = nil
                self.userService.deviceStatus = .Unknown
                return Promise().asVoid()
            }
        }.ensure {
            self.isLoadingData = false
        }.asVoid()
    }
    
    func register(_ user: UserSignature, _ userSecurityBox: UserSecurityBox, isOwner: Bool) -> Promise<Void> {
        return firstly {
            authService.register(user)
        }.get { result in
            self.userService.userSignature = user
            self.userService.securityBox = userSecurityBox
            if result.data == .Registered {
                self.userService.deviceStatus = .Member
                self.tempTimer?.invalidate()
                self.tempTimer = nil
                self.delegate?.closePopUp()
                self.delegate?.routeNext()
            } else {
                self.startTimer()
            }
        }.asVoid()
    }
}

private extension LoginSceneViewModel {
    func startTimer() {
        guard self.tempTimer == nil else { return }
        delegate?.showPendingPopup()
        tempTimer = Timer.scheduledTimer(timeInterval: Constants.Common.timerInterval, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: true)
    }
    
    func checkStatus() -> Promise<Void> {
        if userService.deviceStatus == .Pending {
            return firstly {
                vaultService.getVault(nil)
            }.get { result in
                if result.data?.vaultInfo == .Member {
                    self.userService.deviceStatus = .Member
                    self.tempTimer?.invalidate()
                    self.tempTimer = nil
                    self.delegate?.closePopUp()
                    self.delegate?.routeNext()
                } else if result.data?.vaultInfo == .Declined {
                    self.delegate?.closePopUp()
                    self.userService.resetAll()
                    self.delegate?.failed(with: MetaSecretErrorType.declinedUser)
                } else {
                    self.startTimer()
                }
            }.ensure {
                self.isLoadingData = false
            }.asVoid()
        } else {
            return Promise().asVoid()
        }
    }
    
    @objc func fireTimer() {
        checkStatus()
    }
}
