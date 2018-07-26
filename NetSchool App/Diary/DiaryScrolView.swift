//
//  DiaryScrolView.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 04.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation

// MARK: - Diary View Controller
class DiaryViewController: UIViewController {
    
//    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tabScrollView: ACTabScrollView!
    private var (lastWeek, firstWeek) = (false, false)
    fileprivate var (mondays, arrOfWeeks) = ([String](), [String]())
    private var weekDateTime = Date()
    private let secondsInDay = 86400.0
    
    // MARK: - Setup Before Loading Data
    override func viewDidLoad() {
        super.viewDidLoad()
//        bottomConstraint.setBottomConstraint
//        check3DTouch()
        setupDate()
        setupTabScrollView()
        setupNavigationItems()
        //        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor(hex: "e6e6e6")]
        //        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    private func setupNavigationItems() {
        self.navigationItem.rightBarButtonItem = createBarButtonItem(imageName: "weeks", selector: #selector(showWeeks))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let students = getUsers()
        if students.count > 1 {
            self.navigationItem.leftBarButtonItem = createBarButtonItem(imageName: "users", selector: #selector(showUsers))
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc private func showUsers(sender: AnyObject) {
        selectUsers(sender, self)
    }
    
    private func setupDate() {
        let currentDateTime = Date()
        let userCalendar = Calendar.current as NSCalendar
        let weekDay = Double(-(userCalendar.components(.weekday, from: currentDateTime).weekday! - 2))
        /*
         Пояснение к предыдущей строчке:
         .weekday возвращает число от 1 до 7, где 1 - воскресенье, 2 - понедельник и тд.
         По формуле -1*(weekday - 2) получаем расстояние до понедельника этой недели (В случае воскресенья - следующей)
         */
        weekDateTime = currentDateTime.addingTimeInterval(secondsInDay*weekDay)
        let components = userCalendar.components([.day, .month, .year], from: weekDateTime.addingTimeInterval(secondsInDay*7))
        let nextWeekMonth = String(describing: components.month)
        let nextWeekDay = String(describing: components.day)
        let currentMonth = String(describing: userCalendar.components([.month], from: currentDateTime).month)
        if currentMonth == "9" && Int(nextWeekDay)! < 8 && nextWeekMonth == "9" {
            _ = getWeek(0)
            firstWeek = true
        } else {
            while !firstWeek { _ = getWeek(-7*secondsInDay) }
            self.weekDateTime = currentDateTime.addingTimeInterval(secondsInDay*weekDay)
            self.weekDateTime =  weekDateTime.addingTimeInterval(-secondsInDay*7)
        }
        while !lastWeek { _ = getWeek(7*secondsInDay) }
        self.weekDateTime = currentDateTime.addingTimeInterval(secondsInDay*weekDay)
        let currentWeek = getWeek(0)
        tabScrollView.localWeek = 0
        var weekIndex = 0
        for week in arrOfWeeks {
            let monday = week[week.startIndex..<(week.range(of: " ")?.lowerBound)!]
            if currentWeek == monday {
                tabScrollView.localWeek = weekIndex
            }
            mondays.append(String(monday))
            weekIndex += 1
        }
    }
    
    private func getWeek(_ time:Double) -> String {
        let calendar = Calendar.current as NSCalendar
        weekDateTime = weekDateTime.addingTimeInterval(time)
        let components = calendar.components([.day , .month , .year], from: weekDateTime)
        let year =  String(describing: components.year!)
        let month = String(describing: components.month!)
        let day = String(describing: components.day!)
        var add = time
        add += time < 0 ? 13*secondsInDay : time == 0 ? 6*secondsInDay : -secondsInDay
        let weekDateTime1 = weekDateTime.addingTimeInterval(add)
        let components1 = calendar.components([.day , .month , .year], from: weekDateTime1)
        let year1 =  String(describing: components1.year!)
        let month1 = String(describing: components1.month!)
        let day1 = String(describing: components1.day!)
        let text = "\(day).\(month).\(year) - \(day1).\(month1).\(year1)"
        if components.day! > 25 && components.month! == 8 && !firstWeek || components.day! == 1 && components.month! == 9 && !firstWeek {
            firstWeek = true
            self.arrOfWeeks.insert(text, at: 0)
        } else if components.day! > 24 && components.month! == 8 && firstWeek {
            self.arrOfWeeks.append(text)
            lastWeek = true
            if arrOfWeeks.count > 1 && arrOfWeeks[0].range(of: text) != nil {
                arrOfWeeks.removeLast()
            }
        }
        if !self.firstWeek {
            self.arrOfWeeks.insert(text, at: 0)
        } else if !self.lastWeek {
            self.arrOfWeeks.append(text)
            if arrOfWeeks.count > 1 && arrOfWeeks[0].range(of: text) != nil {
                arrOfWeeks.removeLast()
            }
        }
        return day + "." + month + "." + year
    }
    
    @objc private func showWeeks(sender: AnyObject) {
        guard let sender = sender as? UIView else { return }
        let 🚨 = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for index in 0..<arrOfWeeks.count {
            let action = UIAlertAction(title: "\(arrOfWeeks[index]) : \(index+1)", style: .default) { _ in
                if self.tabScrollView.localWeek != index {
                    self.tabScrollView.localWeek = index
                    self.tabScrollView.permission = false
                    self.tabScrollView.changePageToIndex(index, animated: false)
                }
            }
            action.setValue(self.tabScrollView.localWeek == index, forKey: "checked")
            🚨.addAction(action)
        }
        if let presenter = 🚨.popoverPresentationController {
            presenter.sourceView = sender
            presenter.sourceRect = sender.bounds
        }
        🚨.view.tintColor = UIColor(red: 74/255, green: 88/255, blue: 94/255, alpha: 1)
        🚨.addCancelAction
        🚨.popoverPresentationController?.permittedArrowDirections = .up
        self.present(🚨)
    }
    
    private func setupTabScrollView() {
        tabScrollView.defaultPage = tabScrollView.localWeek
        tabScrollView.arrowIndicator = true
        tabScrollView.cachedPageLimit = 10
        tabScrollView.delegate = self
        tabScrollView.dataSource = self
        tabScrollView.backgroundColor = .blue
    }
}

// MARK: - TAB SCROLL VIEW
extension DiaryViewController: ACTabScrollViewDelegate, ACTabScrollViewDataSource {
    func tabScrollView(_ tabScrollView: ACTabScrollView, didChangePageTo index: Int) {
        tabScrollView.localWeek = index
    }
    func tabScrollView(_ tabScrollView: ACTabScrollView, didScrollPageTo index: Int) {}
    func numberOfPagesInTabScrollView(_ tabScrollView: ACTabScrollView) -> Int { return arrOfWeeks.count }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, tabViewForPageAtIndex index: Int) -> UIView {
        return createTapBarLabel(text: arrOfWeeks[index])
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, contentViewForPageAtIndex index: Int) -> UIView {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DiaryContentViewController") as! DiaryContentViewController
        viewController.weekToLoad = mondays[index]
        addChildViewController(viewController)
        if index == tabScrollView.localWeek {
            // button week select
            tabScrollView.permission = true
        } else if tabScrollView.permission {
            // scroll select
        } else {
            viewController.haveLoadPermission = false
        }
        return viewController.view
    }
}

// MARK: - DIARY GESTURE RECOGNIZER
extension DiaryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

extension UIViewController {
    func present(_ viewController: UIViewController) {
        self.present(viewController, animated: true)
    }
}
