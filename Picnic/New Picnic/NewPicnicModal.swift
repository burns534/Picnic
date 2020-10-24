//
//  NewPicnicModal.swift
//  Picnic
//
//  Created by Kyle Burns on 10/17/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import PhotosUI

protocol NewPicnicModalDelegate: AnyObject {
    func confirm(_ sender: NewPicnicModal)
}

class NewPicnicModal: ReviewCreationController {
    let nameStage = PicnicNameStage(frame: .zero)
    let tagStage = PicnicTagStage(frame: .zero)
    weak var delegate: NewPicnicModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pushStage(nameStage)
        insertStage(tagStage, at: 3)
        contentStage.contentLabel.text = "Give a brief description"
    }
// MARK: Do not call super handler because it makes reviews
    override func confirmationHandler() {
        delegate?.confirm(self)
    }
}
