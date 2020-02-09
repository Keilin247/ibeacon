//
//  ViewController2.swift
//  iBeacon test
//
//  Created by Keilin on 2019/12/4.
//  Copyright © 2019 Keilin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController2: UIViewController , UIScrollViewDelegate{
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationBtn: UIButton!
    
    let locationManager = CLLocationManager();
    
    
    @IBAction func changeMapType(_ sender: UISegmentedControl) {    //切換地圖類型
        if sender.selectedSegmentIndex == 0{
            
            mapView.mapType = MKMapType.standard
        }
        else if sender.selectedSegmentIndex == 1{
            
            mapView.mapType = MKMapType.satellite
        }
    }
    
    @IBAction func LocationBtn(_ sender: UIButton) {                //地圖顯示系館的按鈕
        let depLocation = CLLocationCoordinate2D(latitude: 22.997218, longitude: 120.220838)
        let region = MKCoordinateRegion.init(center: depLocation, latitudinalMeters:200, longitudinalMeters:200)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
        locationManager.stopUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }else{
            //pop up tell user to turn on
        }
        //should add error handling is users location is not turned on
    }
    func centerViewOnUserLocation() {                               //把使用者定位放在銀幕中間
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters:300, longitudinalMeters:300)
            mapView.setRegion(region, animated: true)
        }
    }
    func checkLocationAuthorization(){                              //要求使用者允許app用定位功能
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse://procceed with app
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied://show how to turn on
            break
        case .restricted://show alert that it's resticted
            break
        case .authorizedAlways://not using this
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        }
    }
}

extension ViewController2: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 300, longitudinalMeters: 300 )
        mapView.setRegion(region, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationServices()
    }
}

extension UIViewController: MKMapViewDelegate {
    
}

