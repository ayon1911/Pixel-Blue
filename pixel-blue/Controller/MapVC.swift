//
//  ViewController.swift
//  pixel-blue
//
//  Created by Khaled Rahman Ayon on 02/02/2018.
//  Copyright © 2018 Khaled Rahman Ayon. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RxSwift
import RxCocoa

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    static let shared = MapVC()
    
    //IbOutlets
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullViewHeightConstraints: NSLayoutConstraint!
    //variables
    private let selectedVariable = Variable(UIImage())
    var imageData: Observable<UIImage> {
        return selectedVariable.asObservable()
    }
    
    var screenSize = UIScreen.main.bounds
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    let disposeBag = DisposeBag()
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var collectionView: UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    var imageUrlArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        registerForPreviewing(with: self, sourceView: collectionView!)
        pullUpView.addSubview(collectionView!)
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }

    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    @objc func animateViewDown() {
        RetriveImage.shared.cancelAllSession()
        pullViewHeightConstraints.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func animateViewUp() {
        pullViewHeightConstraints.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
            
        }
    }
    
    @IBAction func centerLocationBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    func getProgressLbl() {
        RetriveImage.shared.downloadedImage.subscribe(onNext: { [weak self] lblTxt in
            self?.progressLbl?.text = lblTxt
        }).disposed(by: disposeBag)
    }
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        removeSpinner()
        removeProgressLbl()
        RetriveImage.shared.cancelAllSession()
        
        RetriveImage.shared.removeImages()
        collectionView?.reloadData()
  
        addProgressLbl()
        animateViewUp()
        addSwipe()
        addSpinner()
        
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DropablePin(coordinate: touchCoordinate, identifier: "pin")
        mapView.addAnnotation(annotation)
                
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        RetriveImage.shared.retriveUrls(forAnnotation: annotation) { (success) in
            if success {
                self.getProgressLbl()
                RetriveImage.shared.downloadImages(handler: { (success) in
                    if success {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 125, y: 175, width: 250, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        progressLbl?.textAlignment = .center
        progressLbl?.text = "Loading Images"
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RetriveImage.shared.imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imageFromIndex = RetriveImage.shared.imageArray[indexPath.row]
            let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        selectedVariable.value = RetriveImage.shared.imageArray[indexPath.row]
        self.imageData.subscribe(onNext: { [weak self] (img) in
            guard let popVC = self?.storyboard?.instantiateViewController(withIdentifier: StoryBoardIDS.POP_VC.rawValue) as? PopVC else { return }
            popVC.initData(forImage: img)
            self?.present(popVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
}

extension MapVC: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        guard let popVc = storyboard?.instantiateViewController(withIdentifier: StoryBoardIDS.POP_VC.rawValue) as? PopVC else { return nil}
        popVc.initData(forImage: RetriveImage.shared.imageArray[indexPath.row])
        
        previewingContext.sourceRect = cell.contentView.frame
        return popVc
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}







