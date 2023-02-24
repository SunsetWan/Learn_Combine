//
//  LearnAdvancedSwiftViewController.swift
//  Learn_Combine_Example
//
//  Created by Sunset Wan on 10/2/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Combine

class LearnAdvancedSwiftViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        dictWithNil()
//        funcCapture()
//        unsafeSwiftDoBlock()
        reviewPropertyWrappers()
    }

    func dictWithNil() {
        var dictWithNils: [String: Int?] = [
            "one": 1,
            "two": 2,
            "none": nil
        ]

        dictWithNils["two"] = .some(nil)
        print("before dict: \(dictWithNils)")
        dictWithNils["two"]? = nil
        print("after dict: \(dictWithNils)")

        var a: Int? = nil
        a? = 3
        print("before a: \(a)")
        a = 5
        a? = 6
        print("after a: \(a)")
    }

    // Functions can capture variables that exist outside of their local scope.
    func funcCapture() {
        let f = makeCounter()
        f(2)
        f(4)
        print(f(6))

        let g = makeCounter()
        g(1)
        g(2)
        print(g(3))
    }


    func makeCounter() -> (Int) -> String {
        var counter = 0

        func innerFunc(i: Int) -> String {
            counter += i // counter is captured
            return "Running total: \(counter)"
        }

        return innerFunc
    }

    func unsafeSwiftDoBlock() {

        func incref(pointer: UnsafeMutablePointer<Int>) -> () -> Int {
            return {
                pointer.pointee += 1
                return pointer.pointee
            }
        }

        let fun: () -> Int
        var array = [8]
        do {
//            var array = [8] // array 放在 do {} 里，和放在 do {} 外面，区别在哪里？
            fun = incref(pointer: &array[0])
        }
//        array.append(9)
        print(fun())
    }

    func advancedSubscripts() {
        var japan: [String: Any] = [
            "name": "Japan",
            "capital": "Tokyo",
            "population": 126_440_000,
            "coordinates": [
                "latitude": 35.0,
                "longitude": 139.0
            ]
        ]

//        japan["coordinates"]?["latitude"] = 36.0

        // The problem is that you can’t mutate a variable through a typecast
//        (japan["coordinates"] as? [String: Double])?["latitude"] = 36.0
    }


    func reviewPropertyWrappers() {
        @propertyWrapper
        struct TwelveOrLess {
            private var number = 0
            var wrappedValue: Int {
                get { return number }
                set { number = min(newValue, 12) }
            }
        }

        @propertyWrapper
        struct SmallNumber {
            private var maximum: Int
            private var number: Int

            var wrappedValue: Int {
                get { return number }
                set { number = min(newValue, maximum) }
            }

            init() {
                maximum = 12
                number = 0
            }
            init(wrappedValue: Int) {
                maximum = 12
                number = min(wrappedValue, maximum)
            }
            init(wrappedValue: Int, maximum: Int) {
                self.maximum = maximum
                number = min(wrappedValue, maximum)
            }
        }

        struct SmallRectangle {
            @TwelveOrLess var height: Int
            @TwelveOrLess var width: Int
        }

        struct ZeroRectangle {
            @SmallNumber var height: Int
            @SmallNumber var width: Int
        }

        struct NarrowRectangle {
            @SmallNumber(wrappedValue: 2, maximum: 5) var height: Int
            @SmallNumber(wrappedValue: 3, maximum: 2) var width: Int
        }

        var narrowRectangle = NarrowRectangle()
        print("narrowRectangle:", narrowRectangle.height, narrowRectangle.width)
        narrowRectangle.height = 100
        narrowRectangle.width = 100
        print("narrowRectangle:", narrowRectangle.height, narrowRectangle.width)

//        var rectangle = SmallRectangle(height: 100)
        var rectangle = SmallRectangle()
        rectangle.height = 10
        print(rectangle.height)

        rectangle.height = 24
        print(rectangle.height)

        var zeroRectangle = ZeroRectangle(height: .init(wrappedValue: 20), width: .init(wrappedValue: 30))
        print(zeroRectangle.height, zeroRectangle.width)

        finishReviewPropertyWrappers()
    }

    func finishReviewPropertyWrappers() {
        struct Checkbox {
            @Box var isOn: Bool = false
            var isOnCopy: Bool = false

            func didTap() {
                isOn.toggle()
//                isOnCopy.toggle()
            }
        }

        func makeEditor() -> PersonEditor {
            @Box var person = Person(name: "Sunset")
            return PersonEditor(person: _person.projectedValue)
        }

    }

    func reviewProjectedValue() {
        @propertyWrapper
        struct SmallNumber {
            private var number: Int
            private(set) var projectedValue: Bool

            var wrappedValue: Int {
                get { return number }
                set {
                    if newValue > 12 {
                        number = 12
                        projectedValue = true
                    } else {
                        number = newValue
                        projectedValue = false
                    }
                }
            }

            init() {
                self.number = 0
                self.projectedValue = false
            }
        }
        struct SomeStructure {
            @SmallNumber var someNumber: Int
        }
        var someStructure = SomeStructure()

        someStructure.someNumber = 4
        print(someStructure.$someNumber)
        // Prints "false"

        someStructure.someNumber = 55
        print(someStructure.$someNumber)
        // Prints "true"
    }
}

// The Box type is useful when you need a mutable variable in a scope that doesn’t allow mutation (for example, you can modify the value inside a Box even when you’re inside a non-mutating method).
@propertyWrapper
class Box<A> {
    var wrappedValue: A
    init(wrappedValue: A) {
        self.wrappedValue = wrappedValue
    }
}

extension Box {
    var projectedValue: Reference<A> {
        Reference<A>(get: { self.wrappedValue }, set: { self.wrappedValue = $0 })
    }
}

@propertyWrapper
class Reference<A> {
    private var _get: () -> A
    private var _set: (A) -> ()

    var wrappedValue: A {
        get { _get() }
        set { _set(newValue) }
    }

    init(get: @escaping () -> A, set: @escaping (A) -> Void) {
        _get = get
        _set = set
    }
}

struct Person {
    var name: String
}

struct PersonEditor {
    @Reference var person: Person
}
