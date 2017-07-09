//
//  SecondViewController.swift
//  ewait
//
//  Created by Aakansha on 14/05/17.
//  Copyright © 2017 Smart Creatives. All rights reserved.
//

import UIKit

enum ApplicationTabs {
    case home, customer, producer , profile
    
}

class HomeViewController: UIViewController {

    let easuWaitApp = EasyWaitApp.sharedInstance
    
    @IBAction func switchToProducerTab(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = ApplicationTabs.producer .hashValue
    }
    
    @IBAction func switchToCustomerTab(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = ApplicationTabs.customer .hashValue
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

