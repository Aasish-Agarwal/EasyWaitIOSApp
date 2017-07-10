//
//  Globals.swift
//  ewait
//
//  Created by Aakansha on 29/05/17.
//  Copyright © 2017 Smart Creatives. All rights reserved.
//

import Foundation

struct GlobalConstants
{
    static let server: String = "http://52.24.120.4:8001/"
}

struct AuthenticationEvents
{
    static let TokenExpired: String = "Authentication Token Expired"
    static let NotAuthenticated: String = "Not Authenticated"
}

struct QueueEvents
{
    static let AppointmentSuccess: String = "Appointment Successful"
    static let AppointmentFail: String = "Booking Appointment Failed"
    static let AppointmentListUpdated: String = "Appointment List Updated"
    static let AppointmentListUpdateFailed: String = "Appointment List Update Failed"
    
}

struct StringsLib
{
    static let AuthFailTitle: String = "Authorization Failure"
    static let AuthMsgTokenExpired: String = "Session Expired. Sign In and Retry "
    
    static let TitleNoAuth: String = "Sign In Required For This Operation"
    static let MsgNoAuth: String = "Sign In Required For This Operation"
    


}

enum JSONError: String, Error {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
}

