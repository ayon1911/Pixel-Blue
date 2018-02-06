//
//  Constants.swift
//  pixel-blue
//
//  Created by Khaled Rahman Ayon on 02/02/2018.
//  Copyright © 2018 Khaled Rahman Ayon. All rights reserved.
//

import Foundation

let API_KEY = "8d3d2e1f01bd0a28f0de9a652ff3d22a"

func flickrUrl(forApiKey key: String, withAnnotation annotation: DropablePin, numberOfPhotos number: Int ) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
}

typealias handler = (_ success: Bool) -> ()

//storyboardIDs
enum StoryBoardIDS: String {
    case POP_VC = "PopVC"
}
