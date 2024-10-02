//
//  ViewController.swift
//  ContentTracker2
//
//  Created by Sümeyra Demirtaş on 10/1/24.
//

import UIKit
import CoreData

class MediaListViewController: UIViewController {
    let newitemVC = NewItemController()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "MediaItemCell")
        
        return table
    }()
    
    private var models = [MediaListItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Content Tracker"
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        getAllItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addButtonTapped))
      
        NotificationCenter.default.addObserver(self, selector: #selector(didAddNewMediaItem(notification:)), name: .didAddNewMediaItem, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .reloadTableView, object: nil)
    }
    
    // MARK: - Functions
    
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

    @objc func reloadTableView() {
        getAllItems()
        tableView.reloadData()
    }

    @objc func addButtonTapped() {
        print("Add button tapped!")
        showMyViewControllerInACustomizedSheet()
    }

    // In a subclass of UIViewController, customize and present the sheet.
    func showMyViewControllerInACustomizedSheet() {
        let viewControllerToPresent = newitemVC
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
        }
        catch {}
    }
    
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

}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MediaListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return CategoryType.allCases.count
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
}
