//
//  AuthenticationService.swift
//  ewait
//
//  Created by Aakansha on 29/05/17.
//  Copyright © 2017 Smart Creatives. All rights reserved.
//

import Foundation

protocol AuthenticationProtocol {
    func isAuthenticated() -> Bool
    func getToken() -> String?
    func signIn(email: String, password: String)
    func signUp(name: String, email: String, password: String)
    func getName() -> String
    func signOut()
}

class AuthenticationServiceSingleton: NSObject, AuthenticationProtocol {
    private var _mToken: String? = nil
    private var _authenticated: Bool = false
    private var _name: String = ""
    let defaults = UserDefaults.standard
    
    
    
    dynamic var status: String = ""
    
    static let sharedInstance = AuthenticationServiceSingleton()
    
    let defaultSession  = URLSession(configuration: URLSessionConfiguration.default)
    private var dataTask: URLSessionDataTask?
    
    private override init() {
        super.init()
        if let token = defaults.string(forKey: "token") {
            self._mToken = token
            self._authenticated = true
            
            if let name = defaults.string(forKey: "auth_user_name")
            {
                self._name = name
            }
            
        } else {
            self._mToken = nil
            self._authenticated = false
            self._name = ""
        }
        
    }
    
    private func updateTokenFromServerData( serverresponse: NSDictionary)
    {
        if ((serverresponse["token"] as? String) != nil) {
            _mToken = (serverresponse["token"] as! String)
            _name = (serverresponse["name"] as! String)

            defaults.set(_mToken, forKey: "token")
            defaults.set(_name, forKey: "auth_user_name")

            _authenticated = true
            status = "OK"
        }
        else
        {
            resetStateWhenError()
        }
    }
    func getName() -> String
    {
        return _name
    }
    
    private func resetStateWhenError()
    {
        _mToken = nil
        _authenticated = false
        _name = ""
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "auth_user_name")
        status = "FAIL"
    }

    func signIn(email: String, password: String)
    {
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        var urlRequest = URLRequest(url: URL(string: GlobalConstants.server + "/api/signin")!)
        
        let bodyData = "email=\(email)&password=\(password)"
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        dataTask = defaultSession.dataTask(with: urlRequest) {
            data, response, error in
            if let error = error {
                //print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200
                {
                    
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        //print(json)
                        self.updateTokenFromServerData(serverresponse: json)
                    } catch let error as JSONError {
                        //print(error.rawValue)
                    } catch let error as NSError {
                        //print(error.debugDescription)
                    }
                }
                else
                {
                    self.resetStateWhenError()
                }
            }
        }
        dataTask?.resume()
    }
    
    func signUp(name: String, email: String, password: String)
    {
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        var urlRequest = URLRequest(url: URL(string: GlobalConstants.server + "/api/signup")!)
        
        let bodyData = "name=\(name)&email=\(email)&password=\(password)"
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        dataTask = defaultSession.dataTask(with: urlRequest) {
            data, response, error in
            if let error = error {
                //print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200
                {
                    
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        //print(json)
                        self.updateTokenFromServerData(serverresponse: json)
                    } catch let error as JSONError {
                        //print(error.rawValue)
                    } catch let error as NSError {
                        //print(error.debugDescription)
                    }
                }
                else
                {
                    self.resetStateWhenError()
                }
            }
        }
        dataTask?.resume()
    }
    
    func getToken() -> String?
    {
        return _mToken
    }
    
    func isAuthenticated() -> Bool
    {
        return _authenticated
    }
    
    func signOut()
    {
        _mToken = nil
        _authenticated = false
        _name = ""
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "auth_user_name")

        status = "SIGNOUT"
    }
}
