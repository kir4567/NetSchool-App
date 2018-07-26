//
//  ReportDetail.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 20.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation

enum ReportType {
    case middleMark, dinamicMiddleMark, reportWithSubjects, parentLetter, undefined
}

class ReportDetails: UIViewController {
    
    var reportVC = Reports()
    var reportType: ReportType = .undefined
    fileprivate var selectedIndex = [0,0]
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAndSetupTableView()
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Далее", style: .done , target: self, action: #selector(getReport))
    }
    
    @objc private func getReport() {
        switch reportType {
        case .middleMark:
            let data = """
            {
            "data" : [
            {
            "id" : "1",
            "subject" : "Russian",
            "mark_of_class" : "1",
            "mark_of_student" : "2"
            },
            {
            "id" : "2",
            "subject" : "English",
            "mark_of_class" : "3",
            "mark_of_student" : "4"
            },
            {
            "id" : "3",
            "subject" : "Biology",
            "mark_of_class" : "5",
            "mark_of_student" : "6"
            }
            ]
            }
            """
            openTableFromJSON(data, name: "CollectionViewControllerMiddleMarks", type: 1)
        case .dinamicMiddleMark:
            if selectedIndex[0] == 0 {
                let data = """
                {
                "data" : [
                {
                "id" : "1",
                "subject" : "Russian",
                "mark_of_class" : "1",
                "mark_of_student" : "2"
                },
                {
                "id" : "2",
                "subject" : "English",
                "mark_of_class" : "3",
                "mark_of_student" : "4"
                },
                {
                "id" : "3",
                "subject" : "Biology",
                "mark_of_class" : "5",
                "mark_of_student" : "6"
                }
                ]
                }
                """
                openTableFromJSON(data, name: "CollectionViewControllerMiddleMarks", type: 1)
            } else {
                let data = """
                {
                "data" : [
                {
                "date" : "13.07",
                "amount_of_student" : "1",
                "mark_of_student" : "2",
                "amount_of_class" : "3",
                "mark_of_class" : "4"
                },
                {
                "date" : "14.07",
                "amount_of_student" : "5",
                "mark_of_student" : "6",
                "amount_of_class" : "7",
                "mark_of_class" : "8"
                },
                {
                "date" : "15.07",
                "amount_of_student" : "9",
                "mark_of_student" : "10",
                "amount_of_class" : "11",
                "mark_of_class" : "12"
                }
                ]
                }
                """
                openTableFromJSON(data, name: "CollectionViewControllerDynamicMiddleMarks", type: 3)
            }
        case .reportWithSubjects:
            let data = """
            {
            "work" : [
            {
            "type" : "Домашняя работа",
            "theme" : "p5, N1:j),m),s),u) + N2:q),w) + N3:c),d)",
            "date" : "12.09.2017",
            "mark" : "3"
            },
            {
            "type" : "Срезовая работа",
            "theme" : "Classwork. To write a frequency table and then to draw frequency histogram and polygon",
            "date" : "12.10.2017",
            "mark" : "5"
            }
            ]
            }
            """
            openTableFromJSON(data, name: "CollectionViewControllerProgressWork", type: 4)
        case .parentLetter:
            let data = """
            {
            "data" : [
            {
            "lesson" : "Russian",
            "mark_info" : [
            {
            "mark" : "8",
            "count" : "4"
            },
            {
            "mark" : "7",
            "count" : "6"
            },
            {
            "mark" : "6",
            "count" : "3"
            },
            {
            "mark" : "5",
            "count" : "8"
            },
            {
            "mark" : "4",
            "count" : "3"
            },
            {
            "mark" : "3",
            "count" : "5"
            },
            {
            "mark" : "2",
            "count" : "0"
            },
            {
            "mark" : "1",
            "count" : "1"
            }
            ],
            "middle" : "7",
            "final" : "5"
            }
            ]
            }
            """
            openTableFromJSON(data, name: "CollectionViewControllerInfoForParents", type: 6)
        default:
            ()
        }
    }
    
    private func createAndSetupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "сell")
        view.addSubview(tableView)
        tableView.addConstraints(view: view, topConstraintConstant: -(navigationController?.navigationBar.frame.height ?? 0))
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
}

extension ReportDetails: UITableViewDelegate, UITableViewDataSource {
    
    private static let middleMarkTitles = ["Итоговые отметки","Срезовые работы","Итоговые отметки и срезовые работы"]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return reportType == .parentLetter ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch reportType {
        case .middleMark, .dinamicMiddleMark: return 3
        case .reportWithSubjects: return 10
        case .parentLetter: return section == 0 ? 2 : 4
        default: ()
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "сell", for: indexPath) as UITableViewCell
        switch reportType {
        case .middleMark, .dinamicMiddleMark:
            cell.textLabel?.text = ReportDetails.middleMarkTitles[indexPath.row]
            
        case .reportWithSubjects:
            let data = ["Алгебра","Биология","Химия","Физика","Английский язык","Физкультура","Литература","Обществознание","История","Русский язык"]
            cell.textLabel?.text = data[indexPath.row]
        case .parentLetter:
            let data = [
                ["Текущие оценки за период","Итоги учебного периода"],
                ["1 четверть","2 четверть","3 четверть","4 четверть"]
            ]
            cell.textLabel?.text = data[indexPath.section][indexPath.row]
        default: ()
        }
        cell.accessoryType = indexPath.row == selectedIndex[indexPath.section] ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch reportType {
//        case .middleMark, .dinamicMiddleMark:
//            let oldIndex = selectedIndex
//            if let cell = tableView.cellForRow(at: IndexPath(row: oldIndex, section: 0)) {
//                cell.accessoryType = .none
//                if oldIndex != indexPath.row {
//                    selectionFeedback()
//                }
//            }
//            if let cell = tableView.cellForRow(at: indexPath) {
//                cell.accessoryType = .checkmark
//            }
//            tableView.deselectSelectedRow
//            selectedIndex = indexPath.row
//        default: ()
//        }
        let oldIndex = selectedIndex[indexPath.section]
        if let cell = tableView.cellForRow(at: IndexPath(row: oldIndex, section: indexPath.section)) {
            cell.accessoryType = .none
            if oldIndex != indexPath.row {
                selectionFeedback()
            }
        }
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        tableView.deselectSelectedRow
        selectedIndex[indexPath.section] = indexPath.row
    }
}


















