//
//  ViewController.swift
//  TaDaToDo
//
//  Created by Saurabh Mirajkar on 27/12/19.
//  Copyright © 2019 Saurabh Mirajkar. All rights reserved.
//

import UIKit
import CoreData

class ToDoViewController: UIViewController {
    
    @IBOutlet weak var todoTableView: UITableView!
    
    var itemsArray = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        todoTableView.dataSource = self
        todoTableView.delegate = self
        fetchItems()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            guard let text = textField.text else { return }
            if text.isEmpty { return }
            self.saveItem(title: text)
            self.todoTableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItem(title: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext)!
        let newItem = NSManagedObject(entity: entity, insertInto: managedContext)
        newItem.setValue(title, forKeyPath: "title")
        newItem.setValue("false", forKeyPath: "isRemoved")
        
        do {
            try managedContext.save()
            itemsArray.append(newItem)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
        let predicate = NSPredicate(format: "isRemoved == %@", "false")
        fetchRequest.predicate = predicate
        
        do {
            itemsArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func updateItem(textName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
        let predicate = NSPredicate(format: "title == %@", textName)
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let objectUpdate = result[0] as NSManagedObject
            objectUpdate.setValue("true", forKey: "isRemoved")
            
            do {
                try managedContext.save()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

}

extension ToDoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! ToDoTableViewCell
        cell.textLabel?.text = item.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = itemsArray[indexPath.row]
            guard let newItem = item.value(forKey: "title") as? String else { return }
            updateItem(textName: newItem)
            fetchItems()
            todoTableView.reloadData()
        }
    }
    
}
