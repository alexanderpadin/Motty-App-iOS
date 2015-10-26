//
//  FoldersViewController.swift
//  Motty app
//
//  Created by Alexander Padin on 10/17/15.
//  Copyright © 2015 Alexander Padin. All rights reserved.
//

import UIKit
import CoreData

class FoldersViewController: UITableViewController {
    
    private var appDelagate: AppDelegate = AppDelegate()
    private var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    
    //JSON-like data structure
    //struct of folder and places
    struct folderObj {
        var folder: (folderId: String, folderName: String, folderIcon: String, folderBackgroung: String, folderNumberOfItems: Int)
        var places: [(placeId: String, placeName: String, placeAddress: String, placeNote: String, placeX: Double, placeY: Double, folderId: String)]
    }
    
    //Array of folders
    var allFolders: [folderObj] = []
    var indexPressed: Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
        //Get AppDelegate Context
        appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
        context = appDelagate.managedObjectContext

    }

    //Called averytime the view appear
    override func viewDidAppear(animated: Bool) {
        allFolders = []
        fetchData()
    }
    
    //Fetch data and populate struct
    func fetchData() {
        var resultFolders : [AnyObject]?
        var resulsPlaces : [AnyObject]?
        
        //Read Folders and Places table
        let requestFolders = NSFetchRequest(entityName: "Folders")
        requestFolders.resultType = NSFetchRequestResultType.DictionaryResultType
        let requesPlaces = NSFetchRequest(entityName: "Places")
        requesPlaces.resultType = NSFetchRequestResultType.DictionaryResultType
        
        //Get folders name and IDs from db
        do {
            //Get folders
            resultFolders = [AnyObject]()
            resultFolders = try context.executeFetchRequest(requestFolders)
            
            //Get places
            resulsPlaces = [AnyObject]()
            resulsPlaces = try context.executeFetchRequest(requesPlaces)
            
            //populate data struct
            for folders in resultFolders! {
                let tempFolderID = folders.valueForKey("folderId") as! String
                allFolders.append(
                    folderObj(
                        folder: (
                            folderId: tempFolderID,
                            folderName: folders.valueForKey("folderName") as! String,
                            folderIcon: folders.valueForKey("folderIcon") as! String,
                            folderBackgroung: folders.valueForKey("folderBackground") as! String,
                            folderNumberOfItems: folders.valueForKey("folderNumOfItems") as! Int
                        ),
                        places: []
                    )
                )
                
                //Get places of each folder
                for places in resulsPlaces! {
                    if(tempFolderID == places.valueForKey("folderId") as! String) {
                        allFolders[allFolders.count - 1].places.append(
                            placeId: places.valueForKey("placeId") as! String,
                            placeName: places.valueForKey("placeName") as! String,
                            placeAddress: places.valueForKey("placeAddress") as! String,
                            placeNote: places.valueForKey("placeNote") as! String,
                            placeX: places.valueForKey("placeX") as! Double,
                            placeY: places.valueForKey("placeY") as! Double,
                            folderId: places.valueForKey("folderId") as! String
                        )
                    }
                }
            } //./populate struct
            tableView.reloadData()
        } catch _ {
            //TODO: Error Handling
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allFolders.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FolderTableViewCell

        cell.nameView.text = allFolders[indexPath.row].folder.folderName
        cell.numView.text = "\(allFolders[indexPath.row].folder.folderNumberOfItems) Places"
        //cell.iconView.image = UIImage(named: "\(allFolders[indexPath.row].folder.folderIcon).png")!
    
        UIGraphicsBeginImageContext(cell.cellView.frame.size)
        UIImage(named: "\(allFolders[indexPath.row].folder.folderBackgroung).png")?.drawInRect(cell.cellView.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        cell.cellView.backgroundColor = UIColor(patternImage: image)
    
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            allFolders.removeAtIndex(indexPath.row)
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    /*  Hack to get row index when is pressed  */
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if  sender is Int {
            return true
        } else {
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPlaces" {
//            let nav = segue.destinationViewController as! UINavigationController
//            let destinationViewController = nav.topViewController as! PlacesViewController

           let destinationViewController : PlacesViewController = segue.destinationViewController as! PlacesViewController
            
            destinationViewController.folderInfo = allFolders[(sender as! Int)].folder
            destinationViewController.placesInfo = allFolders[(sender as! Int)].places
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showPlaces", sender: indexPath.row as Int)
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}
