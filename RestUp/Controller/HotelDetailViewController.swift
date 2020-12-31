//
//  HotelDetailViewController.swift
//  RestUp
//
//  Created by NDHU_CSIE on 2020/12/31.
//  Copyright © 2020 NDHU_CSIE. All rights reserved.
//

import UIKit

class HotelDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: HotelDetailHeaderView!
    
    var hotel: HotelMO!
    
    // MARK: - Table view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        // Configure header view
        headerView.nameLabel.text = hotel.name
        headerView.typeLabel.text = hotel.type
        if let hotelImage = hotel.image {
            headerView.headerImageView.image = UIImage(data: hotelImage as Data)
        }
        headerView.heartImageView.isHidden = (hotel.isVisited) ? false : true
        if let rating =  hotel.rating {
            headerView.ratingImageView.image = UIImage(named: rating)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelDetailIconTextCell.self), for: indexPath) as! HotelDetailIconTextCell
            //        cell.iconImageView.image = UIImage(systemName: "phone")?.withTintColor(.black, renderingMode: .alwaysOriginal)
            cell.iconImageView.image = UIImage(named: "phone")
            cell.shortTextLabel.text = hotel.phone
            cell.selectionStyle = .none
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelDetailIconTextCell.self), for: indexPath) as! HotelDetailIconTextCell
            //        cell.iconImageView.image = UIImage(systemName: "map")?.withTintColor(.black, renderingMode: .alwaysOriginal)
            cell.iconImageView.image = UIImage(named: "map")
            cell.shortTextLabel.text = hotel.location
            cell.selectionStyle = .none
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelDetailTextCell.self), for: indexPath) as! HotelDetailTextCell
            cell.descriptionLabel.text = hotel.summary
            cell.selectionStyle = .none
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelDetailSeparatorCell.self), for: indexPath) as! HotelDetailSeparatorCell
            cell.titleLabel.text = "HOW TO GET HERE"
            cell.selectionStyle = .none
            
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelDetailMapCell.self), for: indexPath) as! HotelDetailMapCell
            cell.selectionStyle = .none
            if let hotelLocation = hotel.location {
                cell.configure(location: hotelLocation)
            }
            
            return cell
            
        default:
            fatalError("Failed to instantiate the table view cell for detail view controller")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let destinationController = segue.destination as! MapViewController
            destinationController.hotel = hotel
        }
        else if segue.identifier == "showReview" {
            let destinationController = segue.destination as! ReviewViewController
            destinationController.hotel = hotel
        }
    }
    
    @IBAction func close(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rateHotel(segue: UIStoryboardSegue) {
        if let rating = segue.identifier {
            self.hotel.rating = rating
            self.headerView.ratingImageView.image = UIImage(named: rating)
        }
        
        dismiss(animated: true, completion: nil)
    }

}
