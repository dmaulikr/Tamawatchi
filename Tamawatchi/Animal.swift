
import AWBanner
import Firebase

class Animal: NSObject {
    
    var name: NSString
    var url:NSURL
    let ref = Firebase(url: "https://brilliant-fire-4695.firebaseio.com")
    
    init(name: NSString, url: NSURL) {
        self.name = name
        self.url = url
    }
    
    func feed(){
        
        AWBanner.showWithDuration(2.5,
            delay: 0.0,
            message: NSLocalizedString("thankss!", comment: ""),
            backgroundColor: UIColor(red:0.25, green:0.73, blue:0.56, alpha:1.0),
            textColor: UIColor.whiteColor(),
            originY: 20.0)
        //self.thanksMessages[Int(arc4random_uniform(UInt32(self.thanksMessages.count-1)))] 
        
        //update lastFed in DB (save in timeIntervalSince1970 string format)
        let userId = ref.authData.uid
        print("auth: \(userId)")
        let currentUserRef = self.ref.childByAppendingPath("users/\(userId)")
        let now: String = "\(NSDate().timeIntervalSince1970)"
        let lastFed = ["lastFed": now]
        currentUserRef.updateChildValues(lastFed)
    }
    
    func died(){
        
        //update DB
        let userId = ref.authData.uid
        let postRef = self.ref.childByAppendingPath("users/\(userId)").childByAppendingPath("deadPets")
        let petInfo = ["type": self.name]
        let post1Ref = postRef.childByAutoId()
        post1Ref.setValue(petInfo)
    }
}