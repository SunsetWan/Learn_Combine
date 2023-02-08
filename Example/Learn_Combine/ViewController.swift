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

    let showEmptyHouseButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        password = "1234"
        let curPassword: String = password
        let printerSubscription = $password.sink { value in
            print("The published value is \(value)")
        }
        password = "555"

//        initTextField()

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
//        usingCombineDemo7()
//        usingCombineDemo6()


//        configureEmptyHouse()

//        optionalMap()
//        optionalsInDict()
//        aaaa()
        bbbb()
    }

    func optionalMap() {
        print(#function)
//        let x: String? = "123"
        let x: String? = nil
        let a = x.map {
            $0 + "456"
        }
        print(a)

        let y: String? = "333"
        let g: String? = .some("333")

        var y1: Int? = nil
        y1? = 20
        print("y1: \(y1)")
        y1 = 20
        y1? = 40
        print("y1: \(y1)")
    }

    func optionalsInDict() {
        var dictWithNils: [String: Int?] = [
            "one": 1,
            "two": 2,
            "none": nil
        ]
    }



    func aaaa() {
        var acc = $selected
            .flatMap({ value in
                value.publisher
            })
            .print("before reduce")
            .reduce(0, { acc, current in // reduce 放到外面为啥不行呢？
                if current {
                   return acc + 1
                }

                return -99
            })
            .print("after reduce")
            .eraseToAnyPublisher()

        bbb222 = acc.sink {
            print("ggg: \($0)")
            print("===")
        }


        selected = [false, true, false]

//        selected = [true, true, true]
    }

    var bbb222: AnyCancellable?
    @Published var selected = [true, true, false]
    func bbbb() {
        var acc = $selected
            .flatMap {
                $0.publisher
                    .reduce(true, { acc, current in
                        return acc && current
                    })
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        bbb222 = acc.sink {
            print("isAllSelected: \($0)")
            // Update UI
        }

        selected = [true, true, true]
        selected[2].toggle()
    }

    private func configureEmptyHouse() {
        showEmptyHouseButton.setTitle("Show empty house", for: .normal)
        showEmptyHouseButton.setTitleColor(.blue, for: .normal)
        showEmptyHouseButton.translatesAutoresizingMaskIntoConstraints = false
        showEmptyHouseButton.addTarget(self, action: #selector(showEmptyHouseButtonDidPress), for: .touchUpInside)

        view.addSubview(showEmptyHouseButton)

        NSLayoutConstraint.activate([
            showEmptyHouseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showEmptyHouseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])


    }

    @objc private func showEmptyHouseButtonDidPress() {
        let vc = LearnUICollectionViewCompositionalLayoutViewController()
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
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
//        weather.temperature = 25

//        Temperature now: 20.0
//        current temp: 20.0
//        Temperature now: 25.0
//        current temp: 20.0
    }

    @Published var isFirstTimeUnlockOrLock: Bool = true
    var startLockSub: AnyCancellable?
    var endLockSub: AnyCancellable?
    // Q: how to run paired api call?
    private func usingCombineDemo7() {
        startAndEndTrack()
    }

    private func startAndEndTrack() {
//        startLockSub = $isFirstTimeUnlockOrLock.sink(receiveValue: { newValue in
//            if newValue {
//                self.startLock()
//                self.startLock()
//                self.startLock()
//            }
//        })

        endLockSub = $isFirstTimeUnlockOrLock.sink(receiveValue: { newValue in
//            print("newValue: \(newValue)")
            if !newValue {
                print("end track Lock")
            }
        })

        self.startLock()

        self.startLock()

        self.startLock()
    }

    private func startLock() {
        if isFirstTimeUnlockOrLock {
            print("start track Lock")
            self.isFirstTimeUnlockOrLock = false
        }
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

