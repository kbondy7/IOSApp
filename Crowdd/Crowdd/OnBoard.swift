//
//  OnBoard.swift
//  Crowdd
//
//  Created by Kieran Bondy on 7/6/19.
//  Copyright © 2019 Kieran Bondy. All rights reserved.
//

import UIKit

class OnBoard: UIViewController, UITextFieldDelegate {
    let defaults = UserDefaults.standard
    
    
    
    @IBOutlet weak var FirstNameEntry: UITextField!
    
    @IBOutlet weak var LastNameEntry: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirstNameEntry.delegate = self
        LastNameEntry.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func EnterBtn(_ sender: UIButton) {
        let First = FirstNameEntry?.text ?? "empty"
        let Last = LastNameEntry?.text ?? "empty"
        
        let firstInitial = First.prefix(1)
        let lastInitial = Last.prefix(1)
        
//        print(firstInitial)
//        print(lastInitial)
        
        if(First == "empty" || Last == "empty"){
            
        }
        else{
            defaults.set(true, forKey: "FirstTime")
            let name = First + " " + Last
            defaults.set(name, forKey: "name")
            defaults.set(firstInitial, forKey: "firstInitial")
            defaults.set(lastInitial, forKey: "lastInitial")
            
            dismiss(animated: true)
        }
        
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        //or
        //self.view.endEditing(true)
        return true
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
