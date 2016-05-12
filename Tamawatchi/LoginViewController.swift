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
        
        //idk if this is running
        if(FBSDKAccessToken.currentAccessToken() != nil){
            
            self.loginFirebase()
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginPressed(){
        
//        let facebookLogin = FBSDKLoginManager()
//        facebookLogin.loginBehavior = FBSDKLoginBehavior.SystemAccount
//        facebookLogin.logInWithReadPermissions(["public_profile"],  fromViewController: self, handler: {
//            (facebookResult, facebookError) -> Void in
//            
//            if facebookError != nil {
//                print("Facebook login failed. Error \(facebookError)")
//            } else if facebookResult.isCancelled {
//                print("Facebook login was cancelled.")
//            } else {
//                self.loginFirebase()
//            }
//        })
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
                          
                                self.selectedAnimal = Animal(name: snapshot.childSnapshotForPath("currentPet").value as! String, url: NSURL(string: snapshot.childSnapshotForPath("currentPetUrl").value as! String)!)
                                
                              //  self.segueToViewControllerWithIdentifier("homeVC")
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
        print("segue with: \(self.selectedAnimal!)")
        if(segue.identifier == "loginToHomeSegue"){
            let svc = segue.destinationViewController as! HomeViewController;
            svc.myAnimal = self.selectedAnimal!
            svc.test = 12
        }
        
    }
    
    func newUser(authData: FAuthData){
        
        let newUser: NSDictionary = ["provider": authData.provider, "displayName": authData.valueForKeyPath("providerData.displayName")! ]
        
        Constants.ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
        
        self.defaults.setObject(authData, forKey: "currentUser")
        self.performSegueWithIdentifier("chooseAnimal", sender: self)

    }
    
    func segueToViewControllerWithIdentifier(indentifier: String){
        
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier(indentifier) as UIViewController
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    
    
    func setPushToken(){
        
        let userId = Constants.ref.authData.uid
        let currentUserRef = Constants.ref.childByAppendingPath("users/\(userId)")
        let pushToken = ["pushToken": self.defaults.valueForKey("pushToken") as! String]
        currentUserRef.updateChildValues(pushToken)
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