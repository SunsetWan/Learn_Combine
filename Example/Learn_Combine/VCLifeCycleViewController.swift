//
//  VCLifeCycleViewController.swift
//  Learn_Combine_Example
//
//  Created by Sunset Wan on 8/2/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class VCLifeCycleBaseViewController: UIViewController {

    var vcName: String {
        "defaultName"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        log()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        log()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        log()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log()
    }

    func log(_ function: String = #function) {
        print("👹 \(vcName): " + function)
    }
}

class VCLifeCycleViewController: VCLifeCycleBaseViewController {

    override var vcName: String {
        "A"
    }

    let pushButton

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
    }
}
