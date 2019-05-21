//
//  DetailViewController.swift
//  Maplication
//
//  Created by William Fischer on 15/5/19.
//  Copyright © 2019 William Fischer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var latInput: UITextField!
    @IBOutlet weak var lngInput: UITextField!
    @IBOutlet weak var coreMap: MKMapView!
    
    let geoCoder = CLGeocoder()
    var name:String = ""
    var address:String = ""
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = name.description
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        
        //setup delegates
        addressInput.delegate = self;
        lngInput.delegate = self;
        latInput.delegate = self;
    }
    
    // Run when any input is returned
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        
        textField.resignFirstResponder()
        let returnedAddress = addressInput.text!
        print(returnedAddress)
        
        let theAddress = "\(addressInput.text!)";
        
        if(theAddress.isEmpty){
            
            // RUN REVERSE GEO LOOKUP
            
            let lat = Double(latInput.text ?? "")
            let lng = Double(lngInput.text ?? "")
            
            let center = CLLocation(latitude: lat!, longitude: lng!);
            
            geoCoder.reverseGeocodeLocation(center) {
                placemarks, error in
                if (error != nil)
                {
                    // IF ERROR
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    
                    // Convert address types
                    
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    print(addressString)
                    self.addressInput.text = "\(addressString)";
                    
                    // Center location on map
                    let center = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    self.coreMap.setRegion(region, animated: true)
                    
                    // Add Pin on location
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = center;
                    self.coreMap.addAnnotation(annotation)
                    
                    self.detailItem = "\(addressString)"
                    
                }
            }
            
        }else{
            // RUN GEO LOOKUP
            
            geoCoder.geocodeAddressString(returnedAddress) {
                placemarks, error in
                let placemark = placemarks?.first
                
                
                // Call Set function
                let lat = Double(placemark?.location?.coordinate.latitude ?? 0)
                let lng = Double(placemark?.location?.coordinate.longitude ?? 0)
                let convertedLat = String(format: "%f",(lat))
                let convertedLng = String(format: "%f",(lng))
                
                print("Lat: \(convertedLat), Lng: \(convertedLng)")
                
                // Call Set function
                self.setInputs(lat: "\(convertedLat)", lng: "\(convertedLng)");
                
                // Center location on map
                let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.coreMap.setRegion(region, animated: true)
                
                // Add Pin on location
                let annotation = MKPointAnnotation()
                annotation.coordinate = center;
                self.coreMap.addAnnotation(annotation)
            }
            
        }
        
        
        
        return true
    }
    
    // Set Lat & Lng Inputs when address is recieved.
    func setInputs(lat: String, lng: String) -> String {
        if(lat.count > 2 && lng.count > 2){
            latInput.text = "\(lat)";
            lngInput.text = "\(lng)";
        }
        
        return "";
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }

}

