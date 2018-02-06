//
//  PopVC.swift
//  pixel-blue
//
//  Created by Khaled Rahman Ayon on 05/02/2018.
//  Copyright © 2018 Khaled Rahman Ayon. All rights reserved.
//

import UIKit
import RxSwift

class PopVC: UIViewController, UIGestureRecognizerDelegate {
    
    //Iboutlets
    @IBOutlet weak var imageView: UIImageView!
    //variables
    var passedInImage: UIImage!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = passedInImage
        addDoubleTap()
    }

  
    
    func initData(forImage image: UIImage) {
        self.passedInImage = image
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }
}
