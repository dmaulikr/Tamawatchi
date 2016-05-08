//
//  ViewController.swift
//  Tamawatchi
//
//  Created by Morgan Steffy on 3/15/16.
//  Copyright © 2016 Morgan Steffy. All rights reserved.
//

import UIKit
import Firebase
import QuartzCore
import UIView_Shake
import Foundation
import AWBanner

class HomeViewController: UIViewController {
    
    @IBOutlet weak var mediaView: UIWebView!
    @IBOutlet weak var userProgress: UIProgressView!
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var hydrateButton: UIButton!
    
    var myAnimal: String?
    let ref = Firebase(url: "https://brilliant-fire-4695.firebaseio.com")

    var decreaseTimerJob: NSTimer = NSTimer()
    var earthQuakeJob: NSTimer = NSTimer()
    var changeDelta: NSTimer = NSTimer()
    var thanksMessages: [String] = []
    
    var delta: Float = 15.0
    var earthQuakeOver: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startEarthquake:", name:"startEarthquake", object: nil)
        
        self.tapButton.hidden = true
        
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        self.myAnimal = defaults.stringForKey("myAnimal")
        self.tapButton.layer.cornerRadius = self.tapButton.frame.width*0.5
        
        print("in home vc")
        
        ref.childByAppendingPath("animals/\(myAnimal!)/url").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if(snapshot.exists()){
                let requestObj = NSURLRequest(URL: NSURL(string: snapshot.value as! String)!)
                self.mediaView.allowsInlineMediaPlayback = true;
                self.mediaView.mediaPlaybackRequiresUserAction = false;
                self.mediaView.loadRequest(requestObj)
                
                print("url: \(snapshot.value as! String)!), my animal: \(self.myAnimal!)")

            }
            else{
                print("animal: \(self.myAnimal!) doesnt exisit")
            }
            
        })
        
        ref.childByAppendingPath("messages/thanks").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if(snapshot.exists()){
                
                for childSnap in  snapshot.children.allObjects as! [FDataSnapshot]{
                    let response = childSnap.value as! NSString
                   // let url = childSnap.value["url"]
                    print("About to add obj: \(response)")
                    self.thanksMessages.append(response as String)
                }
            }
            else{
               self.thanksMessages.append("Thanks!")
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //refactor name when final purpose is determined
    @IBAction func bottomButtonPressed(sender: AnyObject) {
        
        AWBanner.showWithDuration(2.5,
            delay: 0.0,
            message: NSLocalizedString(self.thanksMessages[Int(arc4random_uniform(UInt32(self.thanksMessages.count-1)))] , comment: ""),
            backgroundColor: UIColor(red:0.25, green:0.73, blue:0.56, alpha:1.0),
            textColor: UIColor.whiteColor(),
            originY: 20.0)
        
        //update lastFed in DB (save in timeIntervalSince1970 string format)
        let userId = ref.authData.uid
        print("auth: \(userId)")
        let currentUserRef = self.ref.childByAppendingPath("users/\(userId)")
        let now: String = "\(NSDate().timeIntervalSince1970)"
        let lastFed = ["lastFed": now]
        currentUserRef.updateChildValues(lastFed)


        
        //disable for a short time
        self.hydrateButton.enabled = false
        let resetButton = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("enableButton"), userInfo: nil, repeats: false)
    }
    
    func startEarthquake(notification: NSNotification){
        
        self.userProgress.hidden = false
        self.tapButton.hidden = false
        self.hydrateButton.userInteractionEnabled = false
        
        self.userProgress.progress = 0.5
        
        
        self.earthQuakeJob = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("earthquake:"), userInfo: nil, repeats: true)
        
        self.decreaseTimerJob = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("decreaseProgress"), userInfo: nil, repeats: true)
        
        self.changeDelta = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("changeDeltaFunction"), userInfo: nil, repeats: true)
        
        
        //update lastEarthquake in DB (save in timeIntervalSince1970 string format)
        let userId = ref.authData.uid
        print("auth: \(userId)")
        let currentUserRef = self.ref.childByAppendingPath("users/\(userId)")
        let now: String = "\(NSDate().timeIntervalSince1970)"
        let lastFed = ["lastEarthquake": now]
        currentUserRef.updateChildValues(lastFed)
    }
    
    
    @IBAction func tapButtonPressed(sender: AnyObject) {
        updateProgressBarBy((1/self.userProgress.progress)/75);
    }
    
    
    func earthquake(timer: NSTimer){
        
        self.mediaView.shake(Int32((1/self.userProgress.progress)*1), withDelta: CGFloat(self.delta), speed: NSTimeInterval(0.5/((1/self.userProgress.progress)*1))) { () -> Void in
            
            //if finished, show alert
            if(self.userProgress.progress > 0.99 && self.earthQuakeOver == false)
            {
                self.earthQuakeOver = true
                self.decreaseTimerJob.invalidate()
                self.earthQuakeJob.invalidate()
                self.changeDelta.invalidate()
                
                self.showAlert("Nice Job!", message: "Thanks to you, your \(self.myAnimal!) survived.", cancelButton: "OK")
                
                self.userProgress.hidden = true
                self.tapButton.hidden = true
                self.hydrateButton.userInteractionEnabled = true
                
            }
        }
    }
    
    func updateProgressBarBy(incrementValue: Float){
        
        //without this, it would never reach finish
        if(self.userProgress.progress > 0.99)
        {
            self.userProgress.progress = 1;
        }
        else{
            self.userProgress.progress += incrementValue
        }
    }
    
    func decreaseProgress()
    {
        if(self.userProgress.progress > 0.01){
            self.userProgress.progress -= 0.0025;
    }
        else{
            self.decreaseTimerJob.invalidate()
            self.earthQuakeJob.invalidate()
            self.changeDelta.invalidate()
            
            self.showAlert("Uh oh!", message: "Your \(self.myAnimal!) died. Do you even care?", cancelButton: "OK")
            
            self.userProgress.hidden = true
            self.tapButton.hidden = true
            self.hydrateButton.userInteractionEnabled = true
            
            self.petDied()
            
            UIView.animateWithDuration(1.5, animations: {
                self.mediaView.alpha = 0
            })
        }
    }
    
    func changeDeltaFunction(){
        self.delta = Float(arc4random_uniform(10) + UInt32(5))
    }
    
    
    func petDied (){
        
        //update DB
        let userId = ref.authData.uid
        print("auth: \(userId)")
        let postRef = self.ref.childByAppendingPath("users/\(userId)").childByAppendingPath("deadPets")
        let petInfo = ["type": self.myAnimal!]
        let post1Ref = postRef.childByAutoId()
        post1Ref.setValue(petInfo)
    }
    
    @IBAction func newPetPressed(sender: AnyObject) {
        
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("chooseAnimalVC") as UIViewController
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // *** HELPERS ***
    
    func showAlert(title: String, message: String, cancelButton: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: cancelButton, style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func enableButton(){
        print("enable")
        self.hydrateButton.userInteractionEnabled = true
        print("d")
    }
    
    func startVideo() {
        
       // self.mediaView.stringByEvaluatingJavaScriptFromString("var theEvent = document.createEvent('MouseEvent');\n theEvent.initMouseEvent('click', true, true, window);\n awElement.dispatchEvent(theEvent);\n awElement.click();\n", 10, 10)
        
        
        
        //[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var theEvent = document.createEvent('MouseEvent');\n theEvent.initMouseEvent('click', true, true, window);\n awElement.dispatchEvent(theEvent);\n awElement.click();\n", mouseX, mouseY]];
    }

}