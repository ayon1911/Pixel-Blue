//
//  RetriveImage.swift
//  pixel-blue
//
//  Created by Khaled Rahman Ayon on 05/02/2018.
//  Copyright © 2018 Khaled Rahman Ayon. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import RxSwift

class RetriveImage {
    
    static let shared = RetriveImage()
    public private(set) var imageUrl = [String]()
    public private(set) var imageArray = [UIImage]()
    private let selectedVariable = Variable("")
    var downloadedImage: Observable<String> {
        return selectedVariable.asObservable()
    }
    
    //Download urls for each image
    func retriveUrls(forAnnotation annotation: DropablePin, handler: @escaping handler ) {
        Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, numberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String,AnyObject>]
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrl.append(postUrl)
            }
            handler(true)
        }
    }
    //download image
    func downloadImages(handler: @escaping handler) {
        for url in imageUrl {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.selectedVariable.value = "\(self.imageArray.count)/40 has downloaded"
                
                if self.imageArray.count == self.imageUrl.count {
                    handler(true)
                }
            })
        }
    }
    
    func cancelAllSession() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }

    func removeImages() {
        imageUrl.removeAll()
        imageArray.removeAll()
        self.selectedVariable.value = ""
    }
}
