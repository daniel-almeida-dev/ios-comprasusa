//
//  Product+Conversions.swift
//  ComprasUSA
//
//  Created by MacBook on 24/09/22.
//

import UIKit

extension Product {
    
    var stringValue: String {
        String(format: "%.2f", value)
    }
    
    var formattedValue: String {
        "U$ \(String(format: "%.2f", value))"
    }
    
    var formattedImage: UIImage? {
        if let data = image {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    
    var formattedPurchaseType: String {
        if creditCard {
            return "Sim"
        } else {
            return "Não"
        }
    }
}
