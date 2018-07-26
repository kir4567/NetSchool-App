//
//  Diary.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 29.06.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import UIKit
import JavaScriptCore

class DiaryContentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var haveLoadPermission = true
    var days = [JournalDay]()
    var weekToLoad: String?
    private var (PCLID, refreshControl) = ("", UIRefreshControl())
    var status: Status = .loading
    private var goToLogin = false
    var actionIndexPath = IndexPath(row: 0, section: 0)
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
        days.append(JournalDay(date: "15.03.2018, Чт"))
        days[0].append(lesson: JournalLesson(data: ["Французский язык", "В", "Контроль навыков монологической речи - С (ii, iii, iv)", "-"], inTime: true, key: ""))
        
        days.append(JournalDay(date: "18.05.2018, Пт"))
        days[1].append(lesson: JournalLesson(data: ["Литература", "Д", "Автобиография", "-"], inTime: false, key: ""))
        days[1].append(lesson: JournalLesson(data: ["Алгебра", "А", "Огэ вариант 12", "5"], inTime: false, key: ""))
        days[1].append(lesson: JournalLesson(data: ["Русский язык", "Ч", "Пишем диагностическое сочинение", "4"], inTime: false, key: "мсими"))
        days.append(JournalDay(date: "20.03.2018, Вт"))
        days[2].append(lesson: JournalLesson(data: ["История", "О", "Николай первый", "5"], inTime: false, key: ""))
        days[2].append(lesson: JournalLesson(data: ["Французский язык", "Д", "Досмотреть фильм \"Крамер против Крамера\"", "-"], inTime: false, key: ""))
        days[2].append(lesson: JournalLesson(data: ["Информатика", "Д", "Учить теорию, см файл.", "-"], inTime: false, key: "5п5"))
        days.append(JournalDay(date: "21.03.2018, Ср"))
        days[3].append(lesson: JournalLesson(data: ["География", "О", "Смотрите задание на прошлый урок", "-"], inTime: false, key: ""))
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(loadData), for:  .valueChanged)
        tableView.addSubview(refreshControl)
        automaticallyAdjustsScrollViewInsets = false
//        bottomConstraint.setBottomConstraint
    }
    
    @objc private func loadData() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? Details,
            let indexPath = self.tableView.indexPathForSelectedRow {
            destination.lesson = days[indexPath.section].getLesson(indexPath.row)
            destination.fullDate = days[indexPath.section].fullDate
            destination.detailType = .diary
            destination.diaryVC = self
        }
    }
    
}

// MARK: - DIARY TABLE VIEW
extension DiaryContentViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: TABLE VIEW SETUP
    func numberOfSections(in tableView: UITableView) -> Int { return days.isEmpty ? 1 : days.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return days.isEmpty ? 0 : days[section].count() }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DiaryCell
        let lesson = days[indexPath.section].getLesson(indexPath.row)
        let typeColor = lesson.color
        cell.StateIcon.isHidden = false
        if lesson.inTime {
            cell.StateIcon.image = UIImage(named: "warn")
            cell.StateIcon.setImageBackgroundColor(UIColor(red: 219/255, green: 45/255, blue: 69/255, alpha: 1))
            cell.SubjectLabelConstraint.constant = 33
        } else {
            
            // Это все будем переписывать так как будет облачная синхронизация
//            let def = UserDefaults.standard
            if lesson.key != "" { //def.value(forKey: lesson.key) == nil
                cell.SubjectLabelConstraint.constant = 33
                cell.StateIcon.image = UIImage(named: "dot")
                cell.StateIcon.setImageBackgroundColor(typeColor)
            } else  { //if def.bool(forKey: lesson.key)
                if lesson.homework && (indexPath.section == 1 || indexPath.row == 1) {
                    cell.SubjectLabelConstraint.constant = 33
                    cell.StateIcon.image = UIImage(named: "done")
                    cell.StateIcon.setImageBackgroundColor(typeColor)
                } else {
                    cell.StateIcon.isHidden = true
                    cell.SubjectLabelConstraint.constant = 11
                }
                
            }
//            else {
//                cell.StateIcon.isHidden = true
//                cell.SubjectLabelConstraint.constant = 11
//            }
        }
        cell.DateLabel.text = " \(days[indexPath.section].date) "
        cell.DateLabel.layer.cornerRadius = 3
        cell.DateLabel.layer.masksToBounds = true
        cell.setSelection
        cell.SubjectLabel.text = lesson.subject
        cell.ExplainLabel.text = lesson.task
        cell.MarkLabel.text = lesson.mark
        cell.typeLine.backgroundColor = typeColor
        cell.typeLine.layer.backgroundColor = typeColor.cgColor
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectSelectedRow
        performSegue(withIdentifier: "details")
    }
    
    //MARK: HEADER
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return section < days.count ? days[section].sectionDate : "" }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor(hex: "39393a") //.schemeTintColor
        headerView.textLabel?.font = UIFont.systemFont(ofSize: 15)
        let borderBottom = CALayer(), borderTop = CALayer()
        let width = CGFloat(0.5)
        borderBottom.borderColor = UIColor.lightGray.withAlphaComponent(0.55).cgColor
        borderTop.borderColor = UIColor.lightGray.withAlphaComponent(0.55).cgColor
        borderBottom.frame = CGRect(x: 0, y: headerView.frame.size.height - width, width:  headerView.frame.size.width, height: 0.5)
        borderTop.frame = CGRect(x: 0, y: 0, width:  headerView.frame.size.width, height: 0.5)
        borderBottom.borderWidth = width
        borderTop.borderWidth = width
        headerView.layer.addSublayer(borderBottom)
        headerView.layer.addSublayer(borderTop)
        headerView.layer.masksToBounds = true
    }
    
    //MARK: FOOTER
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return days.isEmpty ? 35 : 0 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard days.isEmpty else { return nil }
        switch status {
        case .loading: return self.view.loadingFooterView()
        case .error: return self.view.errorFooterView()
        default:
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 23))
            footerView.backgroundColor = UIColor.clear
            let footerLabel = UILabel(frame: CGRect(x: 0, y: 7, width: tableView.frame.size.width, height: 23))
            footerLabel.addProperties
            footerLabel.text = status == .successful ? "Заданий нет" : "Загрузка прервана"
            footerView.addSubview(footerLabel)
            return footerView
        }
    }
}

//MARK: - 3D Touch peek and pop
extension DiaryContentViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if #available(iOS 9.0, *) {
            guard let indexPath = tableView.indexPathForRow(at: location),
                let cell = tableView.cellForRow(at: indexPath),
                let detailVC = storyboard?.instantiateViewController(withIdentifier: "Details") as? Details else { return nil }
            actionIndexPath = indexPath
            detailVC.lesson = days[indexPath.section].getLesson(indexPath.row)
            detailVC.fullDate = days[indexPath.section].fullDate
            detailVC.detailType = .diary
            detailVC.diaryVC = self
            previewingContext.sourceRect = cell.frame
            return detailVC
        }
        return nil
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit)
    }
}

class DiaryCell: UITableViewCell {
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let (color1, color2, color3) = (typeLine.backgroundColor, DateLabel.backgroundColor, StateIcon.backgroundColor)
        super.setSelected(selected, animated: animated)
        (typeLine.backgroundColor, DateLabel.backgroundColor, StateIcon.backgroundColor)  = (color1, color2, color3)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let (color1, color2, color3) = (typeLine.backgroundColor, DateLabel.backgroundColor, StateIcon.backgroundColor)
        super.setHighlighted(highlighted, animated: animated)
        (typeLine.backgroundColor, DateLabel.backgroundColor, StateIcon.backgroundColor)  = (color1, color2, color3)
    }
    
    @IBOutlet weak var SubjectLabel: UILabel!
    @IBOutlet weak var ExplainLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var MarkLabel: UILabel!
    @IBOutlet weak var typeLine: UIImageView!
    @IBOutlet weak var StateIcon: UIImageView!
    @IBOutlet weak var SubjectLabelConstraint: NSLayoutConstraint!
}

// MARK: - JournalDay
class JournalDay {
    private var lessons: [JournalLesson]
    let date, sectionDate, fullDate: String
    private static let fullMonths = ["января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноября", "декабря"]
    private static let namesOfWeeks = ["Пн": "ПОНЕДЕЛЬНИК", "Вт": "ВТОРНИК", "Ср": "СРЕДА", "Чт": "ЧЕТВЕРГ", "Пт": "ПЯТНИЦА", "Сб": "СУББОТА", "Вс": "ВОСКРЕСЕНЬЕ"]
    
    init(date: String) {
        lessons = [JournalLesson]()
        var components = date.components(separatedBy: ".")
        if components.count == 3 {
            if components[0][components[0].startIndex] == "0" { components[0].remove(at: components[0].startIndex) }
            let weekDay = components[2].components(separatedBy: " ").last!
            let index = Int(components[1])! - 1
            let date = JournalDay.fullMonths[index]
            self.date = "\(components[0]) \(date[..<date.index(date.startIndex, offsetBy: 3)]), \(weekDay)"
            sectionDate = JournalDay.namesOfWeeks[weekDay]!
            fullDate = "\(JournalDay.namesOfWeeks[weekDay]!.lowercased()), \(components[0]) \(JournalDay.fullMonths[index])"
        } else {
            self.date = "Неизвестная дата"
            sectionDate = self.date
            fullDate = self.date
        }
    }
    
    func append(lesson: JournalLesson) { lessons.append(lesson) }
    func count() -> Int { return lessons.count }
    func getLesson(_ index: Int) -> JournalLesson { return lessons[index] }
}

// MARK: - JournalLesson
class JournalLesson {
    let subject, mark, task, workType, key, fullWorkType :String
    let inTime, homework :Bool
    let color :UIColor
    
    init(data: [String], inTime: Bool, key: String) {
        (subject, workType, task, mark, self.key, homework) = (data[0], data[1], data[2].capitalizeFirst, data[3] == "-" ? "" : data[3], key, data[1] == "Д")
        switch data[1] {
        case "Д": fullWorkType = "Домашняя работа"
        color = UIColor(red: 228/255, green: 117/255, blue: 62/255, alpha: 1)
        case "О": fullWorkType = "Ответ на уроке"
        color = UIColor(red: 0, green: 170/255, blue: 150/255, alpha: 1)
        case "В": fullWorkType = "Срезовая работа"
        color = UIColor(red: 219/255, green: 45/255, blue: 69/255, alpha: 1)
        case "Л": fullWorkType = "Лабораторная работа"
        color = UIColor(red: 140/255, green: 97/255, blue: 166/255, alpha: 1)
        case "Н": fullWorkType = "Диктант"
        color = UIColor(red: 175/255, green: 192/255, blue: 108/255, alpha: 1)
        case "З": fullWorkType = "Зачет"
        color = UIColor(red: 60/255, green: 91/255, blue: 114/255, alpha: 1)
        case "П": fullWorkType = "Проект"
        color = UIColor(red: 226/255, green: 174/255, blue: 12/255, alpha: 1)
        case "Ч": fullWorkType = "Сочинение"
        color = UIColor(red: 31/255, green: 175/255, blue: 208/255, alpha: 1)
        case "Т": fullWorkType = "Тестирование"
        color = UIColor(red: 39/255, green: 72/255, blue: 69/255, alpha: 1)
        case "К": fullWorkType = "Контрольная работа"
        color = UIColor(red: 219/255, green: 45/255, blue: 69/255, alpha: 1)
        case "И": fullWorkType = "Изложение"
        color = UIColor(red: 100/255, green: 34/255, blue: 40/255, alpha: 1)
        case "С": fullWorkType = "Самостоятельная работа"
        color = UIColor(red: 219/255, green: 45/255, blue: 69/255, alpha: 1)
        case "Р": fullWorkType = "Реферат"
        color = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        case "А": fullWorkType = "Практическая работа"
        color = UIColor(red: 177/255, green: 179/255, blue: 215/255, alpha: 1)
        default: fullWorkType = "Неизвестно"
        color = .black
        }
        self.inTime = inTime
    }
}
