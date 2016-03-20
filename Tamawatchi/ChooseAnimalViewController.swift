//
//  ViewController.swift
//  Tamawatchi
//
//  Created by Morgan Steffy on 3/15/16.
//  Copyright © 2016 Morgan Steffy. All rights reserved.
//

import UIKit
import Firebase



class ChooseAnimalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var animals: NSArray = NSArray()
    let ref = Firebase(url: "https://brilliant-fire-4695.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        fetchAnimals()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.animals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = "ANIMAL: \(self.animals[indexPath.row].valueForKey("name")!)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let userId = ref.authData.uid
        print("auth: \(userId)")
        let currentUserRef = self.ref.childByAppendingPath("users/\(userId)")
        let selectedPet = ["currentPet": self.animals[indexPath.row].valueForKey("name") as! String]
        
        currentUserRef.updateChildValues(selectedPet)
        self.performSegueWithIdentifier("animalHomeSegue", sender: self)
    }
    
    func fetchAnimals(){
        
        print("fetching animal")
        
        

        if ((ref.authData) != nil) {
            // user authenticated
            print("auth: \(ref.authData)")
        } else {
            // No user is signed in
        }
        
        ref.childByAppendingPath("animals").observeSingleEventOfType(.Value, withBlock: { snapshot in

            self.animals = self.parseAnimalSnapshot(snapshot)
            self.tableView.reloadData()
        })
    }
    
    func parseAnimalSnapshot(snapshot: FDataSnapshot) -> NSArray{
        
        let animalsObjectArray: NSMutableArray = NSMutableArray()
        
        for childSnap in  snapshot.children.allObjects as! [FDataSnapshot]{
            let animalName = childSnap.key as NSString
            let url = childSnap.value["url"]
            animalsObjectArray.addObject(Animal(name:animalName, url: NSURL(string:url as! NSString as String)!))
        }
        
        return animalsObjectArray
    }
}

class Animal: NSObject {
    
    var name = NSString()
    var url = NSURL()
    
    init(name: NSString, url: NSURL) {
        self.name = name
        self.url = url
    }
}