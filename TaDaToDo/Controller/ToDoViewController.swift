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
        newItem.setValue(false, forKey: "done")
        
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
    
    func updateItem(textName: String, operation: String, isDone: Bool = false) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
        let predicate = NSPredicate(format: "title == %@", textName)
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let objectUpdate = result[0] as NSManagedObject
            
            if operation == "remove" {
                objectUpdate.setValue("true", forKey: "isRemoved")
            } else if operation == "update" {
                objectUpdate.setValue(isDone, forKey: "done")
            }
            
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
        cell.titleLabel.text = item.value(forKey: "title") as? String
        if let doneStatus = item.value(forKey: "done") as? Bool {
           cell.accessoryType = doneStatus ? .checkmark : .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemsArray[indexPath.row]
        guard let newItem = item.value(forKey: "title") as? String else { return }
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                updateItem(textName: newItem, operation: "update", isDone: false)
            } else {
                cell.accessoryType = .checkmark
                updateItem(textName: newItem, operation: "update", isDone: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = itemsArray[indexPath.row]
            guard let newItem = item.value(forKey: "title") as? String else { return }
            updateItem(textName: newItem, operation: "remove")
            fetchItems()
            todoTableView.reloadData()
            showToast(message: "Item moved to Trash")
        }
    }
    
}

extension ToDoViewController {
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height - 100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "Arial", size: 15)!
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
