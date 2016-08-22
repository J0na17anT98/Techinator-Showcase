//
//  DataService.swift
//  Techinators-Showcase
//
//  Created by Jonathan Tsistinas on 8/21/16.
//  Copyright © 2016 Techinator. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "https://techinators-showcase.firebaseio.com")
}