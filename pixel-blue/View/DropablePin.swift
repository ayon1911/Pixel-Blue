//
//  DropablePin.swift
//  pixel-blue
//
//  Created by Khaled Rahman Ayon on 02/02/2018.
//  Copyright © 2018 Khaled Rahman Ayon. All rights reserved.
//

import UIKit
import MapKit

class DropablePin: NSObject, MKAnnotation {
    //variables
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
