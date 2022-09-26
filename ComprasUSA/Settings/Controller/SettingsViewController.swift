//
//  SettingsController.swift
//  ComprasUSA
//
//  Created by MacBook on 23/09/22.
//

import UIKit
import CoreData

class SettingsViewController : UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var textFieldDollarQuote: UITextField!
    @IBOutlet weak var textFieldIof: UITextField!
    @IBOutlet weak var tableStates: UITableView!
    
    // MARK: - Properties
    var states: [State] = []
    let monetaryPoliceManager = MonetaryPoliceManager.shared
    
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Lista de estados vazia."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16.0)
        return label
    }()
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableStates.delegate = self
        tableStates.dataSource = self
        textFieldIof.delegate = self
        textFieldDollarQuote.delegate = self
        
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadStates()
        loadMonetaryPolice()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Methods
    func registerSettingsBundle() {
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    private func loadMonetaryPolice() {
        textFieldIof.text = String(format: "%.2f", monetaryPoliceManager.getIOF())
        textFieldDollarQuote.text = String(format: "%.1f", monetaryPoliceManager.getDollarQuote())
    }
    
    private func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            states = try context.fetch(fetchRequest)
            
            tableStates.reloadData()
        } catch {
            print(error)
        }
    }
    
    private func showStateAlert(for state: State? = nil) {
        let btn = state == nil ? "Adicionar" : "Salvar"
        let title = state == nil ? "Adicionar Estado" : "Editar Estado"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Nome do estado"
            textField.text = state?.name
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Imposto"
            textField.text = String(format: "%.1f", state?.tax ?? 0.0)
        }
        
        let okAction = UIAlertAction(title: btn, style: .default) { _ in
            let state = state ?? State(context: self.context)
            
            let textFieldName = alert.textFields![0] as UITextField
            state.name = textFieldName.text
            
            let textFieldTax = alert.textFields![1] as UITextField
            state.tax = Double(textFieldTax.text!) ?? 0.0
            
            try? self.context.save()
  
            self.loadStates()
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @objc func defaultsChanged() {
       MonetaryPoliceManager.shared.loadValues()
       loadMonetaryPolice()
    }
    
    // MARK: - IBActions
    @IBAction func addState(_ sender: Any) {
        showStateAlert()
    }
}

extension SettingsViewController: UITableViewDelegate & UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = states.count == 0 ? label : nil
        
        return states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let state = states[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableStatesCell", for: indexPath)
        
        cell.textLabel?.text = state.name
        cell.detailTextLabel?.text = String(format: "%.1f", state.tax)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = states[indexPath.row]
        
        self.showStateAlert(for: state)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Excluir") { action, view, completionHandler in
            let state = self.states[indexPath.row]
            
            self.context.delete(state)
            
            do {
                try self.context.save()
            } catch {
            }
            
            self.states.remove(at: indexPath.row)
            self.tableStates.deleteRows(at: [indexPath], with: .automatic)
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
       if textField == textFieldIof {
           guard let iof = Double(textFieldIof.text!) else {
               textFieldIof.text = String(format: "%.2f", monetaryPoliceManager.getIOF())
               
               return
           }
               
           monetaryPoliceManager.setIOF(iof)
       } else if textField == textFieldDollarQuote {
           guard let dollarQuote = Double(textFieldDollarQuote.text!) else {
               textFieldDollarQuote.text = String(format: "%.1f", monetaryPoliceManager.getDollarQuote())
               
               return
           }
               
           monetaryPoliceManager.setDollarQuote(dollarQuote)
       }
    }
}

