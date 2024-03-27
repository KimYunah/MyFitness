//
//  String.swift
//  MyFitness
//
//  Created by UMCios on 2023/05/11.
//

import Foundation

extension String {
    func matches(_ regex: String) -> Bool {
        let match = self.range(of: regex, options: .regularExpression)
        return match != nil
    }
}

