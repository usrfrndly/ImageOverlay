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
class ViewController: UIViewController, FBSDKLoginButtonDelegate, FBSDKSharingDelegate{
    var imageView:UIImageView? = nil;
    var image:UIImage! = nil;
    var myLoginButton:UIButton? = nil;
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let img1 = UIImage(named:"dolls");
        let img2 = UIImage(named: "USA-test");
        let rect = CGRect(x: 0, y: 0, width: img2!.size.width, height: img2!.size.height);
        let width = img2!.size.width;
        let myLoginButton = UIButton(type: UIButtonType.Custom);
        myLoginButton.backgroundColor = UIColor.darkGrayColor();
        myLoginButton.frame=CGRectMake(0,img2!.size.height + 50,180,40);
        myLoginButton.center = self.view.center;
        myLoginButton.setTitle("My Upload Button", forState: UIControlState.Normal);
        
        addImageToImage(img1!, img2: img2!, rect: rect, cropRect: rect, imgWidth: width);
        self.view.addSubview(myLoginButton);
        //        if (FBSDKAccessToken.currentAccessToken() != nil){
        //            FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler((FBSDKGraphRequestConnection)
        //            FBSDKGraphRequestConnection.
        //        }
        //        if ([FBSDKAccessToken currentAccessToken]) {
        //            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
        //            startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        //                if (!error) {
        //                    NSLog(@"fetched user:%@", result);
        //                }
        //            }];
        //        }
        // Handle clicks on the button
        myLoginButton.addTarget(self, action: Selector("loginButtonClicked"), forControlEvents: UIControlEvents.TouchUpInside);
        
        //returnUserData()
    }
    
    
    // accessToken is your Facebook id
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
        let size = CGSizeMake(imgWidth, imgWidth);
        UIGraphicsBeginImageContext(size);
        var pointImg1 = CGPointMake(0,0);
        img1.drawAtPoint(pointImg1)
        
        var pointImg2 = CGPointMake(0, 0);
        img2.drawAtPoint(pointImg2);
        
        var result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.image = result;
        imageView = UIImageView(image: result);
        self.view.addSubview(imageView!);
    }
    
    func loginButtonClicked(){
        var login = FBSDKLoginManager();
        
        login.logInWithReadPermissions(["public_profile","user_photos","email"], fromViewController: self, handler:{ (result:FBSDKLoginManagerLoginResult!, error:NSError!)
            -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    if((FBSDKAccessToken.currentAccessToken()) != nil){
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
                }
            })
        }
        //        login.logInWithPublishPermissions(["publish_actions"], fromViewController: self, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!)
        //            -> Void in
        //            if (error == nil){
        //                NSLog("Error")
        //            }else if(result.isCancelled){
        //                NSLog("Was cancelled")
        //            }else{
        //                let fbloginresult : FBSDKLoginManagerLoginResult = result
        //                if(fbloginresult.grantedPermissions.contains("email"))
        //                {
        //                    if((FBSDKAccessToken.currentAccessToken()) != nil){
        //                        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
        //                            if (error == nil){
        //                                NSLog("Logged in")
        //                                if(FBSDKAccessToken.currentAccessToken().hasGranted("publish_actions")) {
        //                                    let content = FBSDKSharePhotoContent()
        //                                    content.photos = [FBSDKSharePhoto(image: self.image, userGenerated: true)]
        //                                    FBSDKShareAPI.shareWithContent(content, delegate: self)
        //                                } else {
        //                                    print("require publish_actions permissions")
        //                                }
        //                            }
        //
        //
        //
        //                        })
        //                    }
        //                }
        //            }
        //        })
        //
        //
        //    }
    
             func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
            print("didCompleteWithResults")
            alertShow("Photo")
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
                
                myLoginButton!.alpha = 1
                myLoginButton!.enabled = true
            } else {
                myLoginButton!.alpha = 0.3
                myLoginButton!.enabled = false
                
            }
        }
        func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
            print("loginButtonDidLogOut")
            imageView!.image = UIImage(named: "fb-art.jpg")
            //  label.text = "Not Logged In"
            buttonEnable(false)
        }
        
}
