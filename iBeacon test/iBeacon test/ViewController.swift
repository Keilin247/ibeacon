//
//  ViewController.swift
//  iBeacon test
//
//  Created by Keilin on 2019/11/4.
//  Copyright © 2019 Keilin. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion


class ViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var beaconImg_1: UIImageView!
    @IBOutlet weak var beaconImg_2: UIImageView!
    @IBOutlet weak var beaconImg_3: UIImageView!
    @IBOutlet weak var Map: UIImageView!
    @IBOutlet weak var beaconNameText: UILabel!
    @IBOutlet weak var beaconLabel: UILabel!
    @IBOutlet weak var beaconDistanceText: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    
    
    //var userImg = UIImageView(frame : CGRect(x:189, y:440, width:50, height:50));
    
    
    struct beaconObj {
        var x = 0.1
        var y = 0.1
        var r = 0.1
    }
    var bea1 = beaconObj();
    var bea2 = beaconObj();
    var bea3 = beaconObj();
    var nesw = "";
    var userLastX:CGFloat = 0.0 ;
    var userLastY:CGFloat = 0.0;
    var rollingRssi1 = 59.0;
    var rollingRssi2 = 59.0;
    var rollingRssi3 = 59.0;
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(uuidString: "05372221-A417-4823-8277-589464CC67A4")! as UUID, identifier: "School")
    let colors = [
        1: UIColor(red: 233/255, green: 13/255, blue: 13/255, alpha:1),//red
        2: UIColor(red: 13/255, green: 255/255, blue: 220/255, alpha:1),//blue
        3: UIColor(red: 6/255, green: 255/255, blue: 22/255, alpha:1),//green
        4: UIColor(red: 251/255, green: 204/255, blue: 229/255, alpha:1),//pink
        5: UIColor(red: 255/255, green: 148/255, blue: 6/255, alpha:1)//orange
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse){
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        
        
        if (CLLocationManager.headingAvailable()) {
            locationManager.headingFilter = 5
            locationManager.startUpdatingHeading()
        }else{
            print("no heading")
        }
//        let beacon1_x = 149
//        let beacon1_y = 344//12m between 1 and 3
//        let beacon2_x = 275//7m between 1 and 2
//        let beacon2_y = 452//6m between 1,3 and 2
//        let beacon3_x = 149
//        let beacon3_y = 560
        
//         hall = 40.5m(stairs to wall)
//         stairs to wall(elevator) = 6.3m
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        UIView.animate(withDuration: 0.5) {
            let angle = (newHeading.trueHeading+70).degreesToRadians // convert from degrees to radians
            self.userImg.transform = CGAffineTransform(rotationAngle: CGFloat(angle+2.1)) // rotate the picture
            print(newHeading.trueHeading,"," , angle+2.1);
            if(newHeading.trueHeading<120 && newHeading.trueHeading>60 ){
                self.nesw = "east";
            }
            if(newHeading.trueHeading<210 && newHeading.trueHeading>150){
                self.nesw = "south"
            }
            if(newHeading.trueHeading<300 && newHeading.trueHeading>240 ){
                self.nesw = "west"
            }
            if(newHeading.trueHeading<30 || newHeading.trueHeading>330 && newHeading.trueHeading<360){
                self.nesw = "north"
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if(beacons.count>0){
            let closestBeacon = beacons[0]
            let kFilteringFactor = 0.25;
            self.view.backgroundColor = self.colors[closestBeacon.minor.intValue]
            beaconNameText.text = "Beacon " + closestBeacon.minor.stringValue 
            beaconLabel.text = closestBeacon.description
            
            
            userImg.image = UIImage(named:"point")
            for i in 0...beacons.count-1{
                print(beacons[i].minor , beacons[i].rssi)
                if(beacons[i].minor.stringValue=="1"){
                    rollingRssi1 = (Double(beacons[i].rssi) * kFilteringFactor) + (rollingRssi1 * (1.0 - kFilteringFactor));
                    print(rollingRssi1);
                    bea1.r = Double(round(1000*calculateDistance(rssi: Double(rollingRssi1)))/100)
                }
                if(beacons[i].minor.stringValue=="2"){
                    rollingRssi2 = (Double(beacons[i].rssi) * kFilteringFactor) + (rollingRssi2 * (1.0 - kFilteringFactor));
                    print(rollingRssi2);
                    bea2.r = Double(round(1000*calculateDistance(rssi:  Double(rollingRssi2)))/100)
                }
                if(beacons[i].minor.stringValue=="3"){
                    rollingRssi3 = (Double(beacons[i].rssi) * kFilteringFactor) + (rollingRssi3 * (1.0 - kFilteringFactor));
                    print(rollingRssi3);
                    bea3.r = Double(round(1000*calculateDistance(rssi:  Double(rollingRssi3)))/100)
                }
            }
            if(beacons.count<3){
                self.userImg.center.x = userLastX;
                self.userImg.center.y = userLastY;
            }else{
                let userx = getUserX(xa: 149, xb: 275 ,xc: 149, ya: 344, yb: 452, yc: 560, ra: Float(bea1.r.mapRatio), rb: Float(bea2.r.mapRatio), rc: Float(bea3.r.mapRatio))
                let usery = getUserY(xa: 149, xb: 275 ,xc: 149, ya: 344, yb: 452, yc: 560, ra: Float(bea1.r.mapRatio), rb: Float(bea2.r.mapRatio), rc: Float(bea3.r.mapRatio))
                if( userx<280 && userx>130 && usery<560 && usery>330){
                    userLastX = CGFloat(getUserX(xa: 149, xb: 275 ,xc: 149, ya: 344, yb: 452, yc: 560, ra: Float(bea1.r.mapRatio), rb: Float(bea2.r.mapRatio), rc: Float(bea3.r.mapRatio)));
                    userLastY = CGFloat(getUserY(xa: 149, xb: 275 ,xc: 149, ya: 344, yb: 452, yc: 560, ra: Float(bea1.r.mapRatio), rb: Float(bea2.r.mapRatio), rc: Float(bea3.r.mapRatio)));
                    self.userImg.center.x = userLastX;
                    self.userImg.center.y = userLastY;
                    print("ra:" ,bea1.r, "rb:",bea2.r, "rc:", Float(bea3.r))
                }
                let Radius = " 1: " + bea1.r.description;
                beaconDistanceText.text = Radius + " 2: " + bea2.r.description + " 3: " + bea3.r.description;
                //
            }
            
        }

    }
    
    func calculateDistance(rssi:Double) -> Double{
    
        let txPower = -70.0 //hard coded power value. Usually ranges between -59 to -65

        if (rssi == 0) {
        return -1.0;
        }

        let ratio = rssi*1.0/txPower;
        if (ratio < 1.0) {
            return pow(Double(ratio),10);
        }
        else {
            let distance =  (0.89976)*pow(Double(ratio),7.7095) + 0.111;
        return distance;
        }
//        let n = 4.0;
//        let d = pow(10,((-rssi)+txPower)/(10.0 * n));
//        return d
        
    }
    
    func getUserX(xa:Float,xb:Float,xc:Float,ya:Float,yb:Float,yc:Float,ra:Float,rb:Float,rc:Float) -> Float{
        let W = ra*ra - rb*rb - xa*xa - ya*ya + xb*xb + yb*yb;
        let Z = rb*rb - rc*rc - xb*xb - yb*yb + xc*xc + yc*yc;
        
        let x = (W*(yc-yb) - Z*(yb-ya)) / (2 * ((xb-xa)*(yc-yb) - (xc-xb)*(yb-ya)));
        
//        let x = ((y * (ya - yb)) - T) / (xb - xa);
        
        return x;
    }
    func getUserY(xa:Float,xb:Float,xc:Float,ya:Float,yb:Float,yc:Float,ra:Float,rb:Float,rc:Float) -> Float{
        let W = ra*ra - rb*rb - xa*xa - ya*ya + xb*xb + yb*yb;
        let Z = rb*rb - rc*rc - xb*xb - yb*yb + xc*xc + yc*yc;
        
        let x = (W*(yc-yb) - Z*(yb-ya)) / (2 * ((xb-xa)*(yc-yb) - (xc-xb)*(yb-ya)));
        var y = (W - 2*x*(xb-xa)) / (2*(yb-ya));
        //y2 is a second measure of y to mitigate errors
        let y2 = (Z - 2*x*(xc-xb)) / (2*(yc-yb));
        
        y = (y + y2) / 2;
        
        return y;
    }
    
    
}
extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
    var radiansToDegrees: CGFloat { return self * 180 / .pi }
    var mapRatio: CGFloat { return self * 18.0}
}
private extension Double {
    var degreesToRadians: Double { return Double(CGFloat(self).degreesToRadians) }
    var radiansToDegrees: Double { return Double(CGFloat(self).radiansToDegrees) }
    var mapRatio: Double { return Double(CGFloat(self).mapRatio) }
}
extension UIView {
    
    // Set x Position
    func setX(x:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.x = x
        self.frame = frame
    }
     //Set y Position
    func setY(y:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.y = y
        self.frame = frame
    }
}
