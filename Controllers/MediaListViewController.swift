//
//  ViewController.swift
//  ContentTracker2
//
//  Created by Sümeyra Demirtaş on 10/1/24.
//

import CoreData
import UIKit

class MediaListViewController: UIViewController {
    // MARK: - Properties
    
    private var filteredItems = [MediaListItem]()
    private var filteredSections: [CategoryType] = []

    private let searchController = UISearchController(searchResultsController: nil)
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    let newitemVC = NewItemController()
    let edititemVC = EditItemController()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // Core Data islemlerini yapabilmek icin viewContext i aliyoruz.
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "MediaItemCell")
        return table
    }()
    
    private var models = [MediaListItem]()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        view.backgroundColor = .systemBackground
        title = "Content Tracker"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        reloadTableView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addButtonTapped))
      
        NotificationCenter.default.addObserver(self, selector: #selector(didAddNewMediaItem(notification:)), name: .didAddNewMediaItem, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateMediaItem(notification:)), name: .didUpdateMediaItem, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didDeleteMediaItem(notification:)), name: .didDeleteMediaItem, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .reloadTableView, object: nil)
    }
    
    // MARK: - Functions
    
    // configureSearchController
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = false
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // didAddNewMediaItem
    @objc func didAddNewMediaItem(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let name = userInfo["name"] as? String,
              let note = userInfo["note"] as? String,
              let categoryString = userInfo["category"] as? String,
              let category = CategoryType(rawValue: categoryString) else { return }
            
        // new item i  CoreData'ya kaydet
        createItem(name: name, note: note, category: category)
        tableView.reloadData()
    }

    // didUpdateMediaItem
    @objc func didUpdateMediaItem(notification: Notification) {
        print("didUpdateMediaItem fonksiyonu tetiklendi.")
        guard let userInfo = notification.userInfo,
              let name = userInfo["name"] as? String,
              let note = userInfo["note"] as? String,
              let categoryString = userInfo["category"] as? String,
              let category = CategoryType(rawValue: categoryString),
              let itemId = userInfo["id"] as? NSManagedObjectID else { return }
        
        let item = context.object(with: itemId) as! MediaListItem
        updateItem(item: item, newName: name, newNote: note, newCategory: category)
        reloadTableView()
    }
    
    // didDeleteMediaItem
    @objc func didDeleteMediaItem(notification: Notification) {
        print("didDeleteMediaItem fonksiyonu tetiklendi.")
        guard let userInfo = notification.userInfo,
              let itemId = userInfo["id"] as? NSManagedObjectID else { return }
        
        let item = context.object(with: itemId) as! MediaListItem
        deleteItem(item: item)
        reloadTableView()
    }
    
    @objc func reloadTableView() {
        getAllItems()
        tableView.reloadData()
    }

    @objc func addButtonTapped() {
        print("Add button tapped!")
        showMyViewControllerInACustomizedSheet()
    }
    
    // - MARK: - CustomizedSheet
    
//     Add Item
//     In a subclass of UIViewController, customize and present the sheet.
    func showMyViewControllerInACustomizedSheet() {
        let viewControllerToPresent = newitemVC
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    // Edit Item
    func showMyEditItemControllerInACustomizedSheet(with item: MediaListItem) {
        let viewControllerToPresent = edititemVC
        
        edititemVC.selectedItem = item
        
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    // MARK: - Core Data
    
    func getAllItems() {
        do {
            models = try context.fetch(MediaListItem.fetchRequest())
//            print("Items: \(models)")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            print("Veriler yüklenirken hata: \(error)")
        }
    }
    
    func createItem(name: String, note: String, category: CategoryType) {
        let newItem = MediaListItem(context: context)
        newItem.name = name
        newItem.note = note
        newItem.category = category.rawValue
        do {
            try context.save()
        }
        catch {}
    }
    
    func deleteItem(item: MediaListItem) {
        context.delete(item)
        do {
            try context.save()
        }
        catch {}
    }
    
    func updateItem(item: MediaListItem, newName: String, newNote: String, newCategory: CategoryType) {
        item.name = newName
        item.note = newNote
        item.category = newCategory.rawValue
        
        do {
            try context.save()
            print("media updated")
        }
        catch {
            print("Error received: \(error)")
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MediaListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return inSearchMode ? filteredSections.count : CategoryType.allCases.count // ONEMLI:filteredItems.count ta patliyor sanirim. filtrelemeyi duzgun yapiyor gosterimi yapamiyor
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if inSearchMode {
            return filteredSections[section].rawValue
        }
        else {
            return CategoryType.allCases[section].rawValue
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            let category = filteredSections[section].rawValue
            return filteredItems.filter { $0.category == category }.count
        }
        else {
            let category = CategoryType.allCases[section].rawValue
            return models.filter { $0.category == category }.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaItemCell", for: indexPath)
            
        if inSearchMode {
            let category = filteredSections[indexPath.section].rawValue
            let filteredCategoryItems = filteredItems.filter { $0.category == category }
            let mediaItem = filteredCategoryItems[indexPath.row]
            cell.textLabel?.text = mediaItem.name
        }
        else {
            let category = CategoryType.allCases[indexPath.section].rawValue
            let filteredItems = models.filter { $0.category == category }
            let mediaItem = filteredItems[indexPath.row]
            cell.textLabel?.text = mediaItem.name
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // usttekiyle ayni mantik
        let category = CategoryType.allCases[indexPath.section].rawValue
        let filteredItems = models.filter { $0.category == category }
        let selectedItem = filteredItems[indexPath.row]
        
        showMyEditItemControllerInACustomizedSheet(with: selectedItem)
    }
}

extension MediaListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            filteredItems = models // Eğer arama metni boşsa tüm öğeleri gösteriyoruz
            filteredSections = [] // Eğer arama yapılmıyorsa tüm kategorileri göster
            tableView.reloadData()
            return
        }
            
//      Filtreleme
        filteredItems = models.filter {
            let name = $0.name?.lowercased() ?? ""
            
            return name.contains(searchText)
        }
        
        // Filtrelenmiş öğelerin kategorilerini bulalım
        filteredSections = Array(Set(filteredItems.compactMap { item in
            CategoryType(rawValue: item.category ?? "")
        }))
        
        print("DEBuG: Filtered items \(filteredItems)")
        tableView.reloadData()
    }
}
