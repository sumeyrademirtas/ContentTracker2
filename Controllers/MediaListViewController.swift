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
        return inSearchMode ? filteredItems.count : CategoryType.allCases.count // ONEMLI:filteredItems.count ta patliyor sanirim. filtrelemeyi duzgun yapiyor gosterimi yapamiyor
                
//        return CategoryType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return CategoryType.allCases[section].rawValue // enumdan tum case leri aliyor, her section ile case id yi eslestirip case in raw value sunu headerin title ina veriyor
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let category = CategoryType.allCases[section].rawValue // sectiona karsilik gelen kategoriyi belirliyoruz
        return models.filter { $0.category == category }.count // media itemlari tek tek alip filtreliyoruz. eger ustteki kategori ile item kategorisi eslesirse diziye ekliyoruz. sonra da toplam sayisini aliyoruz.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaItemCell", for: indexPath)
            
        let category = CategoryType.allCases[indexPath.section].rawValue // section kategorisini belirliyoruz.
        
        
//        let filteredItems = models.filter { mediaItem in
//                return mediaItem.category == currentCategory
//            }
        let filteredItems = models.filter { $0.category == category } // ustteki kategori ile item kategorisi eslesenleri diziye ekliyoruz.
        let mediaItem = filteredItems[indexPath.row] // satira denk gelen filtrelenmis item i aliyoruz
        cell.textLabel?.text = mediaItem.name // sonra da ismini yazdiriyoruz
            
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
            tableView.reloadData()
            return
        }
            
//      Filtreleme 
        filteredItems = models.filter {
            let name = $0.name?.lowercased() ?? ""
            let category = $0.category?.lowercased() ?? ""
            
            return name.contains(searchText) || category.contains(searchText)
        }
        
//        filteredItems = models.filter ({
//            (($0.name?.contains(searchText)) != nil) ||
//            (($0.category?.contains(searchText)) != nil)})
            
        print("DEBuG: Filtered items \(filteredItems)")
        tableView.reloadData()
    }
}


//extension MediaListViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
//
//        filteredItems = models.filter {
//            $0.name!.contains(searchText) ||
//                $0.category!.lowercased().contains(searchText)
//        }
//
//        print("DEBuG: Filtered users \(filteredItems)")
//        tableView.reloadData()
//    }
//}



//    func deleteAllItems() {
//        let fetchRequest: NSFetchRequest<MediaListItem> = MediaListItem.fetchRequest()
//
//        do {
//            let items = try context.fetch(fetchRequest)
//
//            for item in items {
//                context.delete(item)
//            }
//
//            try context.save()
//            print("Tüm veriler başarıyla silindi.")
//
//        } catch {
//            print("Veriler silinirken bir hata oluştu: \(error)")
//        }
//    }
