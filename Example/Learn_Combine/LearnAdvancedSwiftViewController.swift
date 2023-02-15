//
//  LearnAdvancedSwiftViewController.swift
//  Learn_Combine_Example
//
//  Created by Sunset Wan on 10/2/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class LearnAdvancedSwiftViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        dictWithNil()
//        funcCapture()
        unsafeSwiftDoBlock()
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
}
