//
//  CategoryDetailViewController.swift
//  Reminder
//
//  Created by Dee on 2/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CategoryDetailViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var remindSwitch: UISwitch!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var radiusSegment: UISegmentedControl!
    @IBOutlet var prioritySegment: UISegmentedControl!
    
    var labelColor: String!
    var radius: Int!
    var priority: Int!
    var address: String!
    var latitude: Double!
    var longitude: Double!
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var masterDelegate: MasterDelegate?
    var category: Category!
    var managedObjectContext: NSManagedObjectContext
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        priority = 0
        radius = 50
        labelColor = "black"
        
        if category == nil {
            self.title = "New Category"
        } else {
            self.title = "Edit Category"
            showCategoryDetail()
        }
        
        if remindSwitch.on {
            radiusSegment.enabled = true
        } else {
            radiusSegment.enabled = false
            radius = 0
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        self.delegate?.reloadCategory()
//        self.masterDelegate?.refreshView()
    }
    
    func showCategoryDetail() {
        self.titleField.text = category.title
        changeColor(category.color!, textField: self.titleField)
        self.labelColor = category.color
        self.priority = Int(category.priority!)
        self.radius = Int(category.radius!)
        self.address = category.address
        self.latitude = Double(category.latitude!)
        self.longitude = Double(category.longitude!)
        if category.isRemind == true {
            remindSwitch.setOn(true, animated: true)
        } else {
            remindSwitch.setOn(false, animated: true)
        }
        switch priority {
        case 0:
            prioritySegment.selectedSegmentIndex = 0
            break
        case 1:
            prioritySegment.selectedSegmentIndex = 1
            break
        case 2:
            prioritySegment.selectedSegmentIndex = 2
            break
        case 3:
            prioritySegment.selectedSegmentIndex = 3
            break
        default:
            break
        }
        switch radius {
        case 50:
            radiusSegment.selectedSegmentIndex = 0
            break
        case 250:
            radiusSegment.selectedSegmentIndex = 1
            break
        case 1000:
            radiusSegment.selectedSegmentIndex = 2
            break
        default:
            break
        }
        self.searchBar.text = category.address
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        self.pointAnnotation = MKPointAnnotation()
        self.pointAnnotation.title = category.address
        
        self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: Double(category.latitude!), longitude: Double(category.longitude!))
        self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
        self.mapView.centerCoordinate = self.pointAnnotation.coordinate
        self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        let region = MKCoordinateRegion(center: self.mapView.centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
        self.mapView.setRegion(region, animated: true)
    }
    
    func changeColor(color:String, textField: UITextField) {
        switch color {
        case "purple":
            textField.textColor = UIColor(red: 166/255.0, green: 116/255.0, blue: 233/255.0, alpha: 1.0)
            break
        case "blue":
            textField.textColor = UIColor(red: 77/255.0, green: 202/255.0, blue: 233/255.0, alpha: 1.0)
            break
        case "green":
            textField.textColor = UIColor(red: 112/255.0, green: 215/255.0, blue: 89/255.0, alpha: 1.0)
            break
        case "red":
            textField.textColor = UIColor(red: 254/255.0, green: 76/255.0, blue: 52/255.0, alpha: 1.0)
            break
        case "orange":
            textField.textColor = UIColor(red: 249/255.0, green: 140/255.0, blue: 34/255.0, alpha: 1.0)
            break
        case "pink":
            textField.textColor = UIColor(red: 248/255.0, green: 136/255.0, blue: 223/255.0, alpha: 1.0)
            break
        case "yellow":
            textField.textColor = UIColor(red: 243/255.0, green: 242/255.0, blue: 103/255.0, alpha: 1.0)
            break
        case "black":
            textField.textColor = UIColor.blackColor()
            break
        default:
            textField.textColor = UIColor.blackColor()
            break
        }
    }
    
    @IBAction func sendReminder(sender: UISwitch) {
        if remindSwitch.on {
            radiusSegment.enabled = true
        } else {
            radiusSegment.enabled = false
            radius = 0
        }
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneAction(sender: UIBarButtonItem) {
        
        let title = self.titleField.text
        let isRemind = self.remindSwitch.on
        
        if(title!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "")
        {
            let messageString: String = "Please input valid title"
            // Setup an alert to warn user
            // UIAlertController manages an alert instance
            let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else if(self.searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" || self.latitude == nil || self.longitude == nil) {
            let messageString: String = "Please input valid address"
            // Setup an alert to warn user
            // UIAlertController manages an alert instance
            let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            if (category == nil) {
                category = (NSEntityDescription.insertNewObjectForEntityForName("Category",
                inManagedObjectContext: self.managedObjectContext) as? Category)!
            }
            category.title = title
            category.address = address
            category.color = labelColor
            category.isRemind = isRemind
            category.latitude = latitude
            category.longitude = longitude
            category.priority = priority
            category.radius = radius
            //self.delegate!.reloadCategory()
            if self.managedObjectContext.hasChanges {
                do {
                    try self.managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
            self.masterDelegate?.refreshTableView()
            self.masterDelegate?.refreshMapView()
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        address = searchBar.text
        if(address.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "")
        {
            let messageString: String = "Please input valid address"
            // Setup an alert to warn user
            // UIAlertController manages an alert instance
            let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            displayLocation(address)
        }

    }
    
    func displayLocation(address: String) {
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = address + " " + "Victoria Australia"
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.address
            self.latitude = localSearchResponse!.boundingRegion.center.latitude
            self.longitude = localSearchResponse!.boundingRegion.center.longitude
            
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude:     self.longitude)
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            let region = MKCoordinateRegion(center: self.mapView.centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
            self.mapView.setRegion(region, animated: true)
        }
    }

    @IBAction func setPriority(sender: UISegmentedControl) {
        switch prioritySegment.selectedSegmentIndex
        {
        case 0:
            priority = 0
            break
        case 1:
            priority = 1
            break
        case 2:
            priority = 2
            break
        case 3:
            priority = 3
            break
        default:
            break; 
        }
    }
    
    @IBAction func setRadius(sender: UISegmentedControl) {
        switch radiusSegment.selectedSegmentIndex {
        case 0:
            radius = 50
            break
        case 1:
            radius = 250
            break
        case 2:
            radius = 1000
            break
        default:
            break
        }
    }
    
    @IBAction func showInPurple(sender: UIButton) {
        labelColor = "purple"
        changeColor(labelColor, textField: self.titleField)
    }
    @IBAction func showInBlue(sender: UIButton) {
        labelColor = "blue"
        changeColor(labelColor, textField: self.titleField)
    }
    @IBAction func showInRed(sender: UIButton) {
        labelColor = "red"
        changeColor(labelColor, textField: self.titleField)
    }
    @IBAction func showInPink(sender: UIButton) {
        labelColor = "pink"
        changeColor(labelColor, textField: self.titleField)
    }
    @IBAction func showInYellow(sender: UIButton) {
        labelColor = "yellow"
        changeColor(labelColor, textField: self.titleField)
    }
    @IBAction func showInGreen(sender: UIButton) {
        labelColor = "green"
        changeColor(labelColor, textField: self.titleField)
    }
    @IBAction func showInOrange(sender: UIButton) {
        labelColor = "orange"
        changeColor(labelColor, textField: self.titleField)
    }
    
    // dismiss keyboard for search bar
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
