//
//  HistoryViewController.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/08.
//

import UIKit
import Firebase

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var semiTitleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var historyTableView: UITableView!
    
    let db = Firestore.firestore()
    
    var historys: [History] = []
//    var details: [
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "History"
        
        historyTableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        configureUI()
        loadHistory()
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
    
//    func loadHistory() {
//        if let uid = Auth.auth().currentUser?.uid {
//            db.collection("users").document(uid).collection("history").order(by: "createDate", descending: true).addSnapshotListener { (querySnapshot, error) in
//                if let e = error {
//                    print("History loading failed: \(e.localizedDescription)")
//                } else {
//                    self.historys = []
//                    if let snapshotDocuments = querySnapshot?.documents {
//                        for doc in snapshotDocuments {
//                            let data = doc.data()
//                            if let createDate = data["createDate"] as? String {
//                                let newHistory = History(createDate: createDate)
//
//                                self.historys.append(newHistory)
//                            }
//                        }
//                        DispatchQueue.main.async {
//                            self.historyTableView.reloadData()
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func loadHistory() {
        if let uid = Auth.auth().currentUser?.uid {
            db.collection("users").document(uid).collection("history").order(by: "createDate", descending: true).addSnapshotListener { (querySnapshot, error) in
                if let e = error {
                    print("History loading failed: \(e.localizedDescription)")
                } else {
                    self.historys = []
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let createDate = data["createDate"] as? String {
                                
                                // 여기서 Detail 정보를 불러와야 합니다.
                                // 예를 들면:
                                var details: [Detail] = []
                                
                                if let myQuestion = data["myQuestion"] as? String,
                                   let gptAnswer = data["gptAnswer"] as? String {
                                    // DetailReminderDate 를 불러오려면 데이터베이스에 해당 필드가 있어야 합니다.
                                    let detail = Detail(myQuestion: myQuestion, gptAnswer: gptAnswer, DetailReminderDate: nil)
                                    details.append(detail)
                                }

                                let newHistory = History(createDate: createDate, Details: details)
                                self.historys.append(newHistory)
                            }
                        }
                        DispatchQueue.main.async {
                            self.historyTableView.reloadData()
                        }
                    }
                }
            }
        }
    }

}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryTableViewCell
        
        let history = historys[indexPath.row]

        guard let createDateStr = history.createDate else {
            return cell
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let createDate = formatter.date(from: createDateStr) else {
            return cell
        }
        
        formatter.dateFormat = "yyyy-MM-dd"
        cell.yearMonthDay.text = formatter.string(from: createDate)
        
        formatter.dateFormat = "HH:mm:ss"
        cell.hourMinuteSecond.text = formatter.string(from: createDate)
        
        return cell
    }
}

extension HistoryViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController {
            
            let selectedHistory = historys[indexPath.row]
            detailVC.gptAnswer = selectedHistory.Details.first?.gptAnswer
            detailVC.myQuestion = selectedHistory.Details.first?.myQuestion
            
            
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
