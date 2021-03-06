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
    var selectedAnimal: Animal?
    
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        if let animalName = self.animals[indexPath.row].valueForKey("name") {
            cell.textLabel?.text = animalName as? String
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
        if Constants.ref.authData != nil {
            
            
            //update DB
            let userId = Constants.ref.authData.uid
            let currentUserRef = Constants.ref.childByAppendingPath("users/\(userId)")
            
            if let name = self.animals[indexPath.row].valueForKey("name") as? String, url = self.animals[indexPath.row].valueForKey("url") as? String {
        
                let selectedPet = ["currentPet": name]
                currentUserRef.updateChildValues(selectedPet)
           
                
                let selectedPetUrl = ["currentPetUrl": url]
                currentUserRef.updateChildValues(selectedPetUrl)
            
            
                //update locally
                selectedAnimal = Animal(name: name, url: NSURL(string: url)!)
            }
            
            self.performSegueWithIdentifier("animalHomeSegue", sender: self)
            
        } else {
            // No user is signed in
            print("no user signed in")
        }
    }
    
    func fetchAnimals(){
        
        Constants.ref.childByAppendingPath("animals").observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.animals = self.parseAnimalSnapshot(snapshot)
            self.tableView.reloadData()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if let svc = segue.destinationViewController as? HomeViewController{
            svc.myAnimal = self.selectedAnimal
        }
    }
    
    func parseAnimalSnapshot(snapshot: FDataSnapshot) -> NSArray{
        
        let animalsObjectArray: NSMutableArray = NSMutableArray()

        for childSnap in  snapshot.children.allObjects as! [FDataSnapshot]{
            let animalName = childSnap.key as NSString
            if let url = childSnap.value["url"] as? String{
                animalsObjectArray.addObject(Animal(name:animalName, url: NSURL(string:url)!))
            }
        }
        return animalsObjectArray
    }
}
