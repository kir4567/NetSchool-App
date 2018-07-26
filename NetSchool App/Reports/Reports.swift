//
//  Reports.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 29.06.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import UIKit

class Reports: UIViewController {
    @IBOutlet var tableView: UITableView!
    let titles = ["Итоговые отметки","Средний балл","Динамика среднего балла","Отчет об успеваемости","Отчет об успеваемости и посещаемости","Отчет о доступе к классному журналу","Информационное письмо для родителей"]
    fileprivate static let fullMonths = ["января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноября", "декабря"]
    fileprivate var (start, end) = (Date(), Date())
    fileprivate var (staticStart, staticEnd) = (Date(), Date())
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dates = Reports.getADTandDDT()
        staticStart = dateFormatter.date(from: dates.ADT)!
        staticEnd = dateFormatter.date(from: dates.DDT)!
        start = staticStart
        end = staticEnd
    }
    
    private static func getADTandDDT() -> (ADT: String, DDT: String) {
        let (date, calendar) = (Date(), Calendar.current)
        let (year, month) = (calendar.component(.year, from: date), calendar.component(.month, from: date))
        if month < 9 {
            return ("01.09.\(year - 1)", "31.05.\(year)")
        }
        return ("01.09.\(year)", "31.05.\(year + 1)")
    }
    
    @objc private func showUsers(sender: AnyObject) {
        selectUsers(sender, self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let students = getUsers()
        if students.count > 1 {
            self.navigationItem.leftBarButtonItem = createBarButtonItem(imageName: "users", selector: #selector(showUsers))
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
}

extension Reports: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReportsDateCell
            cell.titleLabel.text = indexPath.row == 0 ? "Начало" : "Конец"
            cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0)
            let date = indexPath.row == 0 ? start : end
            let calendar = Calendar.current
            let (year, month, day) = (calendar.component(.year, from: date), calendar.component(.month, from: date), calendar.component(.day, from: date))
            cell.dateLabel.text = "\(day) \(Reports.fullMonths[month-1]) \(year) г."
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! ReportsCell
        cell.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0)
        cell.titleLabel.text = titles[indexPath.row]
        cell.icon.image = UIImage(named: "report\(indexPath.row+1)")!
        cell.icon.image = cell.icon.image?.withRenderingMode(.alwaysTemplate)
        cell.icon.tintColor = UIColor(hex: "A7A7A7")
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Период" : "Отчеты"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 60 : 44
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let datePickerViewController = AIDatePickerController.picker(with: indexPath.row == 0 ? start : end, start: staticStart, end: staticEnd, selectedBlock: { selectedDate in
                if indexPath.row == 0 {
                    self.start = selectedDate ?? Date()
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                } else {
                    self.end = selectedDate ?? Date()
                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                }
                print(self.dateFormatter.string(from: selectedDate ?? Date()))
                tableView.deselectSelectedRow
                self.dismiss(animated: true)
            }, cancel: {
                tableView.deselectSelectedRow
                self.dismiss(animated: true)
            })
            present(datePickerViewController as! UIViewController, animated: true)
        } else {
            
            switch indexPath.row {
            case 0:
                let data = """
                {
                "table" : [
                {
                "subject": "Испанский язык",
                "period1": "6",
                "period2": "7",
                "period3": "7",
                "period4": "7",
                "year": "7",
                "exam": "",
                "final": ""
                },
                {
                "subject": "Физическая культура",
                "period1": "7",
                "period2": "7",
                "period3": "5",
                "period4": "7",
                "year": "7",
                "exam": "",
                "final": ""
                },
                {
                "subject": "Английский язык",
                "period1": "5",
                "period2": "5",
                "period3": "4",
                "period4": "6",
                "year": "5",
                "exam": "",
                "final": ""
                },
                {
                "subject": "Информатика и ИКТ",
                "period1": "3",
                "period2": "4",
                "period3": "",
                "period4": "4",
                "year": "4",
                "exam": "",
                "final": ""
                },
                {
                "subject": "Литература",
                "period1": "4",
                "period2": "4",
                "period3": "4",
                "period4": "4",
                "year": "4",
                "exam": "",
                "final": "4"
                },
                {
                "subject": "Русский язык",
                "period1": "4",
                "period2": "4",
                "period3": "4",
                "period4": "3",
                "year": "3",
                "exam": "",
                "final": "3"
                },
                {
                "subject": "Алгебра",
                "period1": "4",
                "period2": "5",
                "period3": "5",
                "period4": "5",
                "year": "5",
                "exam": "",
                "final": "5"
                },
                {
                "subject": "Геометрия",
                "period1": "6",
                "period2": "5",
                "period3": "6",
                "period4": "",
                "year": "5",
                "exam": "",
                "final": "5"
                },
                {
                "subject": "Биология",
                "period1": "6",
                "period2": "5",
                "period3": "3",
                "period4": "4",
                "year": "4",
                "exam": "",
                "final": ""
                },
                {
                "subject": "География",
                "period1": "6",
                "period2": "5",
                "period3": "6",
                "period4": "",
                "year": "5",
                "exam": "",
                "final": "5"
                },
                {
                "subject": "Физика",
                "period1": "5",
                "period2": "4",
                "period3": "5",
                "period4": "5",
                "year": "4",
                "exam": "",
                "final": "4"
                },
                {
                "subject": "История",
                "period1": "6",
                "period2": "6",
                "period3": "5",
                "period4": "5",
                "year": "5",
                "exam": "",
                "final": ""
                },
                {
                "subject": "ИЗО",
                "period1": "7",
                "period2": "7",
                "period3": "7",
                "period4": "7",
                "year": "6",
                "exam": "",
                "final": ""
                },
                {
                "subject": "Музыка",
                "period1": "7",
                "period2": "7",
                "period3": "6",
                "period4": "7",
                "year": "7",
                "exam": "",
                "final": ""
                },
                {
                "subject": "Дизайн",
                "period1": "4",
                "period2": "7",
                "period3": "6",
                "period4": "7",
                "year": "6",
                "exam": "",
                "final": ""
                }
                ]}
                """
                openTableFromJSON(data, name: "CollectionViewControllerFinalMarks", type: 0)
            case 1:
                let detailVC = ReportDetails()
                detailVC.reportVC = self
                detailVC.reportType = .middleMark
                show(detailVC)
            case 2:
                let detailVC = ReportDetails()
                detailVC.reportVC = self
                detailVC.reportType = .dinamicMiddleMark
                show(detailVC)
            case 3:
                let detailVC = ReportDetails()
                detailVC.reportVC = self
                detailVC.reportType = .reportWithSubjects
                show(detailVC)
            case 4:
                let data = """
                {
                "table": {
                "months": [
                {
                "name": "April",
                "days": [
                {
                "number": "1",
                "subjects": [
                {
                "name": "Math",
                "marks": [ "1", "2", "3", "M"]
                },
                {
                "name": "Russian",
                "marks": [ "1", "2", "3", "R"]
                },
                {
                "name": "English",
                "marks": [ "1", "2", "3", "E"]
                }
                ]
                },
                {
                "number": "2",
                "subjects": [
                {
                "name": "France",
                "marks": [ "1", "2", "3", "F"]
                },
                {
                "name": "Chem",
                "marks": [ "1", "2", "3", "C"]
                },
                {
                "name": "Geogr",
                "marks": [ "1", "2", "3", "G"]
                }
                ]
                },
                {
                "number": "3",
                "subjects": [
                {
                "name": "Sport",
                "marks": [ "1", "2", "3", "S"]
                },
                {
                "name": "Box",
                "marks": [ "1", "2", "3", "B"]
                },
                {
                "name": "Fuck",
                "marks": [ "1", "2", "3", "Fu"]
                }
                ]
                }
                ]
                },
                {
                "name": "May",
                "days": [
                {
                "number": "1",
                "subjects": [
                {
                "name": "Math",
                "marks": [ "1", "2", "3", "M"]
                },
                {
                "name": "Russian",
                "marks": [ "1", "2", "3", "R"]
                },
                {
                "name": "English",
                "marks": [ "1", "2", "3", "E"]
                }
                ]
                },
                {
                "number": "2",
                "subjects": [
                {
                "name": "France",
                "marks": [ "1", "2", "3", "F"]
                },
                {
                "name": "Chem",
                "marks": [ "1", "2", "3", "C"]
                },
                {
                "name": "Geogr",
                "marks": [ "1", "2", "3", "G"]
                }
                ]
                },
                {
                "number": "3",
                "subjects": [
                {
                "name": "Sport",
                "marks": [ "1", "2", "3", "S"]
                },
                {
                "name": "Box",
                "marks": [ "1", "2", "3", "B"]
                },
                {
                "name": "Fuck",
                "marks": [ "1", "2", "3", "Fu"]
                }
                ]
                }
                ]
                }
                ],
                "average_marks": [
                {
                "name": "string",
                "mark": "number|undefined"
                }
                ]
                }
                }
                """
                openTableFromJSON(data, name: "CollectionViewControllerBigJournal", type: 7)
            case 5:
                let data = """
                {
                "line" : [
                {
                "class_number" : "7",
                "lesson" : "Алгебра",
                "date_time" : "24.05.2018 19:31",
                "user" : "Лендьел Ф.И.",
                "info" : "24.04.2018,08.05.2018",
                "period" : "3 четверть",
                "type" : "ИО"
                },
                {
                "class_number" : "7",
                "lesson" : "Геометрия",
                "date_time" : "24.05.2018 19:31",
                "user" : "Швец Е.А",
                "info" : "24.04.2018,08.05.2018",
                "period" : "5 четверть",
                "type" : "ПТ"
                }
                ]
                }
                """
                openTableFromJSON(data, name: "CollectionViewControllerPermissionToJournal", type: 5)
            case 6:
                let detailVC = ReportDetails()
                detailVC.reportVC = self
                detailVC.reportType = .parentLetter
                show(detailVC)
            default: ()
            }
            tableView.deselectSelectedRow
        }
    }
}

class ReportsDateCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

class ReportsCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}
