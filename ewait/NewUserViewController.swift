//
//  NewUserViewController.swift
//  ewait
//
//  Created by Aakansha on 29/05/17.
//  Copyright © 2017 Smart Creatives. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController {

    @IBOutlet var userNameTextBox: UITextField!
    @IBOutlet var emailTextBox: UITextField!
    @IBOutlet var passwordTextBox: UITextField!
    let authenticationService = AuthenticationServiceSingleton.sharedInstance
    let defaults = UserDefaults.standard
    private var _email: String = ""
    private var _password: String = ""

    @IBAction func signUpAction(_ sender: UIButton) {
        view.endEditing(true)
        _email = self.emailTextBox.text!
        _password  = self.passwordTextBox.text!
        let _username:String = self.userNameTextBox.text!
        authenticationService.signUp(name: _username, email: _email, password: _password)
    }
    func persistCredentials()
    {
        defaults.set(_email, forKey: "auth_email")
        defaults.set(_password, forKey: "auth_password")
    }
    
    func retrieveCredentials()
    {
        DispatchQueue.main.async {
            if let email = self.defaults.string(forKey: "auth_email") {
                self.emailTextBox.text = email
            }
            if let pwd = self.defaults.string(forKey: "auth_password") {
                self.passwordTextBox.text = pwd
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authenticationService.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        authenticationService.removeObserver(self, forKeyPath: "status")
        
        super.viewDidDisappear(animated)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //print(keyPath! + " \(String(describing: change?[NSKeyValueChangeKey.newKey]))" )
        
        
        if authenticationService.isAuthenticated()
        {
            //print(authenticationService.getToken()!)
            persistCredentials()
            let alert = UIAlertController(title: "Sign Up Successful", message: "You can now access featues available to authenticated users only", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Sign Up Failed", message: "Please check your Email & Password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
