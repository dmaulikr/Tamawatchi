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
        
        print("login view did load")

    }
    
    override func viewDidAppear(animated: Bool) {
        
        print("stored user: \(FBSDKAccessToken.currentAccessToken())")
        
        if(FBSDKAccessToken.currentAccessToken() != nil){
            
            //TEMP
            print("seguing from login")
            
            self.loginFirebase()
//            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("chooseAnimalVC") as UIViewController
//            self.presentViewController(viewController, animated: false, completion: nil)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginPressed(){
        
            let ref = Firebase(url: "https://brilliant-fire-4695.firebaseio.com")
            let facebookLogin = FBSDKLoginManager()
        
            facebookLogin.loginBehavior = FBSDKLoginBehavior.SystemAccount

            facebookLogin.logInWithReadPermissions(["public_profile"],  fromViewController: self, handler: {
                (facebookResult, facebookError) -> Void in
                
                if facebookError != nil {
                    print("Facebook login failed. Error \(facebookError)")
                } else if facebookResult.isCancelled {
                    print("Facebook login was cancelled.")
                } else {
                    self.loginFirebase()
                    //let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
//                    ref.authWithOAuthProvider("facebook", token: accessToken,
//                        withCompletionBlock: { error, authData in
//                            if error != nil {
//                                print("Login failed. \(error)")
//                            } else {
//                                print("Logged in! \(authData)")
//                                
//                                //check if user already exists
//                                ref.childByAppendingPath("users/\(authData.uid)").observeEventType(.Value, withBlock: { snapshot in
//                                    print("snapshot is: \(snapshot)")
//                                    if(!snapshot.exists()){
//                                        print("made new user")
//                                        let newUser: NSDictionary = ["provider": authData.provider, "displayName": authData.valueForKeyPath("providerData.displayName")! ]
//                                        
//                                        ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
//                                        
//                                        NSUserDefaults.standardUserDefaults().setObject(authData, forKey: "currentUser")
//                                        self.performSegueWithIdentifier("chooseAnimal", sender: self)
//                                    }
//                                    else{
//                                        print("snapshot has child: \(snapshot.hasChild("currentPet")) and the path is: \(snapshot.childSnapshotForPath("currentPet"))")
//                                            
//                                        if(snapshot.hasChild("currentPet") && snapshot.childSnapshotForPath("currentPet") != "none"){
//                                           
//                                            print("in if")
//                                            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("homeVC") as UIViewController
//                                            self.presentViewController(viewController, animated: true, completion: nil)
//                                        }
//                                        else{
//                                            print("segue to choose animal")
//                                            
//                                            
//                                            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("chooseAnimalVC") as UIViewController
//                                            self.presentViewController(viewController, animated: true, completion: nil)
//                                          
//                                            
//                                        }
//                                    }
//                                })
//                            }
//                    })
                }
            })
        
           }
    
    
    func loginFirebase() {
        
        let ref = Firebase(url: "https://brilliant-fire-4695.firebaseio.com")
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
                            
                            let defaults = NSUserDefaults.standardUserDefaults()
                            defaults.setObject(snapshot.childSnapshotForPath("currentPet").value as! String, forKey: "myAnimal")
                            
                            if(snapshot.hasChild("currentPet") && snapshot.childSnapshotForPath("currentPet") != "none"){
                                
                                print("in if")
                                let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("homeVC") as UIViewController
                                print("set vc")
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