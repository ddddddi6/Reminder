//
//  CategoryMapViewController.swift
//  Reminder
//
//  Created by Dee on 4/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CategoryMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var managedObjectContext: NSManagedObjectContext
    var currentCategory: NSMutableArray
    var masterDelegate: MasterDelegate?
    var categotyId: String?
    
    required init?(coder aDecoder: NSCoder) {
        self.currentCategory = NSMutableArray()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

                if currentCategory.count != 0 {
            showCategoryOnMap()
        }
        // Setup delegation so we can respond to MapView and LocationManager events
        mapView.delegate = self
        locationManager.delegate = self
        
        // Ask user for permission to use location
        // Uses description from NSLocationAlwaysUsageDescription in Info.plist
        locationManager.requestAlwaysAuthorization()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if currentCategory.count != 0 {
            showCategoryOnMap()
        }
    }
    
    func showCategoryOnMap() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        let overlay = self.mapView.overlays
        self.mapView.removeOverlays(overlay)
        for category in self.currentCategory {
            let c: Category = category as! Category
            let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(c.latitude!), Double(c.longitude!))
            let objectAnnotation = MKPointAnnotation()
            objectAnnotation.coordinate = pinLocation
            objectAnnotation.title = c.title
            objectAnnotation.subtitle = c.objectID.URIRepresentation().absoluteString
            let rad = CLLocationDistance(c.radius!)
            self.mapView.addOverlay(MKCircle(centerCoordinate: pinLocation, radius: rad))
            self.mapView.addAnnotation(objectAnnotation)
        }
        let coordinate = CLLocationCoordinate2DMake(Double(currentCategory[0].latitude!!), Double(currentCategory[0].longitude!!))
        self.mapView.centerCoordinate = coordinate
        let region = MKCoordinateRegion(center: self.mapView.centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor(red: 254/255.0, green: 76/255.0, blue: 52/255.0, alpha: 0.5)
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
    
    // add info button for each annotation on map to jump to rehabilitation detail controller
    // solution from: http://stackoverflow.com/questions/28225296/how-to-add-a-button-to-mkpointannotation
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil
            return nil
        }
        if annotation is MKPointAnnotation {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        } else {
            pinView?.annotation = annotation
        }
        
        let button = UIButton(type: .DetailDisclosure) as UIButton // button with info sign in it
        
        pinView?.rightCalloutAccessoryView = button
        
        let titleView = UILabel()
        titleView.textColor = UIColor.clearColor()
        titleView.font = titleView.font.fontWithSize(1)
        titleView.text = annotation.title!
        pinView!.detailCalloutAccessoryView = titleView
        
        return pinView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.categotyId = self.mapView.selectedAnnotations[0].subtitle!
            self.performSegueWithIdentifier("showCategoryDetial", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCategoryDetial"
        {
            let theDestination : CategoryDetailViewController = segue.destinationViewController as! CategoryDetailViewController
            let url = NSURL(string: self.categotyId!)
            let id = (managedObjectContext.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url!))! as NSManagedObjectID
            theDestination.category = managedObjectContext.objectWithID(id) as! Category
            theDestination.masterDelegate = self.masterDelegate
        }
    }
    
//    func changeColor(color:String, pin: MKPinAnnotationView) {
//        switch color {
//        case "purple":
//            pin.tintColor = UIColor(red: 166/255.0, green: 116/255.0, blue: 233/255.0, alpha: 1.0)
//            break
//        case "blue":
//            pin.tintColor = UIColor(red: 77/255.0, green: 202/255.0, blue: 233/255.0, alpha: 1.0)
//            break
//        case "green":
//            pin.tintColor = UIColor(red: 112/255.0, green: 215/255.0, blue: 89/255.0, alpha: 1.0)
//            break
//        case "red":
//            pin.tintColor = UIColor(red: 254/255.0, green: 76/255.0, blue: 52/255.0, alpha: 1.0)
//            break
//        case "orange":
//            pin.tintColor = UIColor(red: 249/255.0, green: 140/255.0, blue: 34/255.0, alpha: 1.0)
//            break
//        case "pink":
//            pin.tintColor = UIColor(red: 248/255.0, green: 136/255.0, blue: 223/255.0, alpha: 1.0)
//            break
//        case "yellow":
//            pin.tintColor = UIColor(red: 243/255.0, green: 242/255.0, blue: 103/255.0, alpha: 1.0)
//            break
//        case "black":
//            pin.tintColor = UIColor.blackColor()
//            break
//        default:
//            pin.tintColor = UIColor.blackColor()
//            break
//        }
//    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
