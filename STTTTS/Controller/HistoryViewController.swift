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

                                var details: [Detail] = []

                                if let myQuestion = data["myQuestion"] as? String,
                                   let gptAnswer = data["gptAnswer"] as? String {

                                    let detail = Detail(myQuestion: myQuestion, gptAnswer: gptAnswer, DetailReminderDate: nil)
                                    details.append(detail)
                                }

                                let newHistory = History(id: doc.documentID, createDate: createDate, Details: details)
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
            detailVC.createDate = selectedHistory.createDate
            
            
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let historyToDelete = self.historys[indexPath.row]
            guard let docId = historyToDelete.id else {
                print("Document ID not found")
                completionHandler(false)
                return
            }
            if let uid = Auth.auth().currentUser?.uid {
                
                let alertController = UIAlertController(title: "History 삭제", message: "해당 대화를 지우시겠습니까?", preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "확인", style: .default) { (action) in
                    
                    self.db.collection("users").document(uid).collection("history").document(docId).delete { error in
                        if let error = error {
                            print("Error removing document: \(error)")
                        } else {
                            if indexPath.row < self.historys.count {
                                self.historys.remove(at: indexPath.row)
                                self.historyTableView.deleteRows(at: [indexPath], with: .automatic)
                                print("해당 대화가 삭제되었습니다.")
                            }
                            else {
                                print("Warning: Attempting to delete a history out of range.")
                            }
                        }
                    }
                    
                    completionHandler(true)
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in
                    completionHandler(false)
                }
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                completionHandler(false)
            }
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
