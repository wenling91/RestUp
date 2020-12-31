//
//  HotelDetailHeaderView.swift
//  RestUp
//
//  Created by NDHU_CSIE on 2020/12/31.
//  Copyright © 2020 NDHU_CSIE. All rights reserved.
//

import UIKit

class HotelDetailHeaderView: UIView {

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var heartImageView: UIImageView! {
        didSet {
            heartImageView.image = UIImage(named: "heart-tick")?.withRenderingMode(.alwaysTemplate)
            heartImageView.tintColor = .white
        }
    }
    
    @IBOutlet var ratingImageView: UIImageView!

}
