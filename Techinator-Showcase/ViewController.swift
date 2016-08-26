//
//  ViewController.swift
//  Techinators-Showcase
//
//  Created by Jonathan Tsistinas on 8/18/16.
//  Copyright © 2016 Techinator. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }

    @IBAction func attemptLogin(sender: UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
            
                if error != nil {
                    
                    print(error)
                    
                    if error!.code == STATUS_ACCOUNT_NONEXIST {

                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in

                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating  account. Try something else")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                                
                                    let userData = ["provider": "provider", "blah": "emailTest"]
                                    DataService.ds.createFirebaseUser(user!.uid, user: userData)

                            
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                            
                        })
                    } else {
                        self.showErrorAlert("Could not login", msg: "please check your username or password")
                    }
                    
                } else {
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })

            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and password")
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}