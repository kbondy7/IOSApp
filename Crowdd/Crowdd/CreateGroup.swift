//
//  CreateGroup.swift
//  Crowdd
//
//  Created by Kieran Bondy on 7/1/19.
//  Copyright © 2019 Kieran Bondy. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CreateGroup: UIViewController, UITextFieldDelegate {
    var ref : DatabaseReference!
    
    
    @IBOutlet weak var CodeEntry: UITextField!
    @IBOutlet weak var CodeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        CodeEntry.delegate = self
        ref = Database.database().reference()
        ViewController.UserVars.code = randomString(length: 1)
        ViewController.UserVars.uuid = UIDevice.current.identifierForVendor?.uuidString ?? "ERROR"
        self.CodeLabel.text = ViewController.UserVars.code
        // Do any additional setup after loading the view.
    }
    
    @IBAction func StartGroupBtn(_ sender: UIButton) {
       
        ref.child(ViewController.UserVars.code).child(ViewController.UserVars.uuid).setValue(["name":ViewController.UserVars.name,"coords":ViewController.UserVars.coords])
        ViewController.UserVars.active = true
        dismiss(animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        //or
        //self.view.endEditing(true)
        return true
    }
    @IBAction func JoinGroupBtn(_ sender: UIButton) {
        let entryCode = CodeEntry?.text ?? "empty"
        
        if(entryCode != "empty"){
            ViewController.UserVars.code = entryCode
        ref.child(entryCode).child(ViewController.UserVars.uuid).setValue(["name":ViewController.UserVars.name,"coords":ViewController.UserVars.coords])
        }
        ViewController.UserVars.active = true
        dismiss(animated: true)
        
    }
    @IBAction func Close(_ sender: UIButton) {
        dismiss(animated: true)
    }
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
