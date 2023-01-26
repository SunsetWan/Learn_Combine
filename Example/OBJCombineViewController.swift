//
//  OBJCombineViewController.swift
//  Learn_Combine_Example
//
//  Created by Sunset Wan on 22/1/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Combine
import UIKit

class OBJCombineViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray

//        demo1()
//        demo2()
        demo3()
    }

    private func demo1() {
//        check("Empty") {
//            Empty<Int, SampleError>()
//        }

//        check("Just") {
//            Just(1)
//        }

//        check("Sequence 1") {
//          Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
//
//        }

//        check("Sequence 2") {
////          Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
//            [1, 2, 3].publisher
//        }

//        check("Scan") {
//            [1,2,3,4,5].publisher.scan(0, +)
//        }

//        check("Flat Map 1") {
//            [[1, 2, 3], ["a", "b", "c"]]
//                .publisher
//                .flatMap {
//                    $0.publisher
//                }
//
//        }

//        check("Flat Map 2") {
//            ["A", "B", "C"]
//                .publisher
//                .flatMap { letter in
//                    [1, 2, 3]
//                        .publisher
//                        .map { "\(letter)\($0)" }
//                }
//        }

        check("Catch with Just") {
            ["1", "2", "Swift", "4"]
                .publisher
                .tryMap { s -> Int in
                    guard let value = Int(s) else {
                        throw SunsetError.random
                    }
                    return value
                }
                .catch { _ in Just(-1) }
        }

        check("Catch with Another Publisher") {
            ["1", "2", "Swift", "4"]
                .publisher
                .print("[ Original ]")
                .flatMap { s in
                    Just(s)
                        .tryMap { s -> Int in
                            guard let value = Int(s) else {
                                throw SunsetError.random
                            }
                            return value
                        }
                        .print("[ TryMap ]")
                        .catch { _ in
                            Just(-1)
                                .print("[ Just ]")
                        }
                        .print("[ Catch ]")
                }
        }
    }

    // 加上时序
    var s1Sub: AnyCancellable?
    private func demo2() {
        s1Sub = check("Subject") { () -> PassthroughSubject<Int, Never> in
            let subject = PassthroughSubject<Int, Never>()
            delay(1) {
                subject.send(1)
                delay(1) {
                    subject.send(2)
                    delay(1) {
                        subject.send(completion: .finished)
                    }
                }
            }
            return subject
        }
    }

    // zip 和 combineLatest 的订阅时机
    var zipSub: AnyCancellable?
    var combineLatestSub: AnyCancellable?
    private func demo3() {
//        let subject1 = PassthroughSubject<Int, Never>()
//        let subject2 = PassthroughSubject<String, Never>()

        let subject1 = CurrentValueSubject<Int, Never>(-1)
        let subject2 = CurrentValueSubject<String, Never>("null")

        subject1.send(1)
        subject2.send("A")
        subject1.send(2)

//        zipSub = Publishers.Zip(subject1, subject2)
//            .sink {
//                print("zip received tuple: \($0)")
//            }

        combineLatestSub = Publishers.CombineLatest(subject1, subject2)
            .sink {
                print("combineLatest received tuple: \($0)")
            }

        subject2.send("B")
        subject2.send("C")
        subject2.send("D")
        subject1.send(3)
        subject1.send(4)
        subject1.send(5)
    }
}

enum SunsetError: Error {
    case random
}

import Foundation

@discardableResult
public func check<P: Publisher>(_ title: String, publisher: () -> P) -> AnyCancellable {
    print("----- \(title) -----")
    defer { print("") }
    return publisher()
        .print()
        .sink(
            receiveCompletion: { _ in},
            receiveValue: { _ in }
        )
}

public func delay(_ seconds: TimeInterval = 0, on queue: DispatchQueue = .main, block: @escaping () -> Void) {
    queue.asyncAfter(deadline: .now() + seconds, execute: block)
}

public enum SampleError: Error {
    case sampleError
}

extension Sequence {
    public func scan<ResultElement>(
        _ initial: ResultElement,
        _ nextPartialResult: (ResultElement, Element) -> ResultElement
        ) -> [ResultElement] {
        var result: [ResultElement] = []
        for x in self {
            result.append(nextPartialResult(result.last ?? initial, x))
        }
        return result
    }
}

public struct TimeEventItem<Value> {
    public let duration: TimeInterval
    public let value: Value

    public init(duration: TimeInterval, value: Value) {
        self.duration = duration
        self.value = value
    }
}

extension TimeEventItem: Equatable where Value: Equatable {}
extension TimeEventItem: CustomStringConvertible {
    public var description: String {
        return "[\(duration)] - \(value)"
    }
}

//public struct TimerPublisher<Value>: Publisher {
//    public typealias Output = TimeEventItem<Value>
//    public typealias Failure = Never
//
//    let items: [TimeEventItem<Value>]
//
//    public init(_ items: [TimeEventItem<Value>]) {
//        self.items = items
//    }
//
//    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
//
//        let data = items.sorted { $0.duration < $1.duration }
//        for index in data.indices {
//            let item = items[index]
//            CombineExample_Starter_Sources.delay(item.duration) {
//                _ = subscriber.receive(item)
//                if index == data.endIndex - 1 {
//                    subscriber.receive(completion: .finished)
//                }
//            }
//        }
//    }
//}

//extension Dictionary where Key == TimeInterval {
//    public var timerPublisher: TimerPublisher<Value> {
//        let items = map { kvp in
//            TimeEventItem(duration: kvp.key, value: kvp.value)
//        }
//        return TimerPublisher(items)
//    }
//}

