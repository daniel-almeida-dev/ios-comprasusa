//
//  TableProductsCellView.swift
//  ComprasUSA
//
//  Created by MacBook on 24/09/22.
//

import UIKit

class TableProductsViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewProductImage: UIImageView!
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var labelProductValue: UILabel!
    
    func configure(with product: Product) {
        imageViewProductImage.image = product.formattedImage
        labelProductName.text = product.name
        labelProductValue.text = product.formattedValue
    }
}
