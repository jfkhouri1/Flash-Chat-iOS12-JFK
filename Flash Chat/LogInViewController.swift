//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import FirebaseAuth
import SVProgressHUD


class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {

        
        //TODO: Log in the user
        
        // show a progress bar while login is being performed.
        SVProgressHUD.show(withStatus: "Logging In")
        
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (authDataResult, error) in
            if error == nil {
                //user signed on successfully
                print ("User "+self.emailTextfield.text!+" signed on successfully")
                print (authDataResult!)
                
                self.performSegue(withIdentifier: "goToChat", sender: self)
                
            }else {
                // there was an error signing in
                print ("Error Signing in user "+self.emailTextfield.text!)
                print (error!)
            }
            SVProgressHUD.dismiss()
        }
        print ("Authorization in progres....")
        
    }
    


    
}  
