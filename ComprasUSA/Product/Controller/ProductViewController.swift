//
//  ProductViewController.swift
//  ComprasUSA
//
//  Created by MacBook on 24/09/22.
//

import UIKit
import CoreData

class ProductViewController : UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var textFieldProductName: UITextField!
    @IBOutlet weak var imageViewProductImage: UIImageView!
    @IBOutlet weak var textFieldPurchaseState: UITextField!
    @IBOutlet weak var textFieldProductValue: UITextField!
    @IBOutlet weak var switchPurchaseType: UISwitch!
    @IBOutlet weak var buttonSave: UIButton!
    
    // MARK: - Properties
    var toolBar: UIToolbar?
    var pickerViewStates: UIPickerView?
    var buttonDone: UIBarButtonItem?
    var buttonCancel: UIBarButtonItem?
    
    var product: Product?
    var initialImage = true
    var states: [State] = []
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let product = product {
            textFieldProductName.text = product.name
            imageViewProductImage.image = product.formattedImage
            textFieldPurchaseState.text = product.state?.name
            textFieldProductValue.text = product.stringValue
            switchPurchaseType.isOn = product.creditCard
            
            initialImage = false
            title = "Editar Produto"
            buttonSave.setTitle("SALVAR", for: .normal)
            imageViewProductImage.contentMode = UIView.ContentMode.scaleAspectFill
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageViewProductImage.isUserInteractionEnabled = true
        imageViewProductImage.addGestureRecognizer(tapGestureRecognizer)
        
        setPickerViewStates()
        textFieldPurchaseState.delegate = self
        textFieldPurchaseState.inputView = pickerViewStates
        textFieldPurchaseState.inputAccessoryView = toolBar
        pickerViewStates?.delegate = self
        pickerViewStates?.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        loadStates()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    // MARK: - Methods
    private func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            states = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }
    
    private func selectPictureFrom(_ sourceType: UIImagePickerController.SourceType) {
        view.endEditing(true)
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func getStateByName(_ stateName: String) -> State? {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let predicate = NSPredicate(format: "name == %@", stateName)
        fetchRequest.predicate = predicate
        
        do {
            let state = try context.fetch(fetchRequest).first
            
            return state
        } catch {
            return nil
        }
    }
    
    // MARK: - Set View
    private func setPickerViewStates() {
        pickerViewStates = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
        
        toolBar = UIToolbar()
        toolBar?.barStyle = UIBarStyle.default
        toolBar?.isTranslucent = true
        toolBar?.sizeToFit()

        buttonDone = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        buttonCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))

        toolBar?.setItems([buttonCancel!, spaceButton, buttonDone!], animated: false)
        toolBar?.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    @objc func donePicker(uiBarButtonItem: UIBarButtonItem) {
        switch (uiBarButtonItem) {
        case buttonDone:
            if self.states.count > 0 {
                self.textFieldPurchaseState.text = self.pickerView(self.pickerViewStates!, titleForRow: self.pickerViewStates!.selectedRow(inComponent: 0), forComponent: 0)
            }
            
            self.view.endEditing(true)
            
            break
        case buttonCancel:
            self.view.endEditing(true)
            
            break
        default: break
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let alert = UIAlertController(title: "Selecionar Imagem", message: "De onde você deseja escolher a foto do produto?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default) { _ in
                self.selectPictureFrom(.camera)
            }
            
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de Fotos", style: .default) { _ in
            self.selectPictureFrom(.savedPhotosAlbum)
        }
        
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func save(_ sender: Any) {
        if product == nil {
            product = Product(context: context)
        }
        
        product?.name = textFieldProductName.text
        product?.creditCard = switchPurchaseType.isOn
        product?.value = Double(textFieldProductValue.text!) ?? 0.0
        product?.image = imageViewProductImage.image?.jpegData(compressionQuality: 0.8)
        
        if let state = getStateByName(textFieldPurchaseState.text!) {
            product?.state = state
        }
        
        do {
            try context.save()
            
            navigationController?.popViewController(animated: true)
        } catch {
            print(error)
        }
    }
}

extension ProductViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == textFieldPurchaseState {
            return false
        }
        return true
    }
}

extension ProductViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            imageViewProductImage.contentMode = UIView.ContentMode.scaleAspectFill
            imageViewProductImage.image = image
            initialImage = false
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension ProductViewController: UIPickerViewDelegate & UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row].name
    }
}
