//
//  TableViewCell.swift
//  TalkidoQR
//
//  Created by yasin on 12.07.2023.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var moveLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var infoLabel: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
