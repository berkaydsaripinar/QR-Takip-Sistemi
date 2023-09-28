//
//  OnlineTableViewCell.swift
//  TalkidoQR
//
//  Created by Berkay Sarıpınar on 18.07.2023.
//

import UIKit

class OnlineTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var onlineLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
