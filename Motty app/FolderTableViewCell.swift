//
//  FolderTableViewCell.swift
//  Motty app
//
//  Created by Alexander Padin on 10/18/15.
//  Copyright © 2015 Alexander Padin. All rights reserved.
//

import UIKit

class FolderTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var numView: UILabel!
    @IBOutlet weak var nameView: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
