//
//  AlbumViewController.swift
//  Virtual Tourist
//
//  Created by Abdulla Hasanov on 11/26/19.
//  Copyright © 2019 Abdulla Hasanov. All rights reserved.
//

import UIKit
import MapKit

class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
       var pin: Pin!
    var photos: Array<Photo>?
    var dataController: DataController!
    @IBOutlet weak var NewCollectionButton: UIButton!
    
    
    @IBAction func onNewCollectionClick(_ sender: Any) {
        downloadPage()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let photos = photos {
            for photo in photos {
                if photo.photoBinary == nil {
                    debugPrint("Not all photos downloaded")
                    return
                }
            }
        }
        pin.removeFromPhotos(photos![indexPath.row])
        photos?.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        do {
            try dataController.viewContext.save()
        } catch {
            debugPrint("Unable to delete from store")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoViewCell
        cell.image.image = UIImage(named: "placeholder")
        cell.indicator.startAnimating()
        if let photo = photos?[indexPath.row].photoBinary {
            cell.image.image = UIImage(data: photo)
            cell.indicator.stopAnimating()
            return cell
        }
        if let photoUrlString = photos?[indexPath.row].photoUrl {
            if let photoUrl = URL(string: photoUrlString) {
                FlickrClient.downloadTaskForRequest(url: photoUrl) { data, error in
                    if let error = error {
                        self.showAlertVC(errorMessage: error.localizedDescription, completion: nil)
                    } else {
                        if let data = data {
                            cell.image.image = UIImage(data: data)
                            cell.indicator.stopAnimating()
                            self.photos?[indexPath.row].photoBinary = data
                            do {
                                try self.dataController.viewContext.save()
                            } catch {
                                debugPrint("Unable to save context")
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initFlowLayout()
        addLocToMapAndZoom()
        populatePhotosArray()
        if let photos = photos {
            if photos.count == 0 {
                downloadPage()
            }
        }
    }
    
    func populatePhotosArray() {
        if let photos = pin?.photos ?? nil {
            if self.photos == nil {
                self.photos = []
            }
            for photo in photos {
                self.photos!.append(photo as! Photo)
            }
        }
    }
    
    func downloadPage() {
        NewCollectionButton.isEnabled = false
        self.photos = []
        pin.removeFromPhotos(pin.photos ?? [])
        self.collectionView.reloadData()
        FlickrClient.getPhotoPage(lat: pin.latitude!, lon: pin.longitude!) { photos, error in
            if let error = error {
                self.showAlertVC(errorMessage: error.localizedDescription) { action in
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                if self.photos == nil {
                    self.photos = []
                }
                for photo in photos!.photo {
                    let photoObj: Photo = Photo(context: self.dataController.viewContext)
                    photoObj.photoUrl = FlickrClient.Endpoints.photo(photo: photo).stringValue
                    photoObj.pin = self.pin
                    self.photos!.append(photoObj)
                    try? self.dataController.viewContext.save()
                    self.collectionView.reloadData()
                    self.NewCollectionButton.isEnabled = true
                }
            }
        }
    }
    
    // Meme app lessons
    func initFlowLayout() {
       let space:CGFloat = 3.0
       let dimension = (view.frame.size.width - (2 * space)) / 3.0
       
       flowLayout.minimumInteritemSpacing = space
       flowLayout.minimumLineSpacing = space
       flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func addLocToMapAndZoom() {
        let lat = Double(pin.latitude!)!
        let long = Double(pin.longitude!)!
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        zoomToAnnotation(annotation: annotation)
    }
    
    // from my on the map project
    func zoomToAnnotation(annotation: MKPointAnnotation) {
        var zoomRect = MKMapRect.null
        let annotationPoint = MKMapPoint(annotation.coordinate)
        let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 300, height: 300)
        if (zoomRect.isNull) {
            zoomRect = pointRect
        } else {
            zoomRect = zoomRect.union(pointRect)
        }
        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
    
    func updateUI(newCollectionEnabled: Bool) {
        NewCollectionButton.isEnabled = newCollectionEnabled
    }
}
