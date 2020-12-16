//
//  paintingCell.swift
//  paintme
//
//  Created by Megan Worrel on 12/14/20.
//

import UIKit

class paintingCell: UITableViewCell {

    @IBOutlet weak var painting: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
