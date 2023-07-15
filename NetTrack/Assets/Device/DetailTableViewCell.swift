//
//  DetailTableViewCell.swift
//  NetTrack
//
//  Created by Nikola Mutic on 10/5/2023.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    
    @IBOutlet weak var attributeLabel: UILabel!
    @IBOutlet weak var attributeValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
