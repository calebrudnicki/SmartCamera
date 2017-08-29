//
//  CoreDataHelper.swift
//  SmartCamera
//
//  Created by Caleb Rudnicki on 7/18/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHelper: NSObject {
    
    //This function adds a new alarm to CoreData
    @available(iOS 10.0, *)
    func addAlarmToCoreData(context: NSManagedObjectContext, time: Date) {
        let newTime = NSEntityDescription.insertNewObject(forEntityName: "Alarm", into: context)
        newTime.setValue(time, forKey: "time")
        do {
            try context.save()
        } catch let error as NSError {
            fatalError("Failed to add time to Core Data: \(error)")
        }
    }
    
    //This function clears CoreData of a specific entity
    @available(iOS 10.0, *)
    func clearCoreData(context: NSManagedObjectContext, entity: String) {
        print("Clearing " + entity)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.returnsObjectsAsFaults = false
        if let result = try? context.fetch(request) {
            for object in result {
                context.delete(object as! NSManagedObject)
            }
        }
    }
    
    //This function returns the alarm from CoreData
    @available(iOS 10.0, *)
    func retrieveAlarmFromCoreData(context: NSManagedObjectContext) -> NSManagedObject {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Alarm")
        request.returnsObjectsAsFaults = false
        let currentData: NSManagedObject? = nil
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    return result
                }
            }
        } catch let error as NSError {
            fatalError("Failed to retrieve alarm: \(error)")
        }
        return currentData!
    }
    
    //This function adds a new object to CoreData
    @available(iOS 10.0, *)
    func addObjectToCoreData(context: NSManagedObjectContext, object: String) {
        let newObject = NSEntityDescription.insertNewObject(forEntityName: "UserObjects", into: context)
        newObject.setValue(object, forKey: "object")
        do {
            try context.save()
        } catch let error as NSError {
            fatalError("Failed to add time to Core Data: \(error)")
        }
    }
    
    //This function returns an array of all of the objects from CoreData
    @available(iOS 10.0, *)
    func retrieveObjectFromCoreData(context: NSManagedObjectContext) -> [String] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserObjects")
        request.returnsObjectsAsFaults = false
        var currentUserObjects: [String] = []
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    currentUserObjects.append(result.value(forKey: "object") as! String)
                }
            }
        } catch let error as NSError {
            fatalError("Failed to retrieve alarm: \(error)")
        }
        return currentUserObjects
    }

}
