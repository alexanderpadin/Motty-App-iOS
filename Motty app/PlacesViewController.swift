//
//  PlacesViewController.swift
//  Motty app
//
//  Created by Alexander Padin on 10/17/15.
//  Copyright © 2015 Alexander Padin. All rights reserved.
//

import UIKit
import MapKit

class PlacesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var nameView: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var numView: UILabel!
    
    var folderInfo: (folderId: String, folderName: String, folderIcon: String, folderBackgroung: String, folderNumberOfItems: Int) =
        (folderId: "", folderName: "", folderIcon: "", folderBackgroung: "", folderNumberOfItems: 0)
    var placesInfo: [(placeId: String, placeName: String, placeAddress: String, placeNote: String, placeX: Double, placeY: Double, folderId: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //self.navigationController?.navigationBar.tintColor = UIColor.redColor().whiteColor()
        //self.navigationController?.navigationBar.hidden = true
        
        

        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        print(folderInfo)
        print("")
        print(placesInfo)
    
            
//        nameView.text = folderInfo.folderName
//        numView.text = "\(folderInfo.folderNumberOfItems) Places"
//        
//        UIGraphicsBeginImageContext(bgView.frame.size)
//        UIImage(named: "\(folderInfo.folderBackgroung).png")?.drawInRect(bgView.bounds)
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        bgView.backgroundColor = UIColor(patternImage: image)

        
       
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.placesInfo.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCellWithReuseIdentifier("item", forIndexPath: indexPath) as! PlaceCollectionViewCell
       
        item.itemNameLabel?.text = self.placesInfo[indexPath.row].placeName
        
        let splittedAddress = self.placesInfo[indexPath.row].placeAddress.characters.split{$0 == ","}.map(String.init)
        item.itemAddressLabel.text = splittedAddress[0]
        
        item.itemNoteLabel.text = self.placesInfo[indexPath.row].placeNote
        
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, item.bounds.size.width, item.bounds.size.height))
        imageViewBackground.image = UIImage(named: "map_bg\(indexPath.row%10).png")
        imageViewBackground.contentMode = UIViewContentMode.ScaleToFill
        item.bgView.addSubview(imageViewBackground)
        item.bgView.sendSubviewToBack(imageViewBackground)
        
       
        
        item.layer.cornerRadius = 6
        item.layer.masksToBounds = true
        item.layer.shadowOffset = CGSize(width: 1, height: 1)
        item.layer.shadowOpacity = 0.2
        item.layer.shadowRadius = 6.0
    
        return item
    }
    
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let itemSize = (screenSize.width / 2) - 15
            
            return CGSize(width: itemSize, height: itemSize)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let itemSize = (screenSize.width / 2) - 15
            
            let cellWidth : CGFloat = itemSize;
            let numberOfCells = floor(self.view.frame.size.width / cellWidth);
            let edgeInsets = (self.view.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1);
            
            // (top, left, bottom, right)
            return UIEdgeInsetsMake(10, edgeInsets, 60.0, edgeInsets);
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        print(self.placesInfo[indexPath.row].placeName)
    }
    
}
