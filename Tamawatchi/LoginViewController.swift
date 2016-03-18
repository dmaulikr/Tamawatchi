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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton: FBSDKLoginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        loginButton.addTarget(self, action: "loginPressed", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginButton)
        
        
        if((NSUserDefaults.standardUserDefaults().objectForKey("currentUser")?.exists()) != nil){
            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("homeVC") as UIViewController
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginPressed(){
        
            let ref = Firebase(url: "https://brilliant-fire-4695.firebaseio.com")
            let facebookLogin = FBSDKLoginManager()
            facebookLogin.logInWithReadPermissions(["public_profile"],  fromViewController: self, handler: {
                (facebookResult, facebookError) -> Void in
                
                if facebookError != nil {
                    print("Facebook login failed. Error \(facebookError)")
                } else if facebookResult.isCancelled {
                    print("Facebook login was cancelled.")
                } else {
                    let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                    ref.authWithOAuthProvider("facebook", token: accessToken,
                        withCompletionBlock: { error, authData in
                            if error != nil {
                                print("Login failed. \(error)")
                            } else {
                                print("Logged in! \(authData)")
                                
                                //check if user already exists
                                ref.childByAppendingPath("users/\(authData.uid)").observeEventType(.Value, withBlock: { snapshot in
                                    print("snapshot is: \(snapshot)")
                                    if(!snapshot.exists()){
                                        print("made new user")
                                        let newUser: NSDictionary = ["provider": authData.provider, "displayName": authData.valueForKeyPath("providerData.displayName")! ]
                                        
                                        ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
                                        
                                        NSUserDefaults.standardUserDefaults().setObject(authData, forKey: "currentUser")
                                        self.performSegueWithIdentifier("chooseAnimal", sender: self)
                                    }
                                    else{
                                        print("snapshot has child: \(snapshot.hasChild("currentPet")) and the path is: \(snapshot.childSnapshotForPath("currentPet"))")
                                            
                                        if(snapshot.hasChild("currentPet") && snapshot.childSnapshotForPath("currentPet") != "none"){
                                            
                                            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("homeVC") as UIViewController
                                            self.presentViewController(viewController, animated: true, completion: nil)
                                        }
                                        else{
                                            print("segue to choose animal")
                                           
                                            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("chooseAnimalVC") as UIViewController
                                            self.presentViewController(viewController, animated: true, completion: nil)
                                        }
                                    }
                                })
                            }
                    })
                }
            })
        
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