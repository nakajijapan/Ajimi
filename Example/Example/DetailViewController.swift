//
//  DetailViewController.swift
//  Example
//
//  Created by nakajijapan on 2017/07/19.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    func configureView() {
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    var detailItem: NSDate? {
        didSet {
            configureView()
        }
    }

}
