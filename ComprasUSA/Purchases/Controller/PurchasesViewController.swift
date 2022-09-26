//
//  PurchasesViewController.swift
//  ComprasUSA
//
//  Created by MacBook on 24/09/22.
//

import UIKit
import CoreData

class PurchasesViewController: UITableViewController {
    
    // MARK: - Properties
    lazy var fetchedResultsController: NSFetchedResultsController<Product> = {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Sua lista está vazia!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16.0)
        return label
    }()
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProducts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let productViewController = segue.destination as? ProductViewController else { return }
        
            let product = fetchedResultsController.object(at: indexPath)
            productViewController.product = product
    }
    
    // MARK: - Methods
    private func loadProducts() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            showAlert("Ocorreu um erro ao tentar carregar os produtos")
        }
    }
    
    // MARK: - Table Wiew Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = fetchedResultsController.fetchedObjects?.count == 0 ? label : nil
        
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tableProductsCell", for: indexPath) as? TableProductsViewCell else {
            return UITableViewCell()
        }
        
        let product = fetchedResultsController.object(at: indexPath)
        
        cell.configure(with: product)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PurchasesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {        
        tableView.reloadData()
    }
}
