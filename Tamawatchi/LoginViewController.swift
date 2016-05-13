//
//  ViewController.swift
//  Tamawatchi
//
//  Created by Morgan Steffy on 3/15/16.
//  Copyright © 2016 Morgan Steffy. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKShareKit

class LoginViewController: UIViewController {
    
    var currentUser: FAuthData = FAuthData()
    let defaults = NSUserDefaults.standardUserDefaults()
    var selectedAnimal: Animal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton: FBSDKLoginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        loginButton.addTarget(self, action: "loginPressed", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if(FBSDKAccessToken.currentAccessToken() != nil){
            
            self.loginFirebase()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loginFirebase() {
        
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        Constants.ref.authWithOAuthProvider("facebook", token: accessToken,
            withCompletionBlock: { error, authData in
                if error != nil {
                    print("Login failed. \(error)")
                } else {
                    print("Logged in! \(authData)")
                    
                    //check if user already exists
                    Constants.ref.childByAppendingPath("users/\(authData.uid)").observeEventType(.Value, withBlock: { snapshot in
                    
                        if(!snapshot.exists()){
                            
                            self.newUser(authData)
                        }
                        else{
                            
                            if(snapshot.hasChild("currentPet") && snapshot.childSnapshotForPath("currentPet") != "none"){
                          
                                if let name = snapshot.childSnapshotForPath("currentPet").value as? String, url = snapshot.childSnapshotForPath("currentPetUrl").value as? String {
                                    self.selectedAnimal = Animal(name: name, url: NSURL(string: url)!)
                                }
                                
                                self.performSegueWithIdentifier("loginToHomeSegue", sender: self)
                            }
                            else{
                                self.segueToViewControllerWithIdentifier("chooseAnimalVC")
                            }
                        }
                        
                        //set user push token
                        self.setPushToken()
                    })
                }
        })

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        if(segue.identifier == "loginToHomeSegue"){
            if let svc = segue.destinationViewController as? HomeViewController{
                svc.myAnimal = self.selectedAnimal
            }
        }
        
    }
    
    func newUser(authData: FAuthData){
        
        if let displayName = authData.valueForKeyPath("providerData.displayName"){
            
            let newUser: NSDictionary = ["provider": authData.provider, "displayName": displayName]
            Constants.ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
        }
        
        self.defaults.setObject(authData, forKey: "currentUser") //maybe not needed anymore?
        self.performSegueWithIdentifier("chooseAnimal", sender: self)

    }
    
    func segueToViewControllerWithIdentifier(indentifier: String){
        
        if let storyboard = self.storyboard {
            let viewController = storyboard.instantiateViewControllerWithIdentifier(indentifier) as UIViewController
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    
    func setPushToken(){
        
        let userId = Constants.ref.authData.uid
        let currentUserRef = Constants.ref.childByAppendingPath("users/\(userId)")
        if let pushToken = self.defaults.valueForKey("pushToken") as? String{
            
            let pushToken = ["pushToken": pushToken]
            currentUserRef.updateChildValues(pushToken)
        }
    }
    
   
    func topMostController()-> UIViewController {
        var topController = UIApplication.sharedApplication().keyWindow?.rootViewController
        
        while((topController?.presentedViewController) != nil){
            topController = topController?.presentedViewController
        }
        if(topController != nil){
            return topController!
        }
        else{
            return self
        }
    }
}