//
//  SettingsViewController.swift
//  SmartCamera
//
//  Created by Caleb Rudnicki on 7/19/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let coreDataHelper = CoreDataHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        appDelegate.userObjects = coreDataHelper.retrieveObjectFromCoreData(context: appDelegate.persistentContainer.viewContext)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This function moves back into the app after the done button is tapped
    @IBAction func doneButtonTapped(_ sender: Any) {
        coreDataHelper.clearCoreData(context: appDelegate.persistentContainer.viewContext, entity: "UserObjects")
        for i in 0...appDelegate.userObjects.count - 1 {
            coreDataHelper.addObjectToCoreData(context: appDelegate.persistentContainer.viewContext, object: appDelegate.userObjects[i])
        }
        if (UserDefaults.standard.value(forKey: "name") as? String) == nil {
            UserDefaults.standard.set("User", forKey: "name")
            performSegue(withIdentifier: "enterAppSegue", sender: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //This function sets the amount of rows of the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.householdObjects.count
    }
    
    //This function goes cell by cell and sets the title of each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = appDelegate.householdObjects[indexPath.row]
        cell.textLabel?.font = UIFont(name:"HelveticaNeue-Light", size: 16)
        cell.tintColor? = UIColor(red: 106/255, green: 204/255, blue: 12/255, alpha: 1.0)
        if (UserDefaults.standard.value(forKey: "name") as? String) == nil {
            cell.accessoryType = .checkmark
            appDelegate.userObjects.append((cell.textLabel?.text)!)
        } else if appDelegate.userObjects.contains((cell.textLabel?.text)!) {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    //This function handles the taps on the cells and toggles between checks and nothing
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if (cell?.accessoryType.rawValue == 3) {
            cell?.accessoryType = .none
            appDelegate.userObjects = appDelegate.userObjects.filter { $0 != cell?.textLabel?.text }
        } else if (cell?.accessoryType.rawValue == 0) {
            cell?.accessoryType = .checkmark
            appDelegate.userObjects.append((cell?.textLabel?.text)!)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    
}
