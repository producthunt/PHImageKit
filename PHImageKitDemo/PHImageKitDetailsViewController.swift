//
//  PHImageKitDetailsViewController.swift
//  PHImageKit
//
//  Created by Vlado on 1/22/16.
//  Copyright © 2016 ProductHunt. All rights reserved.
//

import UIKit
import PHImageKit

class PHImageKitDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: PHImageView!

    var url : NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.url = url
    }
}
