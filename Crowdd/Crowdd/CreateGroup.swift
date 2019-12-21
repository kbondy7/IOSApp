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
    var create = true
    let color = UIColor(red: 0/255.0, green: 187/255.0, blue: 195/255.0, alpha: 1.0)
    let white = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    @IBOutlet weak var CopyButton: UIButton!
    @IBOutlet weak var JoinBtn: UIButton!
    @IBOutlet weak var CreateBtn: UIButton!
    @IBOutlet weak var PageImg: UIImageView!
    @IBOutlet weak var CodeEntry: UITextField!
    @IBOutlet weak var CodeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        create = true
        CodeEntry.delegate = self
        ref = Database.database().reference()
        ViewController.UserVars.code = randomString(length: 10)
        ViewController.UserVars.uuid = UIDevice.current.identifierForVendor?.uuidString ?? "ERROR"
        self.CodeLabel.text = ViewController.UserVars.code
        // Do any additional setup after loading the view.
        CodeEntry.isHidden = true
    }
    
    @IBAction func CopyBtn(_ sender: Any) {
        UIPasteboard.general.string = ViewController.UserVars.code
    }
    @IBAction func StartGroupBtn(_ sender: UIButton) {
        if(create){
        ref.child(ViewController.UserVars.code).child(ViewController.UserVars.uuid).setValue(["name":ViewController.UserVars.name,"coords":ViewController.UserVars.coords])
        }
        else{
            let entryCode = CodeEntry?.text ?? "empty"
            if(entryCode != "empty"){
                ViewController.UserVars.code = entryCode
                ref.child(entryCode).child(ViewController.UserVars.uuid).setValue(["name":ViewController.UserVars.name,"coords":ViewController.UserVars.coords])
            }
        }
        ViewController.UserVars.active = true
        dismiss(animated: true)
            
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        //or
        //self.view.endEditing(true)
        return true
    }
    @IBAction func CreateGroupBtn(_ sender: UIButton) {
        create = true
        JoinBtn.setTitleColor(white, for: .normal)
        CreateBtn.setTitleColor(color, for: .normal)
        CodeEntry.isHidden = true
        CodeLabel.isHidden = false
        PageImg.image = UIImage(named: "createPage")
    }
    @IBAction func JoinGroupBtn(_ sender: UIButton) {
        create = false
        CodeEntry.isHidden = false
        CodeLabel.isHidden = true
        PageImg.image = UIImage(named: "joinPage")
        JoinBtn.setTitleColor(color, for: .normal)
        CreateBtn.setTitleColor(white, for: .normal)
        
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
