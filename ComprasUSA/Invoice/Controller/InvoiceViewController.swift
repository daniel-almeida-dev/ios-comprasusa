//
//  InvoiceViewController.swift
//  ComprasUSA
//
//  Created by MacBook on 25/09/22.
//

import UIKit
import CoreData

class InvoiceViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var labelValueInUSD: UILabel!
    @IBOutlet weak var labelValueInBRL: UILabel!
    
    // MARK: - Properties
    var products: [Product] = []
    let invoiceViewModel = InvoiceViewModel()
    let monetaryPoliceManager = MonetaryPoliceManager.shared
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(InvoiceViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadProducts()
    }
    
    // MARK: - Methods
    func registerSettingsBundle() {
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    private func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            products = try context.fetch(fetchRequest)
            
            loadValues()
        } catch {
            showAlert("Ocorreu um erro ao tentar carregar os produtos")
        }
    }
    
    private func loadValues() {
        invoiceViewModel.valueInUSD = 0.0
        invoiceViewModel.valueInBRL = 0.0
        
        calculateValues()
        labelValueInUSD.text = invoiceViewModel.formattedValueInUSD
        labelValueInBRL.text = invoiceViewModel.formattedValueInBRL
    }
    
    private func calculateValues() {
        for product in products {
            var valueInUSD: Double = 0.0
            var valueInBRL: Double = 0.0
            
            valueInUSD = product.value
            invoiceViewModel.valueInUSD += valueInUSD
            
            valueInUSD = calculateUSDValueWithStateTax(valueInUSD, product.value, product.state!.tax)
            valueInBRL = convertUSDValueInBRL(valueInUSD)
            
            if product.creditCard {
                valueInBRL = calculateBRLValueWithCreditCardTax(valueInBRL)
            }
            
            invoiceViewModel.valueInBRL += valueInBRL
        }
    }
    
    private func calculateUSDValueWithStateTax(_ valueUSD: Double, _ productValue: Double, _ stateTax: Double) -> Double {
        let tax = calculateUSDStateTax(productValue, stateTax)
        
        return (valueUSD + tax)
    }
    
    private func calculateUSDStateTax(_ productValue: Double, _ stateTax: Double) -> Double {
        return ((productValue * stateTax)/100)
    }
    
    private func convertUSDValueInBRL(_ valueInUSD: Double) -> Double {
        let dollarQuote = monetaryPoliceManager.getDollarQuote()
        
        return (valueInUSD * dollarQuote)
    }
    
    private func calculateBRLValueWithCreditCardTax(_ valueBRL: Double) -> Double {
        return (valueBRL + calculateBRLValueCreditCardTax(valueBRL))
    }
    
    private func calculateBRLValueCreditCardTax(_ valueBRL: Double) -> Double {
        let iof = monetaryPoliceManager.getIOF()
        
        return ((valueBRL * iof)/100)
    }
    
    // MARK: - Methods
    @objc func defaultsChanged() {
        MonetaryPoliceManager.shared.loadValues()
        loadValues()
    }
}

