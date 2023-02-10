//
//  VCLifeCycleViewController.swift
//  Learn_Combine_Example
//
//  Created by Sunset Wan on 8/2/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class VCLifeCycleBaseViewController: UIViewController {
    let button = UIButton()

    var buttonTitle: String {
        get {
            "defaultName"
        }
    }

    var vcName: String {
        get {
            "defaultName"
        }
    }

    func didPressButton() {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        log()
        view.backgroundColor = .white
        configureButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        log()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        log()
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

    private func configureButton() {
        button.setTitle(vcName + ": " + buttonTitle, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func buttonDidPress() {
        didPressButton()
    }
}

class VCLifeCycleViewController: VCLifeCycleBaseViewController {
    override var vcName: String {
        "A"
    }

    override var buttonTitle: String {
        "Present B"
    }

    override func didPressButton() {
        let bVC = VCLifeCycleViewControllerB()
        let container = UINavigationController(rootViewController: bVC)
        //      navigationController?.pushViewController(bVC, animated: true)
        container.modalPresentationStyle = .fullScreen
        present(container, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}


class VCLifeCycleViewControllerB: VCLifeCycleBaseViewController {
    override var vcName: String {
        "B"
    }

    override var buttonTitle: String {
        "Push C"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    override func didPressButton() {
        let cVC = VCLifeCycleViewControllerC()
        navigationController?.pushViewController(cVC, animated: true)
    }
}

class VCLifeCycleViewControllerC: VCLifeCycleBaseViewController {
    override var vcName: String {
        "C"
    }


    override var buttonTitle: String {
        "Present D"
    }


    override func didPressButton() {
        let dVC = VCLifeCycleViewControllerD()
        dVC.modalPresentationStyle = .fullScreen
        present(dVC, animated: true)
    }
}

class VCLifeCycleViewControllerD: VCLifeCycleBaseViewController {
    override var vcName: String {
        "D"
    }


    override var buttonTitle: String {
        "Dismiss"
    }


    override func didPressButton() {
//        (presentingViewController as? UINavigationController)?.popToRootViewController(animated: false)
        (presentingViewController as? UINavigationController)?.dismiss(animated: false)
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
}
