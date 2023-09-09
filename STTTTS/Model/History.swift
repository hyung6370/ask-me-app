//
//  History.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/09.
//

import UIKit

struct History {
    var createDate: String?
//    let Details: [Detail] = []
    var Details: [Detail]
    
    init(createDate: String? = nil, Details: [Detail]) {
        self.createDate = createDate
        self.Details = Details
    }
}
