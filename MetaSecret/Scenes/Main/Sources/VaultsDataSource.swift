//
//  VaultsDataSource.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

final class VaultsDataSource: MainScreeSourcable {
    func getDataSource(for vault: Vault) -> MainScreenSource {
        var sourceItems = [[CellSetupDate]]()
        var pendingItems = [CellSetupDate]()
        var declinedItems = [CellSetupDate]()
        var memberItems = [CellSetupDate]()
        
        for item in vault.pendingJoins ?? [] {
            
            let cellSource = CellSetupDate()
            
            cellSource.setupCellSource(title: item.device?.deviceName, subtitle: VaultInfoStatus.pending.rawValue, intValue: MainScreenSourceType.Vaults.rawValue, status: .pending, boolValue: true)
            pendingItems.append(cellSource)
        }
        sourceItems.append(pendingItems)
        
        for item in vault.declinedJoins ?? [] {
            let cellSource = CellSetupDate()
            
            cellSource.setupCellSource(title: item.device?.deviceName, subtitle: VaultInfoStatus.declined.rawValue, intValue: MainScreenSourceType.Vaults.rawValue, status: .declined)
            declinedItems.append(cellSource)
        }
        sourceItems.append(declinedItems)
        
        for item in vault.signatures ?? [] {
            let cellSource = CellSetupDate()
            
            cellSource.setupCellSource(title: item.device?.deviceName, subtitle: VaultInfoStatus.member.rawValue, intValue: MainScreenSourceType.Vaults.rawValue, status: .member)
            memberItems.append(cellSource)
        }
        sourceItems.append(memberItems)
        
        let source = MainScreenSource()
        source.items = sourceItems
        return source
    }
}
