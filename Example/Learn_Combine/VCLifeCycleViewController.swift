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
        get {
            "defaultName"
        }
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        log()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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

    let pushButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        configureEmptyHouse()
    }

    private func configureEmptyHouse() {
        pushButton.setTitle("Push B", for: .normal)
        pushButton.setTitleColor(.blue, for: .normal)
        pushButton.translatesAutoresizingMaskIntoConstraints = false
        pushButton.addTarget(self, action: #selector(pushButtonDidPress), for: .touchUpInside)

        view.addSubview(pushButton)

        NSLayoutConstraint.activate([
            pushButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pushButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func pushButtonDidPress() {
        let bVC = VCLifeCycleViewControllerB()
        let container = UINavigationController(rootViewController: bVC)
//      navigationController?.pushViewController(bVC, animated: true)
        container.modalPresentationStyle = .fullScreen
        present(container, animated: true)

    }
}


class VCLifeCycleViewControllerB: VCLifeCycleBaseViewController {
    override var vcName: String {
        "B"
    }

    let pushButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue.withAlphaComponent(0.3)
        configureEmptyHouse()
    }

    private func configureEmptyHouse() {
        pushButton.setTitle("Push C", for: .normal)
        pushButton.setTitleColor(.black, for: .normal)
        pushButton.translatesAutoresizingMaskIntoConstraints = false
        pushButton.addTarget(self, action: #selector(pushButtonDidPress), for: .touchUpInside)

        view.addSubview(pushButton)

        NSLayoutConstraint.activate([
            pushButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pushButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func pushButtonDidPress() {
//        dismiss(animated: true)
        let cVC = VCLifeCycleViewControllerC()
        navigationController?.pushViewController(cVC, animated: true)
    }
}

class VCLifeCycleViewControllerC: VCLifeCycleBaseViewController {
    override var vcName: String {
        "C"
    }

    let pushButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue.withAlphaComponent(0.3)
        configureEmptyHouse()
    }

    private func configureEmptyHouse() {
        pushButton.setTitle("Dismiss C", for: .normal)
        pushButton.setTitleColor(.black, for: .normal)
        pushButton.translatesAutoresizingMaskIntoConstraints = false
        pushButton.addTarget(self, action: #selector(pushButtonDidPress), for: .touchUpInside)

        view.addSubview(pushButton)

        NSLayoutConstraint.activate([
            pushButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pushButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func pushButtonDidPress() {
        dismiss(animated: true)
    }
}
