//
//  DetailViewController.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/09.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var semiTitleLabel: UILabel!
    @IBOutlet weak var answerBackView: UIView!
    @IBOutlet weak var meBackView: UIView!
    
    @IBOutlet weak var chatGptTextView: UITextView!
    @IBOutlet weak var meLabel: UILabel!
    @IBOutlet weak var hourMinuteSecond: UILabel!
    
    var myQuestion: String?
    var gptAnswer: String?
    var createDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        loadData()
        divideDate()
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureUI() {
        semiTitleLabel.layer.shadowColor = UIColor.darkGray.cgColor
        semiTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        semiTitleLabel.layer.shadowOpacity = 0.2
        semiTitleLabel.layer.shadowRadius = 4
        
        answerBackView.layer.cornerRadius = 10
        answerBackView.clipsToBounds = false
        answerBackView.layer.shadowColor = UIColor.darkGray.cgColor
        answerBackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        answerBackView.layer.shadowOpacity = 0.5
        answerBackView.layer.shadowRadius = 4
        answerBackView.backgroundColor = UIColor(hexCode: "F5F5F4")
        
        meBackView.layer.cornerRadius = 10
        meBackView.clipsToBounds = false
        meBackView.layer.shadowColor = UIColor.darkGray.cgColor
        meBackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        meBackView.layer.shadowOpacity = 0.5
        meBackView.layer.shadowRadius = 4
        meBackView.backgroundColor = UIColor(hexCode: "F5F5F4")
        
        chatGptTextView.layer.cornerRadius = 10
        chatGptTextView.clipsToBounds = false
        chatGptTextView.layer.shadowColor = UIColor.darkGray.cgColor
        chatGptTextView.layer.shadowOffset = CGSize(width: 0, height: 2)
        chatGptTextView.layer.shadowOpacity = 0.5
        chatGptTextView.layer.shadowRadius = 4
        chatGptTextView.backgroundColor = UIColor(hexCode: "F5F5F4")
        
        chatGptTextView.isScrollEnabled = true
        chatGptTextView.isEditable = false
        chatGptTextView.isSelectable = false
        chatGptTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        chatGptTextView.textContainer.lineFragmentPadding = 0
        chatGptTextView.layoutIfNeeded()
        chatGptTextView.clipsToBounds = true
    }

    func loadData() {
        chatGptTextView.text = gptAnswer
        meLabel.text = myQuestion
    }
    
    func divideDate() {
        if let createDate = createDate {
            let dateFormatter = DateFormatter()
            let dateFormatter2 = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = dateFormatter.date(from: createDate) {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let newDateString = dateFormatter.string(from: date)
                navigationItem.title = newDateString
            } else {
                navigationItem.title = createDate
            }
            
            if let date = dateFormatter2.date(from: createDate) {
                dateFormatter2.dateFormat = "HH:mm:ss"
                let newDateString2 = dateFormatter2.string(from: date)
                hourMinuteSecond.text = newDateString2
                
            } else {
                hourMinuteSecond.text = createDate
            }
        }
    }

}
