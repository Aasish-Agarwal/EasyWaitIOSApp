//
//  PublishedQueues.swift
//  ewait
//
//  Created by Aakansha on 31/05/17.
//  Copyright © 2017 Smart Creatives. All rights reserved.
//

import Foundation

// PublishedQueueList
    // Events Out: Queue List Updates
    // Events That Trigger Updates: Sign In/ Sign Out/ Token Expired
    // Interface: itemcount, item at position

// Authentication
    // Events Out: Sign In/ Sign Out
    // Events In: None
    // Interface: GetToken, SignIn, SignOut, SIgnUp

// ActiveQueue
    // Events Out: Status Refreshed
    // Events In: None
    // Interface: GetId, GetPosition, GetAppointentStatus, GetNextFreeSlot, GetInitialFreeSlots, GetPriodicFreeSlots,
    // ResetPosition, MoveNext, SetInitialFreeSlots, SetPriodicFreeSlots
    // Refresh Status

// ObservedQueue
    // Events Out: Status Refreshed
    // Events In: None
    // Interface: GetId, GetPosition, GetAppointentStatus, GetNextFreeSlot
    // Refresh Status

// Appointments
    // Events Out: Updated
    // Events In: Sign Out, Sign In


// Events being pushed out
    // QueueListUpdated - when we get to see the

class EasyWaitApp: NSObject
{
    static let sharedInstance = EasyWaitApp()
    private var _PublishedQueueList : PublishedQueueList
    private var _QueueFactory : QueueFactory
    private var _authenticationService = AuthenticationServiceSingleton.sharedInstance
    private var _mActiveQueue: Int = -1
    
    private var newQueueCreatedContext = 0
    private var queueListUpdated = 1
    dynamic var status: String = ""

    func getQueueFctory() -> QueueFactory
    {
        return _QueueFactory
    }
    
    func getQueueList() -> NSMutableArray
    {
        return _PublishedQueueList.getQueueList()
    }
    
    func setActiveQueue(index: Int)
    {
        //String((_queueList[indexPath.row] as! NSDictionary)["id"] as! Int)
        _mActiveQueue = index
    }
    
    func getActiveQueueId() -> String
    {
        if ( _mActiveQueue >= 0 )
        {
            return String((_PublishedQueueList.getQueueList()[_mActiveQueue] as! NSDictionary)["id"] as! Int)
        }
        return "-1"
    }
    
    func moveNext ()
    {
    
    }
    
    func resetActiveQueue()
    {
    
    }
    
    private override init() {
        _PublishedQueueList = PublishedQueueList(authenticationService: _authenticationService)
        _QueueFactory = QueueFactory(authenticationService: _authenticationService)
        super.init()
        _QueueFactory.addObserver(self, forKeyPath: "status", options: .new, context: &newQueueCreatedContext)
        _PublishedQueueList.addObserver(self, forKeyPath: "status", options: .new, context: &queueListUpdated)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        NSLog("observeValue: keyPath=%@", keyPath!)

        let blank:String  = ""
        let newKeyValue = "\(change?[NSKeyValueChangeKey.newKey] ?? blank)"
        
        if (context == &newQueueCreatedContext) {
            NSLog("observeValue: newQueueCreatedContext")
            NSLog(newKeyValue)
            status = "QueueAdded"
            _PublishedQueueList.refresh()
        }
        if (context == &queueListUpdated && newKeyValue == "OK") {
            NSLog("observeValue: queueListUpdated")
            NSLog(newKeyValue)
            status = "QueueListUpdated"
        }
    }
}

class QueueFactory: NSObject
{
    private var _mAuthenticationService:AuthenticationServiceSingleton
    dynamic var status: String = ""

    init(authenticationService: AuthenticationServiceSingleton) {
        _mAuthenticationService = authenticationService
        super.init()
    }

    let defaultSession  = URLSession(configuration: URLSessionConfiguration.default)
    private var dataTask: URLSessionDataTask?

    func addQueue(name: String)
    {
        if  _mAuthenticationService.isAuthenticated() != true
        {
            return
        }
        
        var urlRequest = URLRequest(url: URL(string: GlobalConstants.server + "/api/queue")!)
        let bodyData = "name=\(name)"
        
        urlRequest.httpMethod = "POST"
        // urlRequest.head
        let token = _mAuthenticationService.getToken()
        let key = "Bearer \(token!))"
        urlRequest.setValue(key, forHTTPHeaderField: "Authorization")
        print(key)
        urlRequest.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        dataTask = defaultSession.dataTask(with: urlRequest) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        print(json)
                        self.status = "OK"
                    } catch let error as JSONError {
                        print(error.rawValue)
                    } catch let error as NSError {
                        print(error.debugDescription)
                    }
                }
                else
                {
                    self.status = "FAIL"
                }
            }
        }
        dataTask?.resume()
        
    }
    
}

class PublishedQueueList: NSObject
{
    private var _queueList: NSMutableArray = []
    private var _mAuthenticationService:AuthenticationServiceSingleton
    let defaultSession  = URLSession(configuration: URLSessionConfiguration.default)
    private var dataTask: URLSessionDataTask?
    dynamic var status: String = ""
    
    init(authenticationService: AuthenticationServiceSingleton) {
        _mAuthenticationService = authenticationService
        super.init()
        _mAuthenticationService.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.refresh()
    }
    
    func refresh()
    {
        if  _mAuthenticationService.isAuthenticated() != true
        {
            return
        }
        
        var urlRequest = URLRequest(url: URL(string: GlobalConstants.server + "/api/queue")!)
        
        
        urlRequest.httpMethod = "GET"
        // urlRequest.head
        let token = _mAuthenticationService.getToken()
        let key = "Bearer \(token!))"
        urlRequest.setValue(key, forHTTPHeaderField: "Authorization")
        print(key)
        
        
        dataTask = defaultSession.dataTask(with: urlRequest) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        print(json)
                        let array = json["queues"] as! NSArray
                        self._queueList.removeAllObjects()
                        self._queueList = array.mutableCopy() as! NSMutableArray
                        self.status = "OK"
                    } catch let error as JSONError {
                        print(error.rawValue)
                    } catch let error as NSError {
                        print(error.debugDescription)
                    }
                }
                else
                {
                    self.status = "FAIL"
                }
            }
        }
        dataTask?.resume()

    }
    func getQueueList() -> NSMutableArray
    {
        return _queueList
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(keyPath! + " \(String(describing: change?[NSKeyValueChangeKey.newKey]))" )
        
        if _mAuthenticationService.isAuthenticated()
        {
            refresh()
        }
        else
        {
            self._queueList.removeAllObjects()
        }
    }

}
