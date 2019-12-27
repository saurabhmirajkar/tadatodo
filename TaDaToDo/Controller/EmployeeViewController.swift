//
//  EmployeeViewController.swift
//  TaDaToDo
//
//  Created by Saurabh Mirajkar on 27/12/19.
//  Copyright © 2019 Saurabh Mirajkar. All rights reserved.
//

import UIKit

class EmployeeViewController: UIViewController {

    @IBOutlet weak var employeeTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var employeeArray = [Employee]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        employeeTableView.delegate = self
        employeeTableView.dataSource = self
        fetchEmployees()
    }
    
    func fetchEmployees() {
        employeeTableView.isHidden = true
        self.activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        let session = URLSession.shared
        let url = URL(string: "http://dummy.restapiexample.com/api/v1/employees")!
        
        let task = session.dataTask(with: url) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let jsonData = json as? [NSDictionary] {
                    for data in jsonData {
                        let employee = Employee(employeeAge: data["employee_age"] as? String, employeeName: data["employee_name"] as? String, employeeSalary: data["employee_salary"] as? String, id: data["id"] as? String)
                        self.employeeArray.append(employee)
                    }
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.employeeTableView.isHidden = false
                        self.employeeTableView.reloadData()
                    }
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

}

extension EmployeeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "employeeCell", for: indexPath) as! EmployeeTableViewCell
        let employee = employeeArray[indexPath.row]
        cell.idLabel.text = employee.id
        cell.nameLabel.text = employee.employeeName
        cell.salaryLabel.text = employee.employeeSalary
        cell.ageLabel.text = employee.employeeAge
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
