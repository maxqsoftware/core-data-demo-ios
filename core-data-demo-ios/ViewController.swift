//
//  ViewController.swift
//  core-data-demo-ios
//
//  Taken from Ray Wenderlich tutorial
//  https://www.raywenderlich.com/7569-getting-started-with-core-data-tutorial
//
//  Created by Daniel Greenheck on 3/24/20.
//  Copyright © 2020 Max Q Software LLC. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataIdentifiers.personEntity)
        
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    // Implement the addName IBAction
    @IBAction func addName(_ sender: UIBarButtonItem) {
      let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)

      let saveAction = UIAlertAction(title: "Save", style: .default) {[unowned self] action in
        guard let textField = alert.textFields?.first,
          let nameToSave = textField.text else {
            return
        }
        
        self.save(name: nameToSave)
        self.tableView.reloadData()
      }

      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

      alert.addTextField()
      alert.addAction(saveAction)
      alert.addAction(cancelAction)

      present(alert, animated: true)
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // Get the main queue context associatd with the CoreData model
        let managedContext = appDelegate.persistentContainer.viewContext
        // Obtain the schema for the entity
        let entity = NSEntityDescription.entity(forEntityName: CoreDataIdentifiers.personEntity, in: managedContext)!
        // Create new instance of the "Person" entity
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        person.setValue(name, forKeyPath: "name")
        
        // Save the context
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return people.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let person = people[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = person.value(forKeyPath: CoreDataIdentifiers.nameAttribute) as? String
    return cell
  }
}
