//
//  Profile.swift
//  Crowdd
//
//  Created by Kieran Bondy on 7/5/19.
//  Copyright © 2019 Kieran Bondy. All rights reserved.
//

import UIKit

class Profile: UIViewController {

    @IBOutlet weak var NameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        NameLabel.text = ViewController.UserVars.name
        // Do any additional setup after loading the view.
    }
    
    @IBAction func BackBtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let Home = storyBoard.instantiateViewController(withIdentifier: "Home")
        self.present(Home, animated: false, completion: nil)
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
