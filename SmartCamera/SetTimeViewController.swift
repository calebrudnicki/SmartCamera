//
//  SetAlarmViewController.swift
//  SmartCamera
//
//  Created by Caleb Rudnicki on 7/18/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit
import CoreData

class SetAlarmViewController: UIViewController {

    @IBOutlet weak var alarmPicker: UIDatePicker!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //This function dismissed the view when the cancel button is tapped
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //This function saves the new time when the save button is tapped
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let coreDataHelper = CoreDataHelper()
        coreDataHelper.clearCoreData(context: appDelegate.persistentContainer.viewContext, entity: "Alarm")
        coreDataHelper.addAlarmToCoreData(context: appDelegate.persistentContainer.viewContext, time: alarmPicker.date)
        UserDefaults.standard.set(false, forKey: "coreDataIsEmpty")
        UserDefaults.standard.set(true, forKey: "alarmIsOn")
        dismiss(animated: true, completion: nil)
    }
    
}
