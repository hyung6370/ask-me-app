//
//  Detail.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/09.
//

import UIKit

struct Detail {
    var myQuestion: String?
    var gptAnswer: String?
    var DetailReminderDate: String?
    
    init(myQuestion: String? = nil, gptAnswer: String? = nil, DetailReminderDate: String? = nil) {
        self.myQuestion = myQuestion
        self.gptAnswer = gptAnswer
        self.DetailReminderDate = DetailReminderDate
    }
}
