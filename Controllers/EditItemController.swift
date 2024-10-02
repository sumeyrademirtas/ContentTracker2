//
//  EditItemController.swift
//  ContentTracker2
//
//  Created by Sümeyra Demirtaş on 10/2/24.
//

import UIKit

class EditItemController: UIViewController {
    var editView = EditMediaView()
    var selectedItem: MediaListItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDetailView()
        setupUpdateButton()
        setupDeleteButton()
    }
    
    // Controller acilirken resetItems func calisacak.
    override func viewWillAppear(_ animated: Bool) {
        getItemInfo()
    }
    
    // MARK: - UI Setup

    private func setupDetailView() {
        view.addSubview(editView)
            
        editView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            editView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupUpdateButton() {
        editView.updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
    }

    private func setupDeleteButton() {
        editView.deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    // updateButtonTapped
    @objc private func updateButtonTapped() {
        let name = editView.nameField.text ?? ""
        let note = editView.noteField.text ?? ""
        let categoryIndex = editView.categoryPicker.selectedRow(inComponent: 0) // user in sectigi kategori indexini aliyor
        let category = CategoryType.allCases[categoryIndex].rawValue // enumda karsilik gelen case in raw value sunu aliyoruz. String oluyor zaten.
        
        if name.isEmpty {
            let alert = UIAlertController(title: "Missing Information", message: "Please enter the media title", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
            return
        }
            
        NotificationCenter.default.post(name: .didUpdateMediaItem, object: nil, userInfo: [
            "name": name,
            "note": note,
            "category": category,
            "id": selectedItem!.objectID
        ])
            
        dismiss(animated: true) {
            NotificationCenter.default.post(name: .reloadTableView, object: nil)
        }
    }
    
    // deleteButtonTapped
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(title: "Are you sure?", message: "If you say yes, your item will be deleted permanently.", preferredStyle: .alert)
        
        // handler icin ayrica bir fonksiyon yazmak yerine closure ile isimi hallettim
        alert.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { _ in
            NotificationCenter.default.post(name: .didDeleteMediaItem, object: nil, userInfo: [
                "id": self.selectedItem!.objectID
            ])
            
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: .reloadTableView, object: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // edit item controller icindeki itemlar sifirlanacak. bunu yazmayinca bir onceki tikladigimizin bilgileri geliyor
    func getItemInfo() {
        editView.nameField.text = selectedItem?.name
        editView.noteField.text = selectedItem?.note
        
        // enumdan kategoriyi aliyoruz, o kategorinin indexini aliyoruz, o indexle category picker index i uyumlu oldugu icin direkt pickerdan seciyoruz.
        if let categoryEnum = CategoryType(rawValue: (selectedItem?.category)!) {
            let categoryIndex = CategoryType.allCases.firstIndex(of: categoryEnum)!
            editView.categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: true)
        }
    }
}
