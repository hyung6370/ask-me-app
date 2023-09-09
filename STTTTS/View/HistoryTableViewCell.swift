//
//  HistoryTableViewCell.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/09.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var yearMonthDay: UILabel!
    @IBOutlet weak var hourMinuteSecond: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
