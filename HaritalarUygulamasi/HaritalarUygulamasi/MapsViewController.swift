//
//  ViewController.swift
//  HaritalarUygulamasi
//
//  Created by Abdullah Karagöz on 27.03.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var notTextField: UITextField!
    
    var locationManager = CLLocationManager()
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    var secilenIsim = ""
    var secilenId : UUID?
    
    var annonationTitle = ""
    var annonationSubTitle = ""
    var annonationLatitude = Double()
    var annonationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if secilenIsim != "" {
            // Core Data'dan verileri çek
            
            if let uuidString = secilenId?.uuidString{
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    
                    if sonuclar.count > 0 {
                            
                        for sonuc in sonuclar as! [NSManagedObject] {
                            
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                annonationTitle = isim
                                if let not = sonuc.value(forKey: "not") as? String {
                                    annonationSubTitle = not
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double {
                                        annonationLatitude = latitude
                                        if let longitude = sonuc.value(forKey: "longitude") as? Double {
                                            annonationLongitude = longitude
                                        
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annonationTitle
                                            annotation.subtitle = annonationSubTitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annonationLatitude, longitude: annonationLongitude)
                                            annotation.coordinate = coordinate

                                            mapView.addAnnotation(annotation)
                                            isimTextField.text = annonationTitle
                                            notTextField.text = annonationSubTitle
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                        
                    }
                    
                } catch {
                    print("Veri çekilirken hata oluştu!")
                }
                
            }
        } else {
            // Yeni veri ekle
        
        }
        
    }
    
    @objc func konumSec(gestureRecognizer : UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            
            let dokunulanNokta = gestureRecognizer.location(in: mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
        
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
            annotation.title = isimTextField.text
            annotation.subtitle = notTextField.text
            mapView.addAnnotation(annotation)
        
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       //print(locations[0].coordinate.latitude)
       //print(locations[0].coordinate.longitude)
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 2.00, longitudeDelta: 2.00)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func kaydetTiklandi(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(notTextField.text, forKey: "not")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")

        
        do {
            try context.save()
                print("Kayıt edildi.")
        } catch {
                print("Kayıt edilirken hata oluştu!")
            }
        }
    
    
}
