//
//  UIViewController+Alert.swift
//  ComprasUSA
//
//  Created by MacBook on 26/09/22.
//

import UIKit

extension UIViewController {
    
    func showAlert(_ message: String){
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle:.alert)
        
        alert.addAction(UIAlertAction(title: "Entendi", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
