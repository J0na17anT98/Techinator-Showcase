//
//  FeedVC.swift
//  Techinator-Showcase
//
//  Created by Jonathan Tsistinas on 8/22/16.
//  Copyright © 2016 Jonathan Tsistinas. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    var posts = [Post]()
    
    var imagePicker: UIImagePickerController!
    
    
    static var imgCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 358
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: {snapshot in
            print(snapshot.value)
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    print ("SNAP:\(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                    
                }
                
            }
            
            self.tableView.reloadData()
        })

    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imgCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImage.image = image
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
    
        if let txt = postField.text where txt != "" {
            
            if let img = imageSelectorImage.image {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imageData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                multipartFormData.appendBodyPart(data: imageData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    
                multipartFormData.appendBodyPart(data: keyData, name: "key")
                
                multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                }) { encodingResult in
                    
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        //won't work for some reason :( \/
                        upload.responseJSON(completionHandler: { request, response, result in
                            
                            if let info = result.value as? Dictionary<String, AnyObject> {
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    if let imageLink = links["image_link"] as? String {
                                        print("LINK: \(imageLink)")
                                    }
                                }
                            }
                        })
                        
                    case .Failure(let error):
                        print(error)
                    }
                    
                
                }
            }
        }
    
    }

}
