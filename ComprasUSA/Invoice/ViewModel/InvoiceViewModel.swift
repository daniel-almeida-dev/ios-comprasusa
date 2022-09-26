//
//  InvoiceViewModel.swift
//  ComprasUSA
//
//  Created by MacBook on 25/09/22.
//

class InvoiceViewModel {
    
    var valueInUSD: Double = 0.0
    var valueInBRL: Double = 0.0
    
    var formattedValueInUSD: String {
        return String(format: "%.2f", valueInUSD)
    }
    
    var formattedValueInBRL: String {
       return String(format: "%.2f", valueInBRL)
    }
}
