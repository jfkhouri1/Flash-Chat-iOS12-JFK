//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    // Declare instance variables here
    
    // declare messageArray as an array of messages and initialize it to be empty.
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        

        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self

        
        
        //TODO: Set the tapGesture here:
        // create tapGesture that call tableViewTapped when user taps on the tableView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        // register that tapGesture in messageTableView
        messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")

        
        retrieveMessages()
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if (cell.senderUsername.text == Auth.auth().currentUser?.email) {
            // this message is from us
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBody.backgroundColor = UIColor.flatSkyBlue()
        } else {
            // message is from someone else.   Color it differently.
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBody.backgroundColor = UIColor.flatGray()
        }
       
        return cell
    }
    
    //TODO: Declare numberOfRowsInSection here:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    //TODO: Declare tableViewTapped here:
    
    @objc func tableViewTapped () {
        // indicate end editing in message Text has occured which causes its textFieldDidEndEditing method defined below to be called.
        messageTextfield.endEditing(true)
    }
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // slide text field up to make room for keyboard.
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 358
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // slide text field back down since the keyboard will be tucked away.
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        
        //TODO: Send the message to Firebase and save it in our database
        
        // disable user input while doing time consuming DB operations
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        // create and inject message in DB
        
        let messagesDB = Database.database().reference().child("Messages")
        let messageDictionary = ["senderEmail":Auth.auth().currentUser?.email, "messageBody": messageTextfield.text]
        
        messagesDB.childByAutoId().setValue(messageDictionary) { (error, dbReference) in
            if (error != nil) {
                // there was an error
                print (error!)
            } else {
                print ("Message addedd successfully \(dbReference)")
            }
            // re-enable user input
            self.messageTextfield.isEnabled = true
            self.sendButton.isEnabled = true
            
            //clear message content on screen
            self.messageTextfield.text = ""
        }
        
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        // get a reference to the Messages DB
        let messageDB = Database.database().reference().child("Messages")
        
        // ask to be identified when a child gets inserted in the DB
        messageDB.observe(.childAdded) { (snapshot) in
            // cast the snapshot of the added child as a dictionary (same as Message class)
            let snapshotValue = snapshot.value as! Dictionary <String, String>
            
            // extract user email and message body from snapshot.
            let senderEmail = snapshotValue["senderEmail"]!
            let messageBody = snapshotValue["messageBody"]!
            
            let message = Message()
            message.sender = senderEmail
            message.messageBody = messageBody
            
            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()

            
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            
            print("User signed out successfully")
            // pop out to root view (i.e welcome screen)
            navigationController?.popToRootViewController(animated: true)
            
            
        } catch {
            print ("Error Logging Out")
        }

        
        
    }
    


}
