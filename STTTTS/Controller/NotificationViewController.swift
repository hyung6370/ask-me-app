//
//  NotificationViewController.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/10.
//

import UIKit

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var first: UILabel!
    @IBOutlet weak var second: UILabel!
    @IBOutlet weak var third: UILabel!
    @IBOutlet weak var fourth: UILabel!
    
    
    @IBOutlet weak var refButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        titleLabel.layer.shadowColor = UIColor.darkGray.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowOpacity = 0.2
        titleLabel.layer.shadowRadius = 4
        
        first.layer.shadowColor = UIColor.darkGray.cgColor
        first.layer.shadowOffset = CGSize(width: 0, height: 2)
        first.layer.shadowOpacity = 0.2
        first.layer.shadowRadius = 4
        
        second.layer.shadowColor = UIColor.darkGray.cgColor
        second.layer.shadowOffset = CGSize(width: 0, height: 2)
        second.layer.shadowOpacity = 0.2
        second.layer.shadowRadius = 4
        
        third.layer.shadowColor = UIColor.darkGray.cgColor
        third.layer.shadowOffset = CGSize(width: 0, height: 2)
        third.layer.shadowOpacity = 0.2
        third.layer.shadowRadius = 4
        
        fourth.layer.shadowColor = UIColor.darkGray.cgColor
        fourth.layer.shadowOffset = CGSize(width: 0, height: 2)
        fourth.layer.shadowOpacity = 0.2
        fourth.layer.shadowRadius = 4
        
        refButton.layer.cornerRadius = 15
        refButton.clipsToBounds = true
    }

    @IBAction func refButtonTapped(_ sender: UIButton) {
        if let url = URL(string: "https://www.youtube.com/watch?v=h4vyOz4Tztg&t=8956s") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    

}
