//
//  HistoryViewController.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/08.
//

import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var semiTitleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var historyTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "History"
        configureUI()
    }
    
    func configureUI() {
        semiTitleLabel.layer.shadowColor = UIColor.darkGray.cgColor
        semiTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        semiTitleLabel.layer.shadowOpacity = 0.2
        semiTitleLabel.layer.shadowRadius = 4
        
        backView.layer.cornerRadius = 10
        backView.clipsToBounds = false
        backView.layer.shadowColor = UIColor.darkGray.cgColor
        backView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backView.layer.shadowOpacity = 0.5
        backView.layer.shadowRadius = 4
        backView.backgroundColor = UIColor(hexCode: "F5F5F4")
        
        
    }
}

