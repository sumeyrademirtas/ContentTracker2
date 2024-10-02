//
//  NewItemController.swift
//  ContentTracker2
//
//  Created by Sümeyra Demirtaş on 10/1/24.
//

import UIKit

class NewItemController: UIViewController {
    var detailView = NewMediaView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDetailView()
        setupSaveButton()
    }
    
    // Controller acilirken resetItems func calisacak.
    override func viewWillAppear(_ animated: Bool) {
        resetItems()
    }
    
    // MARK: - UI Setup

    private func setupDetailView() {
        view.addSubview(detailView)
            
        detailView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSaveButton() {
        detailView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    
    // MARK: - Functions
    
    @objc private func saveButtonTapped() {
        let name = detailView.nameField.text ?? ""
        let note = detailView.noteField.text ?? ""
        let categoryIndex = detailView.categoryPicker.selectedRow(inComponent: 0) // user in sectigi kategori indexini aliyor
        let category = CategoryType.allCases[categoryIndex].rawValue // enumda karsilik gelen case in raw value sunu aliyoruz. String oluyor zaten.
        
        if name.isEmpty {
            let alert = UIAlertController(title: "Missing Information", message: "Please enter the media title", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
            return 
        }
            
        NotificationCenter.default.post(name: .didAddNewMediaItem, object: nil, userInfo: [
            "name": name,
            "note": note,
            "category": category
        ])
            
        dismiss(animated: true) {
            NotificationCenter.default.post(name: .reloadTableView, object: nil)
        }
    }
    
    // new item controller icindeki itemlar sifirlanacak. bunu yazmayinca son girilen bilgiler kaliyor.
    func resetItems() {
        detailView.nameField.text = ""
        detailView.noteField.text = ""
        detailView.categoryPicker.selectRow(0, inComponent: 0, animated: true)
    }
}
