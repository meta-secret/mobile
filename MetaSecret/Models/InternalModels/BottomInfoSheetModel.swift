//
//  BottomInfoSheetModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 10.09.2022.
//

import Foundation
import UIKit

struct BottomInfoSheetModel {
    let title: String?
    let attributedTitle: NSAttributedString?
    let message: String?
    let isClosable: Bool
    let image: UIImage?
    let buttonHandler: (()->())?
    
    init(title: String? = nil, attributedTitle: NSAttributedString? = nil, message: String? = nil, isClosable: Bool = true, image: UIImage? = nil, buttonHandler: (()->())? = nil) {
        self.title = title
        self.attributedTitle = attributedTitle
        self.message = message
        self.buttonHandler = buttonHandler
        self.image = image
        self.isClosable = isClosable
    }
}
