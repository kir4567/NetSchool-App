//
//  TableData.swift
//  NetSchool App
//
//  Created by Arthur on 13.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
class TableData{
    var countOfSections:Int
    var countOfRows:Int
    var data:[[String]]
    init(countOfSections:Int, countOfRows:Int, data:[[String]]) {
        self.countOfRows = countOfRows
        self.countOfSections = countOfSections
        self.data = data
    }
}
