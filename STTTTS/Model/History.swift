//
//  History.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/09.
//

import UIKit

struct History {
    var id: String?
    var createDate: String?
    var Details: [Detail]
    
    init(id: String? = nil, createDate: String? = nil, Details: [Detail]) {
        self.id = id
        self.createDate = createDate
        self.Details = Details
    }
}
