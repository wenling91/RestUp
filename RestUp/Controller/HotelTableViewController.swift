//
//  HotelTableViewController.swift
//  RestUp
//
//  Created by NDHU_CSIE on 2020/12/31.
//  Copyright © 2020 NDHU_CSIE. All rights reserved.
//

import UIKit
import CoreData

class HotelTableViewController: UITableViewController, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {

    var hotels: [HotelMO] = []
    var fetchResultController: NSFetchedResultsController<HotelMO>!
    var hotelToUpdate: HotelMO?
    var searchController: UISearchController!
    var searchResults: [HotelMO] = []
    
    
    // MARK: - Table view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadHotelFromDatabase()
        if hotels.isEmpty {
            //print("generate data from begining")
            Hotel.writeHotelFromBegin()
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        //not change the color of the search contents
        searchController.obscuresBackgroundDuringPresentation = false
        
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive {
            return searchResults.count
        } else {
            return hotels.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "datacell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HotelTableViewCell
        
        // Configure the cell...
        // Determine if we get the hotel from search result or the original array
        let hotel = (searchController.isActive) ? searchResults[indexPath.row] : hotels[indexPath.row]
        
        
        cell.nameLabel.text = hotel.name
        cell.locationLabel.text = hotel.location
        cell.typeLabel.text = hotel.type
        if let hotelImage = self.hotels[indexPath.row].image {
            cell.thumbnailImageView.image = UIImage(data: hotelImage as Data)
        }
        
        if hotel.isVisited {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        //cell.accessoryType = hotelIsVisited[indexPath.row] ? .checkmark : .none
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }
    
    
    //   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    //        // Create an option menu as an action sheet
    //        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
    //
    //        if let popoverController = optionMenu.popoverPresentationController {
    //            if let cell = tableView.cellForRow(at: indexPath) {
    //                popoverController.sourceView = cell
    //                popoverController.sourceRect = cell.bounds
    //            }
    //        }
    //
    //        // Add Call action
    //        let callActionHandler = { (action:UIAlertAction!) -> Void in
    //            let alertMessage = UIAlertController(title: "Service Unavailable", message: "Sorry, the call feature is not available yet. Please retry later.", preferredStyle: .alert)
    //            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    //            self.present(alertMessage, animated: true, completion: nil)
    //        }
    //
    //        let callAction = UIAlertAction(title: "Call " + "123-000-\(indexPath.row)", style: .default, handler: callActionHandler)
    //        optionMenu.addAction(callAction)
    //
    //        // Check-in action
    //        let checkInAction = UIAlertAction(title: "Check in", style: .default, handler: {
    //            (action:UIAlertAction!) -> Void in
    //
    //            let cell = tableView.cellForRow(at: indexPath)
    //            cell?.accessoryType = .checkmark
    //            self.hotelIsVisited[indexPath.row] = true
    //        })
    //        optionMenu.addAction(checkInAction)
    //
    //        //add undo check-in action
    //        let uncheckInAction = UIAlertAction(title: "Undo Check in", style: .default, handler: {
    //            (action:UIAlertAction!) -> Void in
    //
    //            let cell = tableView.cellForRow(at: indexPath)
    //            if self.hotelIsVisited[indexPath.row] {  //if ckecked
    //                cell?.accessoryType = .none
    //                self.hotelIsVisited[indexPath.row] = false
    //            }
    //        })
    //        optionMenu.addAction(uncheckInAction)
    //
    //
    //
    //        // Add actions to the menu
    //        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    //        optionMenu.addAction(cancelAction)
    //
    //        // Display the menu
    //        present(optionMenu, animated: true, completion: nil)
    //
    //        // Deselect a row
    //        tableView.deselectRow(at: indexPath, animated: false)
    
    
    //   }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            // Delete the row from the data store
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let hotelToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(hotelToDelete)
                
                appDelegate.saveContext()
            }
            
            // Call completion handler with true to indicate
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (action, sourceView, completionHandler) in
            let defaultText = "Just checking in at " + self.hotels[indexPath.row].name!
            
            let activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, sourceView, completionHandler) in
            //get the cooresponding managed object
            self.hotelToUpdate = self.fetchResultController.object(at: indexPath)
            self.performSegue(withIdentifier: "updateHotel", sender: nil)
            print("editing")
            
            completionHandler(true)
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction, editAction])
        
        // Set the icon and background color for the actions
        deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        //deleteAction.image = UIImage(systemName: "trash") //iOS 13
        deleteAction.image = UIImage(named: "delete")  //iOS 12
        
        
        shareAction.backgroundColor = UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        //shareAction.image = UIImage(systemName: "square.and.arrow.up")
        shareAction.image = UIImage(named: "share") //iOS 12
        
        return swipeConfiguration
    }
    
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let checkInAction = UIContextualAction(style: .normal, title: "Check-in") { (action, sourceView, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath) as! HotelTableViewCell
            self.hotels[indexPath.row].isVisited = (self.hotels[indexPath.row].isVisited) ? false : true
            cell.accessoryType = self.hotels[indexPath.row].isVisited ? .checkmark : .none
            
            completionHandler(true)
        }
        
        // let checkInIcon = hotels[indexPath.row].isVisited ? "arrow.uturn.left" : "checkmark"
        let checkInIcon = hotels[indexPath.row].isVisited ? "undo" : "tick"
        checkInAction.backgroundColor = UIColor(red: 38.0/255.0, green: 162.0/255.0, blue: 78.0/255.0, alpha: 1.0)
        //checkInAction.image = UIImage(systemName: checkInIcon)
        checkInAction.image = UIImage(named: checkInIcon)  //iOS 12
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [checkInAction])
        
        
        return swipeConfiguration
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHotelDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! HotelDetailViewController
                destinationController.hotel = (searchController.isActive) ? searchResults[indexPath.row] : hotels[indexPath.row]
            }
        }
        else if segue.identifier == "updateHotel" {
            let destinationController = segue.destination as! UINavigationController
            let topView = destinationController.topViewController as! NewHotelController
            topView.hotelToUpdate = hotelToUpdate
        }
        
    }
    
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    // Fetch data from data store
    private func loadHotelFromDatabase() {
        let fetchRequest: NSFetchRequest<HotelMO> = HotelMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    hotels = fetchedObjects
                    //print("load data from database with \(hotels.count) entries")
                }
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        
        if let fetchedObjects = controller.fetchedObjects {
            hotels = fetchedObjects as! [HotelMO]
        }
    }
    
    
    
    // MARK: - Search bar none core data version
    
    func filterContent(for searchText: String) {
        
        searchResults = hotels.filter({ (hotel) -> Bool in
            let name = hotel.name
            let isMatch = name!.localizedCaseInsensitiveContains(searchText)
            
            return isMatch
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }

}
