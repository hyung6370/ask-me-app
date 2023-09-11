//
//  OnboardingViewController.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/07.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startButtonView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        startButton.layer.cornerRadius = 20
        startButton.clipsToBounds = true
        startButtonView.layer.cornerRadius = 13
        startButtonView.clipsToBounds = true
        
        titleLabel.layer.shadowColor = UIColor.darkGray.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowOpacity = 0.5
        titleLabel.layer.shadowRadius = 4
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        
    }
}
