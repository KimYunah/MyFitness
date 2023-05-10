//
//  Date.swift
//  MyFitness
//
//  Created by UMC on 2023/02/01.
//

import Foundation

extension Date {
    public var year: Int {
        return Calendar.current.component(.year, from: self)
    }
        
    public var month: Int {
        return Calendar.current.component(.month, from: self)
    }
        
    public var day: Int {
        return Calendar.current.component(.day, from: self)
    }
        
    public var monthName: String {
        let nameFormatter = DateFormatter()
        nameFormatter.dateFormat = "MMMM" // format January, February, March, ...
        return nameFormatter.string(from: self)
    }
    
    public func getText(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
