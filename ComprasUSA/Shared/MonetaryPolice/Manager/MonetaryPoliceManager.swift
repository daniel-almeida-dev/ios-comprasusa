//
//  MonetaryManager.swift
//  ComprasUSA
//
//  Created by MacBook on 24/09/22.
//

import Foundation

class MonetaryPoliceManager {
    
    // MARK: - Properties
    let ud = UserDefaults.standard
    
    var monetaryPolice : MonetaryPolice
    
    static let shared = MonetaryPoliceManager()
    
    static let IOF_KEY = "iof";
    static let DOLLAR_QUOTE_KEY = "dollarQuote";
    
    static let DEFAULT_IOF_VALUE = 6.38
    static let DEFAULT_DOLLAR_QUOTE_VALUE = 3.2
    
    init() {
        if let iof = ud.string(forKey: MonetaryPoliceManager.IOF_KEY),
           let dollarQuote = ud.string(forKey: MonetaryPoliceManager.DOLLAR_QUOTE_KEY) {
            if let mIof = Double(iof),
               let mDollarQuote = Double(dollarQuote) {
                monetaryPolice = MonetaryPolice(iof: mIof, dollarQuote: mDollarQuote)
            } else {
                monetaryPolice = MonetaryPolice(iof: MonetaryPoliceManager.DEFAULT_IOF_VALUE, dollarQuote: MonetaryPoliceManager.DEFAULT_DOLLAR_QUOTE_VALUE)
            }
        } else {
            monetaryPolice = MonetaryPolice(iof: MonetaryPoliceManager.DEFAULT_IOF_VALUE, dollarQuote: MonetaryPoliceManager.DEFAULT_DOLLAR_QUOTE_VALUE)
        }
        
        configure()
        loadValues()
    }
    
    // MARK: - Methods
    func configure() {
        if monetaryPolice.iof == MonetaryPoliceManager.DEFAULT_IOF_VALUE && monetaryPolice.dollarQuote == MonetaryPoliceManager.DEFAULT_DOLLAR_QUOTE_VALUE {
            ud.set(monetaryPolice.iof, forKey: MonetaryPoliceManager.IOF_KEY)
            ud.set(monetaryPolice.dollarQuote, forKey: MonetaryPoliceManager.DOLLAR_QUOTE_KEY)
        }
    }
    
    func loadValues() {
        let iof = ud.double(forKey: MonetaryPoliceManager.IOF_KEY)
        let dollarQuote = ud.double(forKey: MonetaryPoliceManager.DOLLAR_QUOTE_KEY)
        
        monetaryPolice.iof = iof
        monetaryPolice.dollarQuote = dollarQuote
    }
    
    func getIOF() -> Double {
        return monetaryPolice.iof
    }
    
    func setIOF(_ iof: Double) {
        monetaryPolice.iof = iof

        ud.set(iof, forKey: MonetaryPoliceManager.IOF_KEY)
    }
    
    func getDollarQuote() -> Double {
        return monetaryPolice.dollarQuote
    }
    
    func setDollarQuote(_ dollarQuote: Double) {
        monetaryPolice.dollarQuote = dollarQuote
        
        ud.set(dollarQuote, forKey: MonetaryPoliceManager.DOLLAR_QUOTE_KEY)
    }
}
