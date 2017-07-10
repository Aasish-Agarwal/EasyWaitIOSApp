//
//  QStateDataSource.swift
//  ewait
//
//  Created by Aakansha on 27/05/17.
//  Copyright © 2017 Smart Creatives. All rights reserved.
//

import Foundation

protocol QStateDataSourceProtocl {
    func setQueueId(qId: String)
    func getQueueId() -> String
    func getQueuePosition() -> String
    func getQueueName() -> String
    func getQueueServiceRate() -> String
    func isAcceptingAppointments() -> Bool
    func availablePosition() -> String
}

class Queue: NSObject {
    //MARK: Private Members

    private var _mLastOperationResponse: String = ""
    private var _mueueId: String = ""
    private var _mAppointmentList: NSMutableArray = []
    private var _mAuthenticationService:AuthenticationServiceSingleton
    private let defaultSession  = URLSession(configuration: URLSessionConfiguration.default)
    private var dataTask: URLSessionDataTask?
    private var appointmentsDataTask: URLSessionDataTask?
    dynamic var status: String = ""
    
    init(queueId: String, authenticationService: AuthenticationServiceSingleton) {
        _mueueId = queueId
        _mAuthenticationService = authenticationService
        super.init()
        if ( _mueueId.characters.count > 0 ) {
            refreshAppointmentList()
        }
    }

    func getAppointmentList() -> NSMutableArray
    {
        return _mAppointmentList
    }
    
    func setQueueId(queueId: String)
    {
        _mueueId = queueId
        if ( _mueueId.characters.count > 0 ) {
            refreshAppointmentList()
        }
    }

    func refreshAppointmentList()
    {
        if  _mAuthenticationService.isAuthenticated() != true
        {
            return
        }
        
        var urlRequest = URLRequest(url: URL(string: GlobalConstants.server + "/api/queue/" + _mueueId + "/appointment")!)
        
        
        urlRequest.httpMethod = "GET"
        // urlRequest.head
        let token = _mAuthenticationService.getToken()
        let key = "Bearer \(token!))"
        urlRequest.setValue(key, forHTTPHeaderField: "Authorization")
        
        
        appointmentsDataTask = defaultSession.dataTask(with: urlRequest) {
            data, response, error in
            if let error = error {
                //print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        //print(json)
                        let array = json["appointments"] as! NSArray
                        self._mAppointmentList.removeAllObjects()
                        self._mAppointmentList = array.mutableCopy() as! NSMutableArray
                        self.status = "AppointmentListUpdated"
                    } catch let error as JSONError {
                        //print(error.rawValue)
                    } catch let error as NSError {
                        //print(error.debugDescription)
                    }
                }
                else if ( httpResponse.statusCode == 401 )
                {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        //print(json)
                        self.status = AuthenticationEvents.TokenExpired
                    } catch let error as JSONError {
                        //print(error.rawValue)
                    } catch let error as NSError {
                        //print(error.debugDescription)
                    }
                }
                else
                {
                    self.status = "FAIL"
                }
            }
        }
        appointmentsDataTask?.resume()
        
    }

    func makeAppointment(reference: String)
    {
        if  _mAuthenticationService.isAuthenticated() != true
        {
            self.status = AuthenticationEvents.NotAuthenticated
            return
        }
        
        var urlRequest = URLRequest(url: URL(string: GlobalConstants.server + "/api/queue/" + _mueueId + "/appointment")!)
        
        let action : String = "book"
        let bodyData = "action=\(action)&reference=\(reference)"
        
        
        urlRequest.httpMethod = "POST"
        // urlRequest.head
        let token = _mAuthenticationService.getToken()
        let key = "Bearer \(token!))"
        urlRequest.setValue(key, forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        appointmentsDataTask = defaultSession.dataTask(with: urlRequest) {
            data, response, error in
            if let error = error {
                //print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        //print(json)
                        self.status = "Booking Successful"
                        self.refreshAppointmentList()
                    } catch let error as JSONError {
                        //print(error.rawValue)
                    } catch let error as NSError {
                        //print(error.debugDescription)
                    }
                }
                else if ( httpResponse.statusCode == 401 )
                {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        //print(json)
                        self.status = AuthenticationEvents.TokenExpired
                    } catch let error as JSONError {
                        //print(error.rawValue)
                    } catch let error as NSError {
                        //print(error.debugDescription)
                    }
                }
                else
                {
                        self.status = "FAIL"
                }
            }
        }
        appointmentsDataTask?.resume()
    }
    
    func moveNext()
    {
        updateQueueState(action: "movenext")
    }
    func reset()
    {
        updateQueueState(action: "reset")
    }

    private func manageAppointmentState (action: String)
    {
        if  _mAuthenticationService.isAuthenticated() != true
        {
            self.status = AuthenticationEvents.NotAuthenticated
            return
        }
        
        var urlRequest = URLRequest(url: URL(string: GlobalConstants.server + "/api/queue/" + _mueueId + "/appointment")!)
        
        let bodyData = "action=\(action)"
        
        
        urlRequest.httpMethod = "POST"
        // urlRequest.head
        let token = _mAuthenticationService.getToken()
        let key = "Bearer \(token!))"
        urlRequest.setValue(key, forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        appointmentsDataTask = defaultSession.dataTask(with: urlRequest) {
            data, response, error in
            if let error = error {
                //print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        //print(json)
                        self.status = "OK"
                    } catch let error as JSONError {
                        //print(error.rawValue)
                    } catch let error as NSError {
                        //print(error.debugDescription)
                    }
                }
                else if ( httpResponse.statusCode == 401 )
                {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        //print(json)
                        self.status = AuthenticationEvents.TokenExpired
                    } catch let error as JSONError {
                        //print(error.rawValue)
                    } catch let error as NSError {
                        //print(error.debugDescription)
                    }
                }
                else
                {
                    self.status = "FAIL"
                }
            }
        }
        appointmentsDataTask?.resume()
        
    }
    func resetAllAppointments()

    {
        let action : String = "reset"
        manageAppointmentState(action: action)
    }
    
    func acceptAppointments(state: Bool)
    {
        var action : String = "open"
        if ( state == false) {
            action = "close"
        }
        manageAppointmentState(action: action)
    }
    
    
    
    private func updateQueueState(action: String)
    {
        if  _mAuthenticationService.isAuthenticated() != true
        {
            self.status = AuthenticationEvents.NotAuthenticated

            return
        }
        
        var urlRequest = URLRequest(url: URL(string: GlobalConstants.server + "/api/queue/" + _mueueId)!)
        let bodyData = "action=\(action)"
        
        urlRequest.httpMethod = "POST"
        // urlRequest.head
        let token = _mAuthenticationService.getToken()
        let key = "Bearer \(token!))"
        urlRequest.setValue(key, forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        dataTask = defaultSession.dataTask(with: urlRequest) {
            data, response, error in
            if let error = error {
                //print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        ////print(json)
                        self.status = "OK"
                    } catch let error as JSONError {
                        ////print(error.rawValue)
                    } catch let error as NSError {
                        //print(error.debugDescription)
                    }
                }
                else if ( httpResponse.statusCode == 401 )
                {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        //print(json)
                        self.status = AuthenticationEvents.TokenExpired
                    } catch let error as JSONError {
                        //print(error.rawValue)
                    } catch let error as NSError {
                        //print(error.debugDescription)
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

class QueueStateRetriever: NSObject, QStateDataSourceProtocl {
    private var _mQueueId: String = ""
    private var _mQueueName: String = ""
    private var _mNextAvailableSlot: String = ""
    private var _mAcceptingAppointments: Bool = false
    private var _mTimePerCustomer: String = ""
    
    dynamic var position: String = ""
    private var count: Int = 0
    
    let defaultSession  = URLSession(configuration: URLSessionConfiguration.default)
    private var dataTask: URLSessionDataTask?

    
    private func updateQueueStatusFromServerData( qstatus: NSDictionary)
    {
        self._mQueueName = (qstatus["name"] as! String)
        self._mQueueId = String(qstatus["id"] as! Int)
        self._mNextAvailableSlot = String(qstatus["next_available_slot"] as! Int)
        self._mTimePerCustomer = String(qstatus["timepercustomer"] as! Int)
        
        let accepting_appointments = qstatus["accepting_appointments"] as! Int
        
        if accepting_appointments == 1
        {
            self._mAcceptingAppointments = true
            
        }
        else
        {
            self._mAcceptingAppointments = false
        }
        self.position = String(qstatus["position"] as! Int)
    }

    private func resetStateWhenError()
    {
        self._mQueueName = "Queue not found with id: " + self._mQueueId
        self._mNextAvailableSlot = ""
        self._mAcceptingAppointments = false
        self.position = ""
        self._mTimePerCustomer = ""
    }
    
    private func getQueueStatusFromServer(queueid: String)
    {
        // Call server API to fetch queue list
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        var urlRequest = URLRequest(url: URL(string: GlobalConstants.server + "/api/queue/" + queueid)!)
        
        
        urlRequest.httpMethod = "GET"
        
        dataTask = defaultSession.dataTask(with: urlRequest) {
            data, response, error in
            // 7
            if let error = error {
                //print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        //print(json)
                        self.updateQueueStatusFromServerData(qstatus: json)
                        
                        
                    } catch let error as JSONError {
                        //print(error.rawValue)
                    } catch let error as NSError {
                        //print(error.debugDescription)
                    }
                } else {
                    self.resetStateWhenError()
                }
            }
        }
        dataTask?.resume()
    }
    
    
    func getQueueId() -> String {
        return _mQueueId
    }

    func setQueueId(qId: String)
    {
        _mQueueId = qId
        getQueueStatusFromServer(queueid: qId)
    }

    func getQueueName() -> String
    {
        return _mQueueName
    }
    func getQueuePosition() -> String
    {
        
        return position
    }
    func getQueueServiceRate() -> String
    {
        return _mTimePerCustomer + " minutes each"
    }
    func isAcceptingAppointments() -> Bool
    {
        return _mAcceptingAppointments
    }
    func availablePosition() -> String
    {
        return _mNextAvailableSlot
    }
}
