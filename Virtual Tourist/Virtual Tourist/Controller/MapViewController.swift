//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Abdulla Hasanov on 11/26/19.
//  Copyright © 2019 Abdulla Hasanov. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var pinsToDeleteLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var pinsToDeleteLabelConstraint: NSLayoutConstraint!
    
    var annotationToPinMap: Dictionary<MKPointAnnotation,Pin> = [:]
    
    var dataController: DataController!
    
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    var editMode = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.gestureRecognizers = [longPressGesture]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dataController = appDelegate.dataController
        initMap()
    }
    
    func initMap() {
        self.mapView.removeAnnotations(mapView.annotations)
        debugPrint("restoring view context")
        DispatchQueue.global(qos: .utility).async {
            let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
            var annotations: Array<MKPointAnnotation> = []
            if let pins = try? self.dataController.viewContext.fetch(fetchRequest) {
                for pin in pins{
                  let pinAnnotation = MKPointAnnotation()
                    pinAnnotation.coordinate = CLLocationCoordinate2D(latitude: Double(pin.latitude!)!, longitude: Double(pin.longitude!)!)
                    annotations.append(pinAnnotation)
                    self.annotationToPinMap[pinAnnotation] = pin
                }
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(annotations)
                }
            }
        }
    }

    @IBAction func onLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard !editMode else {
            return
        }
       if sender.state == .began {
           let gestureCoordinate = sender.location(in: mapView)
           let coordinate = mapView.convert(gestureCoordinate, toCoordinateFrom: mapView)
           let pinAnnotation = MKPointAnnotation()
           pinAnnotation.coordinate = coordinate
           mapView.addAnnotation(pinAnnotation)
           persistLocation(coordinate: coordinate, annotation: pinAnnotation)
       }
    }
    
    func persistLocation(coordinate: CLLocationCoordinate2D, annotation: MKPointAnnotation) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = String(coordinate.latitude)
        pin.longitude = String(coordinate.longitude)
        do {
            try dataController.viewContext.save()
            annotationToPinMap[annotation] = pin
        } catch {
            showAlertVC(errorMessage: "unable to save pin", completion: nil)
            mapView.removeAnnotation(annotation)
        }
    }
    
    func removeLocation(annotation: MKPointAnnotation) {
        let latitude: Double = annotation.coordinate.latitude
        let longitude: Double = annotation.coordinate.longitude
        debugPrint("Coordinates to delete: ", latitude, longitude)
        mapView.removeAnnotation(annotation)
        let pin = annotationToPinMap[annotation]
        annotationToPinMap[annotation] = nil
        if let pin = pin {
            dataController.viewContext.delete(pin)
            do {
                try dataController.viewContext.save()
            } catch {
                showAlertVC(errorMessage: "Unable to delete from persistence store", completion: nil)
            }
        }
    }
    
    @IBAction func onEditDoneClick(_ sender: Any) {
        editMode = !editMode
        if editMode {
            editBarButton.title = "Done"
            pinsToDeleteLabelConstraint.constant = 48
            
        } else {
            editBarButton.title = "Edit"
            pinsToDeleteLabelConstraint.constant = 0
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if editMode {
            if let annotation = view.annotation {
                debugPrint("remove location...")
                removeLocation(annotation: annotation as! MKPointAnnotation)
            }
        } else {
            performSegue(withIdentifier: "albumSegue", sender: self)
            view.setSelected(false, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == "albumSegue" {
                if let albumVC = segue.destination as? AlbumViewController {
                    albumVC.pin = annotationToPinMap[mapView.selectedAnnotations[0] as! MKPointAnnotation]
                    albumVC.dataController = dataController
                }
            }
        }
    }
}
