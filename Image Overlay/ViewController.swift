//
//  ViewController.swift
//  Image Overlay
//
//  Created by Jaclyn Horowitz on 3/21/16.
//  Copyright © 2016 Levin Riegner. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit
class ViewController: UIViewController, FBSDKLoginButtonDelegate, FBSDKSharingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var imageView:UIImageView? = nil;
    var image:UIImage! = nil;
    let img2 = UIImage(named: "USA-test");
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var myLoginButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var profilePicButton: UIButton!
    @IBOutlet weak var takePicButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        buttonEnable(false)
        imagePicker.delegate = self;
        self.view.addSubview(myLoginButton);
        
        // Handle clicks on the button
        myLoginButton.addTarget(self, action: Selector("loginButtonClicked"), forControlEvents: UIControlEvents.TouchUpInside);
        
        //returnUserData()
    }
    
    @IBAction func saveImagePressed(sender: AnyObject) {
        
        UIImageWriteToSavedPhotosAlbum(self.imageView!.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    @IBAction func galleryButtonPressed(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func takePicPressed(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let temp = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            var img1 = resizeImage(temp, newWidth: img2!.size.width)
            let rect = CGRect(x: 0, y: 100, width: img2!.size.width, height: img2!.size.height);
            
            addImageToImage(img1, img2: self.img2!, rect: rect, cropRect: rect, imgWidth: rect.size.width);
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func profilePicButtonPressed(sender: AnyObject) {
        
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler({ (connection, result, error)
                -> Void in
                NSLog("This logged in user: \(result)")
                if error == nil{
                    if let dict = result as? Dictionary<NSString, AnyObject>{
                        NSLog("This is dictionary of user infor getting from facebook:")
                        print(dict)
                        
                        let facebookID:NSString = dict["id"] as AnyObject? as! NSString
                        let pictureURL = "https://graph.facebook.com/\(facebookID)/picture?type=large&width=320&height=320&return_ssl_resources=1"
                        //
                        var URLRequest = NSURL(string: pictureURL)
                        var URLRequestNeeded = NSURLRequest(URL: URLRequest!)
                        NSLog(pictureURL)
                        
                        
                        
                        NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?, error: NSError?) -> Void in
                            if error == nil {
                                //data is the data of profile image you need. Just create UIImage from it
                                let img1 = UIImage(data: data!)
                                let rect = CGRect(x: 0, y: 0, width: self.img2!.size.width, height: self.img2!.size.height);
                                self.addImageToImage(img1!, img2: self.img2!, rect: rect, cropRect: rect, imgWidth: rect.size.width);
                                
                            }
                            else {
                                NSLog("Error: \(error)")
                            }
                        })
                        
                        
                    }
                }
            })
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = self.img2!.size.height
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func returnUserProfileImage(accessToken: NSString)
    {
        var userID = accessToken as NSString
        var facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(userID)/picture?type=large")
        
        if let data = NSData(contentsOfURL: facebookProfileUrl!) {
            print(data);
            let imageProfile = UIImage(data: data);
        }
        
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                
                if let id: NSString = result.valueForKey("id") as? NSString {
                    print("ID is: \(id)")
                    self.returnUserProfileImage(id)
                } else {
                    print("ID es null")
                }
                
                
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    func addImageToImage(img1:UIImage, img2:UIImage, rect: CGRect, cropRect:CGRect, imgWidth:CGFloat) {
        let size = CGSizeMake(imgWidth, self.img2!.size.height);
        UIGraphicsBeginImageContext(size);
        var pointImg1 = CGPointMake(0,0);
        img1.drawAtPoint(pointImg1)
        
        var pointImg2 = CGPointMake(0, 0);
        img2.drawAtPoint(pointImg2);
        
        var result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.image = result;
        imageView = UIImageView(image: result);
        imageView?.frame = CGRectMake(0, 100,imgWidth,img2.size.height);
        self.view.addSubview(imageView!);
        self.myLoginButton.frame=CGRectMake(0,img2.size.height + img2.size.height + 50,180,40);
        
        buttonEnable(true)
    }
    
    func loginButtonClicked(){
        var login = FBSDKLoginManager();
        
        login.logInWithReadPermissions(["public_profile","user_photos","email"], fromViewController: self, handler:{ (result:FBSDKLoginManagerLoginResult!, error:NSError!)
            -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    
                    
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                        if (error == nil){
                            NSLog("Logged in")
                            login.logInWithPublishPermissions(["publish_actions"], fromViewController: self, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!)
                                -> Void in
                                if(FBSDKAccessToken.currentAccessToken().hasGranted("publish_actions")) {
                                    let content = FBSDKSharePhotoContent()
                                    content.photos = [FBSDKSharePhoto(image: self.image, userGenerated: true)]
                                    FBSDKShareAPI.shareWithContent(content, delegate: self)
                                } else {
                                    print("require publish_actions permissions")
                                }
                            })
                            
                        }
                    })
                }
            }
        })
    }
    
    
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        NSLog("didCompleteWithResults \(results)")
        var separatedId = results["postId"]!.componentsSeparatedByString("_")
        var pid = separatedId[1]
        //TODO: Will the native fb app work?
        //let facebookURL = NSURL(string:"fb://page/\(results["postId"]!)");
        let facebookURL = NSURL(string:"fb://profile");
        //                if (UIApplication.sharedApplication().canOpenURL(facebookURL!)){
        //                    UIApplication.sharedApplication().openURL(facebookURL!);
        //                } else {
        UIApplication.sharedApplication().openURL( NSURL(string: "https://facebook.com/photo.php?fbid=\(pid)&makeprofile=1")!);
        //    }
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("didFailWithError   \(error)")
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("sharerDidCancel")
    }
    
    func alertShow(typeStr: String) {
        let alertController = UIAlertController(title: "", message: typeStr+" Posted!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("didCompleteWithResult")
        
        getFacebookUserInfo()
    }
    
    func getFacebookUserInfo() {
        if(FBSDKAccessToken.currentAccessToken() != nil)
        {
            
            buttonEnable(true)
            
            //print permissions, such as public_profile
            print(FBSDKAccessToken.currentAccessToken().permissions)
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                //self.label.text = result.valueForKey("name") as? String
                
                let FBid = result.valueForKey("id") as? String
                
                let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
                self.imageView!.image = UIImage(data: NSData(contentsOfURL: url!)!)
            })
        } else {
            buttonEnable(false)
        }
    }
    func buttonEnable(enable: Bool) {
        if enable {
            
            myLoginButton.hidden = false
            myLoginButton.enabled = true
            saveButton.hidden = false
            saveButton.enabled = true
        } else {
            myLoginButton.hidden = true
            myLoginButton.enabled = false
            saveButton.hidden = true
            saveButton.enabled = false
            
        }
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("loginButtonDidLogOut")
        imageView!.image = UIImage(named: "fb-art.jpg")
        //  label.text = "Not Logged In"
        buttonEnable(false)
    }
    
}
