//
//  DetailView.swift
//  ContentTracker2
//
//  Created by Sümeyra Demirtaş on 10/1/24.
//

import UIKit

class NewMediaView: UIView {
    // MARK: - Properties

    let nameField: UITextField = {
        let nameField = UITextField()
        nameField.backgroundColor = .systemBackground
        nameField.placeholder = "Media title (required)"
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.layer.cornerRadius = 2
        nameField.borderStyle = .roundedRect
        nameField.autocorrectionType = .no
        return nameField
    }()
    
    let noteField: UITextField = {
        let noteField = UITextField()
        noteField.backgroundColor = .systemBackground
        noteField.placeholder = "Media notes (optional)"
        noteField.translatesAutoresizingMaskIntoConstraints = false
        noteField.layer.cornerRadius = 2
        noteField.borderStyle = .roundedRect
        noteField.autocorrectionType = .no
        return noteField
    }()
    
    let categoryPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .secondarySystemBackground
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.layer.cornerRadius = 2
        return picker
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        var configuration = UIButton.Configuration.filled()
        button.configuration = configuration
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemOrange
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup

    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [categoryPicker, nameField, noteField, saveButton])
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
  
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            categoryPicker.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension NewMediaView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CategoryType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CategoryType.allCases[row].rawValue
    }
    
    
}
