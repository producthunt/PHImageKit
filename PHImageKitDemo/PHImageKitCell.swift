//
//  PHImageKitCell.swift
//  PHImageKit
//
//  Created by Vlado on 1/22/16.
//  Copyright © 2016 ProductHunt. All rights reserved.
//

import UIKit
import PHImageKit

class PHImageKitCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: PHImageView!

    override var highlighted : Bool {
        set {
            super.highlighted = false
        }
        get {
            return super.highlighted
        }
    }

    override var selected: Bool {
        set {
            super.selected = false
        }
        get {
            return super.selected
        }
    }

}
