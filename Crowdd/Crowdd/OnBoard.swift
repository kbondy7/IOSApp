//
//  OnBoard.swift
//  Crowdd
//
//  Created by Kieran Bondy on 7/6/19.
//  Copyright © 2019 Kieran Bondy. All rights reserved.
//

import UIKit

class OnBoard: UIViewController {
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var FirstNameEntry: UITextField!
    
    @IBOutlet weak var LastNameEntry: UITextField!
    @IBAction func EnterBtn(_ sender: UIButton) {
        let First = FirstNameEntry?.text ?? "empty"
        let Last = LastNameEntry?.text ?? "empty"
        if(First == "empty" || Last == "empty"){
            
        }
        else{
            defaults.set(true, forKey: "FirstTime")
            let name = First + " " + Last
            defaults.set(name, forKey: "name")
            dismiss(animated: true)
        }
        
        
        
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
