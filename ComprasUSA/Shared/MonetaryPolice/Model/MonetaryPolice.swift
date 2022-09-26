//
//  Monetary.swift
//  ComprasUSA
//
//  Created by MacBook on 24/09/22.
//

import Foundation

class MonetaryPolice: Codable {
    
    var iof: Double
    var dollarQuote: Double
    
    init(iof: Double, dollarQuote: Double) {
        self.iof = iof
        self.dollarQuote = dollarQuote
    }
}
