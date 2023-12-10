//
//  TableViewCell.swift
//  first
//
//  Created by gvantsa gvagvalia on 7/22/23.
//

import UIKit

class ForecastVCCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
