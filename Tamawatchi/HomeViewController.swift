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


class HomeViewController: UIViewController {
    
    @IBOutlet weak var mediaView: UIWebView!
    @IBOutlet weak var userProgress: UIProgressView!
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var hydrateButton: UIButton!
    
    var myAnimal: Animal!
    var test: Int!

    var decreaseTimerJob: NSTimer = NSTimer()
    var earthQuakeJob: NSTimer = NSTimer()
    var changeDelta: NSTimer = NSTimer()
    var thanksMessages: [String] = []
    
    var delta: Float = 15.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        //listen for earthquake
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startEarthquake:", name:"startEarthquake", object: nil)
    }
    
    func setupUI() {

        self.startVideo(self.myAnimal!.url)
        loadThanksMessages()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func feedAnimal(sender: AnyObject) {

        self.myAnimal?.feed()
        
        //disable for a short time
        self.hydrateButton.enabled = false
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.hydrateButton.enabled = true
        }
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
        let userId = Constants.ref.authData.uid
        print("auth: \(userId)")
        let currentUserRef = Constants.ref.childByAppendingPath("users/\(userId)")
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
            if(self.userProgress.progress > 0.99)
            {
               self.stopEarthquakeWithMessage("Thanks to you, your \(self.myAnimal!) survived.")
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
            stopEarthquakeWithMessage("Your \(self.myAnimal!) died. Do you even care?")
            self.petDied()
        }
    }
    
    func stopEarthquakeWithMessage(message: String){
        
        self.decreaseTimerJob.invalidate()
        self.earthQuakeJob.invalidate()
        self.changeDelta.invalidate()
        
        self.showAlert("Uh oh!", message: message, cancelButton: "OK")
        
        self.userProgress.hidden = true
        self.tapButton.hidden = true
        self.hydrateButton.userInteractionEnabled = true
    }
    
    func changeDeltaFunction(){
        self.delta = Float(arc4random_uniform(10) + UInt32(5))
    }
    
    
    func petDied (){
        
        self.myAnimal!.died()
               
        UIView.animateWithDuration(1.5, animations: {
            self.mediaView.alpha = 0
        })
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

    
    //func autostartVideo() {
        
       // self.mediaView.stringByEvaluatingJavaScriptFromString("var theEvent = document.createEvent('MouseEvent');\n theEvent.initMouseEvent('click', true, true, window);\n awElement.dispatchEvent(theEvent);\n awElement.click();\n", 10, 10)
        
        
        
        //[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var theEvent = document.createEvent('MouseEvent');\n theEvent.initMouseEvent('click', true, true, window);\n awElement.dispatchEvent(theEvent);\n awElement.click();\n", mouseX, mouseY]];
  //  }
    
    func loadThanksMessages(){
        
        Constants.ref.childByAppendingPath("messages/thanks").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if(snapshot.exists()){
                
                for childSnap in  snapshot.children.allObjects as! [FDataSnapshot]{
                    let response = childSnap.value as! NSString
                    self.thanksMessages.append(response as String)
                }
            }
            else{
                self.thanksMessages.append("Thanks!")
            }
        })
    }
    
    func startVideo(url: NSURL){
        
        let requestObj = NSURLRequest(URL: url)
        self.mediaView.allowsInlineMediaPlayback = true;
        self.mediaView.mediaPlaybackRequiresUserAction = false;
        self.mediaView.loadRequest(requestObj)
        
        print("url: \(url)!), my animal: \(self.myAnimal!)")
    }


}