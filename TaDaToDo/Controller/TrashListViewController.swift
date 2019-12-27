//
//  TrashListViewController.swift
//  TaDaToDo
//
//  Created by Saurabh Mirajkar on 28/12/19.
//  Copyright © 2019 Saurabh Mirajkar. All rights reserved.
//

import UIKit
import CoreData

class TrashListViewController: UIViewController {

    @IBOutlet weak var trashTableView: UITableView!
    
    var itemsArray = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trashTableView.delegate = self
        trashTableView.dataSource = self
        fetchItems()
        trashTableView.reloadData()
    }
    
    func fetchItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
        let predicate = NSPredicate(format: "isRemoved == %@", "true")
        fetchRequest.predicate = predicate
        
        do {
            itemsArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

}

extension TrashListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trashCell", for: indexPath)
        let item = itemsArray[indexPath.row]
        cell.textLabel?.textColor = #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)
        cell.textLabel?.text = item.value(forKey: "title") as? String
        return cell
    }
    
    
}
