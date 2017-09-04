//
//  MyAlarmViewController.swift
//  SmartCamera
//
//  Created by Caleb Rudnicki on 7/18/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit
import UserNotifications

class MyAlarmViewController: UIViewController {

    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var alarmHour: Int?
    var alarmMinute: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func alarmSwitchTapped(_ sender: Any) {
        if (UserDefaults.standard.value(forKey: "alarmIsOn") as? Bool) == true {
            UserDefaults.standard.set(false, forKey: "alarmIsOn")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        } else {
            UserDefaults.standard.set(true, forKey: "alarmIsOn")
            self.createNotification(hour: alarmHour!, minute: alarmMinute!, id: "ID")
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        alarmSwitch.setOn((UserDefaults.standard.value(forKey: "alarmIsOn") as? Bool)!, animated: true)
        if (UserDefaults.standard.value(forKey: "coreDataIsEmpty") as? Bool) == false {
            let coreDataHelper = CoreDataHelper()
            let alarmObject = coreDataHelper.retrieveAlarmFromCoreData(context: appDelegate.persistentContainer.viewContext) as! Alarm
            let dateObject = alarmObject.time! as Date
            self.changeAlarmLabel(dateObject: dateObject)
        }
        if (UserDefaults.standard.value(forKey: "alarmIsOn") as? Bool) == true {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            alarmSwitch.isOn = true
            self.createNotification(hour: alarmHour!, minute: alarmMinute!, id: "ID")
        }
        print(alarmLabel.text)
        if alarmLabel.text == "No Alarm" {
            alarmSwitch.isEnabled = false
        } else {
            alarmSwitch.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Helper Functions
    
    //This function changes the alarm label based on the date object passed in
    func changeAlarmLabel(dateObject: Date) {
        var amPM = "AM"
        var minuteString = ""
        let calendar = NSCalendar.current
        var hour = calendar.component(.hour, from: dateObject as Date)
        let minutes = calendar.component(.minute, from: dateObject as Date)
        alarmHour = hour
        alarmMinute = minutes
        //Make changes for the hour
        if hour > 12 {
            hour = hour - 12
            amPM = "PM"
        } else if hour == 0 {
            hour = 12
        }
        //Make changes for the minute
        if minutes < 10 {
            minuteString = "0" + String(minutes)
        } else {
            minuteString = String(minutes)
        }
        alarmLabel.text = "\(hour):" + minuteString + " \(amPM)"
    }
    
    func createNotification(hour: Int, minute: Int, id: String) {
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour, minute: minute), repeats: true)
        print(trigger.nextTriggerDate() ?? "nil")
        
        let openAppAction = UNNotificationAction(identifier: "OpenApp", title: "Open App", options: .foreground)
        
        let category = UNNotificationCategory(identifier: "cat", actions: [openAppAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let content = UNMutableNotificationContent()
        content.title = "Your " + alarmLabel.text! + " alarm"
        content.body = "Open this notification app to turn off the alarm"
        content.sound = UNNotificationSound.init(named: "alarm.wav")
        content.categoryIdentifier = "cat"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error)
                return
            }
            print("scheduled")
        }
    }
    
}
