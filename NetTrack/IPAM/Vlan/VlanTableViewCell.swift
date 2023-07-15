//
//  VlanTableViewCell.swift
//  NetTrack
//
//  Created by Nikola Mutic on 16/5/2023.
//

import UIKit
import SwiftUI

class VlanTableViewCell: UITableViewCell {
    
    private let circleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10 // Adjust the corner radius as needed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Add the circle view to the cell's content view
        contentView.addSubview(circleView)
        
        // Configure constraints for the circle view
        NSLayoutConstraint.activate([
            circleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 20), // Adjust the width as needed
            circleView.heightAnchor.constraint(equalToConstant: 20) // Adjust the height as needed
        ])
    }
    
    func configure(with vlan: Vlan) {
        // Customize the appearance of the circle view based on the VLAN status
        switch vlan.status {
        case .Active:
            circleView.backgroundColor = UIColor(Color.blue)
        case .Reserved:
            circleView.backgroundColor = UIColor(Color.orange)
        case .Depreciated:
            circleView.backgroundColor = UIColor(Color.gray)
        default:
            circleView.backgroundColor = UIColor(Color.gray)
        }
        
        // Configure the title and subtitle labels with VLAN data
        textLabel?.text = "VLAN ID: \(vlan.vlanId ?? 0)"
        detailTextLabel?.text = vlan.name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
