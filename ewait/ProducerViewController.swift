//
//  FirstViewController.swift
//  ewait
//
//  Created by Aakansha on 14/05/17.
//  Copyright © 2017 Smart Creatives. All rights reserved.
//

import UIKit

class ProducerViewController: UIViewController , UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource  {
    let authenticationService = AuthenticationServiceSingleton.sharedInstance
    private var _queueList: NSMutableArray = []
    
    @IBOutlet var qlistTableView: UITableView!
    let queueFactory = EasyWaitApp.sharedInstance.getQueueFctory()

    @IBOutlet var queueNameTextField: UITextField!
    
    @IBOutlet var userMessageWindow: UILabel!
    
    @IBAction func actionAddQueue(_ sender: UIButton) {
        queueFactory.addQueue(name: queueNameTextField.text!)
    
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        return _queueList.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = self.qlistTableView.dequeueReusableCell(withIdentifier: "cell")!
        
        var cellText = String((_queueList[indexPath.row] as! NSDictionary)["id"] as! Int)
        
        cellText = cellText + ": " + String((_queueList[indexPath.row] as! NSDictionary)["name"] as! String)
        
        cell.textLabel?.text = cellText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        EasyWaitApp.sharedInstance.setActiveQueue(index: indexPath.row)
        performSegue(withIdentifier: "ManageQueueSegue", sender: nil)
    }

    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //override func tableView(_:)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        queueNameTextField.delegate = self
        self.qlistTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.qlistTableView.delegate = self
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        NSLog("observeValue: keyPath=%@", keyPath!)
        
        let blank:String  = ""
        let newKeyValue = "\(change?[NSKeyValueChangeKey.newKey] ?? blank)"
        
        if ( newKeyValue == "QueueListUpdated")
        {
            _queueList = EasyWaitApp.sharedInstance.getQueueList()
            DispatchQueue.main.async {
                self.qlistTableView.reloadData()
            }
            NSLog("\(self._queueList.count)")
            
        }

        
        NSLog(newKeyValue)
    }

    override func viewDidDisappear(_ animated: Bool) {
        EasyWaitApp.sharedInstance.removeObserver(self, forKeyPath: "status")
    }

    override func viewDidAppear(_ animated: Bool) {
        EasyWaitApp.sharedInstance.addObserver(self, forKeyPath: "status", options: .new, context:nil)
        if authenticationService.isAuthenticated() == false {
            self.tabBarController?.selectedIndex = ApplicationTabs.profile .hashValue
        }
        else
        {
            userMessageWindow.text = "Welcome: " + authenticationService.getName()
        }
        DispatchQueue.main.async {
            self._queueList = EasyWaitApp.sharedInstance.getQueueList()
            self.qlistTableView.reloadData()
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

