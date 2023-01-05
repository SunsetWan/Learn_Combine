//
//  ValidateNewPasswordViewController.swift
//  Learn_Combine_Example
//
//  Created by Sunset Wan on 28/12/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import Combine

class TextInputView: UIView {
    let titleLabel = UILabel()
    let hintLabel = UILabel()
    let textField = UITextField(frame: .zero)

    private let hStackView = UIStackView()
    private let vStackView = UIStackView()

    lazy var titleLabelHugging = titleLabel.widthAnchor

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1

        hStackView.axis = .horizontal
        hStackView.spacing = 10
        hStackView.addArrangedSubview(titleLabel)
        hStackView.addArrangedSubview(textField)

        titleLabel.textColor = .black
        titleLabel.text = "Value 1"
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        hintLabel.textColor = .black

        vStackView.axis = .vertical
        vStackView.spacing = 5
        vStackView.addArrangedSubview(hStackView)
        vStackView.addArrangedSubview(hintLabel)
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vStackView)

        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            vStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            heightAnchor.constraint(equalToConstant: 120),
        ])
    }
}

class ValidateNewPasswordViewController: UIViewController {

    let value1Input = TextInputView(frame: .zero)
    let value2Input = TextInputView(frame: .zero)
    let value3Input = TextInputView(frame: .zero)

    @Published var value1 = ""
    @Published var value2 = ""
    @Published var value3 = ""

    let vStackView = UIStackView()

    @objc func value1Changed() {
        value1 = value1Input.textField.text ?? ""
        print(#function + " new value: \(value1)")
    }

    @objc func value2Changed() {
        value2 = value2Input.textField.text ?? ""
        print(#function + " new value: \(value2)")
    }

    @objc func value3Changed() {
        value3 = value3Input.textField.text ?? ""
        print(#function + " new value: \(value3)")
    }

    var validateValue1: AnyPublisher<String?, Never> {
        return $value1.map { value1 in
            guard value1.count > 2 else {
                DispatchQueue.main.async {
                    self.value1Input.hintLabel.text = "minimum of 3 char required!"
                }
                return nil
            }

            DispatchQueue.main.async {
                self.value1Input.hintLabel.text = ""
            }
            return value1
        }.eraseToAnyPublisher()
    }

    var validateValue2: AnyPublisher<String?, Never> {
        return Publishers.CombineLatest($value2, $value3)
            .receive(on: DispatchQueue.main)
            .map { (value2, value3) in
                guard value2 == value3, value2.count > 4 else {
                    self.value2Input.hintLabel.text = "values must match and have at least 5 chars"
                    return nil
                }

                self.value2Input.hintLabel.text = ""
                return value2
            }
            .eraseToAnyPublisher()
    }

    var readyToSubmit: AnyPublisher<(String, String)?, Never> {
        return Publishers.CombineLatest(validateValue1, validateValue2)
            .map { (value1, value2) in
                guard let realValue2 = value2, let realValue1 = value1 else {
                    return nil
                }
                return (realValue1, realValue2)
            }
            .eraseToAnyPublisher()
    }

    var validateValue1Sub: AnyCancellable?
    var readyToSubmitSub: AnyCancellable?

    private var cancellableSet: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        value1Input.textField.addTarget(self, action: #selector(value1Changed), for: .editingChanged)
        value2Input.textField.addTarget(self, action: #selector(value2Changed), for: .editingChanged)
        value3Input.textField.addTarget(self, action: #selector(value3Changed), for: .editingChanged)

        value1Input.titleLabel.text = "Value1"
        value2Input.titleLabel.text = "Value2"
        value3Input.titleLabel.text = "Value3"

        vStackView.axis = .vertical
        vStackView.spacing = 5

        vStackView.addArrangedSubview(value1Input)
        vStackView.addArrangedSubview(value2Input)
        vStackView.addArrangedSubview(value3Input)

        vStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(vStackView)

        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            vStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        validateValue1Sub = validateValue1.receive(on: RunLoop.main)
            .sink { newValue1 in
                print("newValue1: \(newValue1)")
            }

        readyToSubmit
            .map { $0 != nil }
            .receive(on: DispatchQueue.main)
            .sink { canContinue in
                print("canContinue: \(canContinue)")
            }
            .store(in: &cancellableSet)
    }
}
