//
//  ViewController.swift
//  Learn_Combine
//
//  Created by Sunset Wan on 12/14/202=2.
//  Copyright (c) 2022 Sunset Wan. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {

    let textField1 = UITextField(frame: .zero)

    @Published var password: String = ""

    var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        password = "1234"
        let curPassword: String = password
        let printerSubscription = $password.sink { value in
            print("The published value is \(value)")
        }
        password = "555"

        initTextField()

//        let sub = pub1.sin

//        rangePub()
//
//         let pub1 = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: textField1)
//
//        let a = pub1.sink { new in
//            print("new")
//        }
//
//        let sub1 = pub1.map { notifacation in
//            (notifacation.object as! UITextField).text
//        }.sink(receiveValue: { newText in
//            print("newText")
//        })

//        usingCombineDemo1()
//        usingCombineDemo2()
//        usingCombineDemo3()
//        usingCombineDemo4()
//        usingCombineDemo5()
        usingCombineDemo6()
    }

    private func initTextField() {
        textField1.backgroundColor = .lightGray
        textField1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField1)
        NSLayoutConstraint.activate([
            textField1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textField1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            textField1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            textField1.heightAnchor.constraint(equalToConstant: 100),
        ])
    }

    private func rangePub() {
        let myRange = (0 ..< 5)
        let cancellable = myRange.publisher
            .sink { ret in
                print("ret: \(ret)")
            } receiveValue: { value in
                print("value: \(value)")
            }
    }

    private func usingCombineDemo1() {
        let pub1 = Just(5)
            .map { value in
                return "a string"
            }

        let sub1 = pub1.sink { receivedValue in
            print("receivedValue: \(receivedValue)")
        }



    }

    private func usingCombineDemo2() {
        let numbers = [5, 4, 3, 2, 1, 0]
        let romanNumeralDict: [Int : String] = [1:"I", 2:"II", 3:"III", 4:"IV", 5:"V"]
        let cancellable = numbers.publisher
        let _ = cancellable.map { value in
            romanNumeralDict[value] ?? "(unknown)"
        }.sink { received in
            print("received: \(received)", terminator: ", ")
        }
    }

    private func usingCombineDemo3() {
        struct ParseError: Swift.Error {}
        func romanNumeral(from:Int) throws -> String {
            let romanNumeralDict: [Int : String] = [1:"I", 2:"II", 3:"III", 4:"IV", 5:"V"]
            guard let numeral = romanNumeralDict[from] else {
                throw ParseError()
            }
            return numeral
        }

        let numbers = [5, 4, 3, 2, 1, 0]
        let cancellable = numbers.publisher
            .tryMap {
                try romanNumeral(from: $0)
            }
            .sink { result in
                print("result: \(result)")
            } receiveValue: { receicedValue in
                print("receicedValue: \(receicedValue)")
            }

    }

    // Future
    private func usingCombineDemo4() {
        let pub = generateAsyncRandomNumberFromFuture()
        cancellable = pub.sink { randomNumber in
            print("randomNumber: \(randomNumber)")
        }
    }

    func generateAsyncRandomNumberFromFuture() -> Future<Int, Never> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let number = Int.random(in: 1...10)
                promise(.success(number))
            }
        }
    }

    private func usingCombineDemo5() {
        let x = PassthroughSubject<String, Never>()
            .flatMap { name in
                return Future<String, Error> { promise in
                    promise(.success(""))
                }
                .catch { _ in
                    return Just("No user found")
                }
                .map { result in
                    return "\(result) foo"
                }
            }
//            .eraseToAnyPublisher()
    }

    /// When the property changes, publishing occurs in the property's `willSet` block,
    /// meaning subscribers receive the new value before it's actually set on the property.
    /// In the above example, the second time the sink executes its closure, it receives the parameter value `25`.
    /// However, if the closure evaluated `weather.temperature`, the value returned would be `20`.
    var weatherCancellable: AnyCancellable?
    private func usingCombineDemo6() {
        let weather = Weather(temperature: 20)
        weatherCancellable = weather.$temperature
            .sink {
                print("Temperature now: \($0)")
                print("current temp: \(weather.temperature)")
            }
        weather.temperature = 25

//        Temperature now: 20.0
//        current temp: 20.0
//        Temperature now: 25.0
//        current temp: 20.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class Weather {
    @Published var temperature: Double
    init(temperature: Double) {
        self.temperature = temperature
    }
}

