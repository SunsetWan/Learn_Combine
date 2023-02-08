//
//  LearnAdvancedSwiftViewController.swift
//  Learn_Combine_Example
//
//  Created by Sunset Wan on 7/2/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class LearnAdvancedSwiftViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dictWithNil()

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
