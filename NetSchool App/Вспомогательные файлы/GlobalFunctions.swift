//
//  GlobalFunctions.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 04.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation

// MARK: - Colors


func isSchemeLight() -> Bool {
    return darkSchemeColor().isWhiteText
}

func darkSchemeColor(key: Int) -> UIColor {
    guard key < Settings.colorsHEXs.count else {
//        setInt(forKey: "Color", val: 1)
        return UIColor.init(hex: Settings.colorsHEXs[1])
    }
    return UIColor.init(hex: Settings.colorsHEXs[key])
}

func lightSchemeColor() -> UIColor {
    let color = darkSchemeColor()
    let red = color.redValue
    let green = color.greenValue
    let blue = color.blueValue
    let minimum = min(min(red, green),blue)
    let maximum = max(max(red, green),blue)
    let luminance = ((minimum + maximum) / 2) * 0.85
    let saturation = minimum == maximum ? 0 : luminance < 0.5 ? (maximum-minimum)/(maximum+minimum) : (maximum-minimum)/(2.0-maximum-minimum)
    let hue = (red == maximum ? (green-blue)/(maximum-minimum) : green == maximum ? 2.0 + (blue-red)/(maximum-minimum) : 4.0 + (red-green)/(maximum-minimum))/6
    guard saturation != 0  else { return UIColor(red: luminance, green: luminance, blue: luminance, alpha: 1) }
    let t1 = luminance < 0.5 ? luminance * (1.0+saturation) : luminance + saturation - luminance * saturation
    let t2 = 2 * luminance - t1
    var tr = hue + 1/3
    var tg = hue
    var tb = hue - 1/3
    while tr < 0 { tr += 1 }
    while tr > 1 { tr -= 1 }
    while tg < 0 { tg += 1 }
    while tg > 1 { tg -= 1 }
    while tb < 0 { tb += 1 }
    while tb > 1 { tb -= 1 }
    func test(_ temporary: CGFloat) -> CGFloat {
        if 6 * temporary < 1 { return t2 + (t1 - t2) * 6 * temporary }
        if 2 * temporary < 1 { return t1 }
        if 3 * temporary < 2 { return t2 + (t1 - t2) * (2/3 - temporary) * 6 }
        return t2
    }
    return UIColor(red: test(tr), green: test(tg), blue: test(tb), alpha: 1)
}

func darkSchemeColor() -> UIColor {
    return UIColor.init(hex: Settings.colorsHEXs[getColor()])
}

func selectUsers(_ sender: AnyObject, _ viewController: UIViewController) {
    let 🚨 = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let selectedUser = getFirstUser()
    for child in getUsers() {
        let action = UIAlertAction(title: child.username, style: .default) { _ in
            setFirstUser(child.id)
        }
        action.setValue(child.id == selectedUser, forKey: "checked")
        🚨.addAction(action)
    }
    if let presenter = 🚨.popoverPresentationController {
        presenter.sourceView = sender as? UIView
        presenter.sourceRect = sender.bounds
    }
    🚨.view.tintColor = UIColor(red: 74/255, green: 88/255, blue: 94/255, alpha: 1)
    🚨.addCancelAction
    🚨.popoverPresentationController?.permittedArrowDirections = .up
    viewController.present(🚨)
}

func getColor() -> Int {
    let key = UserDefaults.standard.object(forKey: "Color") as? Int ?? 5
    guard key < Settings.colorsHEXs.count else {
        setInt(forKey: "Color", val: 5)
        return 5
    }
    return key
}

func setInt(forKey: String, val: Int) {
    let defaults = UserDefaults.standard
    defaults.set(val, forKey: forKey)
    defaults.synchronize()
}

func setBool(forKey: String, val: Bool) {
    let defaults = UserDefaults.standard
    defaults.set(val, forKey: forKey)
    defaults.synchronize()
}

func getInt(forKey key: String) -> Int {
    return UserDefaults.standard.object(forKey: key) as? Int ?? 0
}

func createTapBarLabel(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.textColor = UIColor(red: 77.0 / 255, green: 79.0 / 255, blue: 84.0 / 255, alpha: 1)
    label.sizeToFit()
    label.frame.size = CGSize(width: label.frame.size.width + 28, height: label.frame.size.height + 36)
    return label
}

// MARK: - Login and ChangePassword funcs

func animation(textfield: UITextField, duration: TimeInterval, delay: TimeInterval, const: CGFloat) {
    UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
        textfield.center.x += const
    }, completion: nil)
}

/**
 Dangles textField
 - parameter textfield: Text Field to dangle
 */
func dangle(textfield: UITextField) {
    animation(textfield: textfield, duration: 0.05, delay: 0, const: 3)
    animation(textfield: textfield, duration: 0.05, delay: 0.05, const: -3)
    animation(textfield: textfield, duration: 0.04, delay: 0.1, const: 2)
    animation(textfield: textfield, duration: 0.04, delay: 0.14, const: -2)
    animation(textfield: textfield, duration: 0.03, delay: 0.18, const: 1.2)
    animation(textfield: textfield, duration: 0.03, delay: 0.21, const: -1.2)
}

func selectionFeedback() {
    if #available(iOS 10.0, *) {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

func impactFeedback() {
    if #available(iOS 10.0, *) {
        UIImpactFeedbackGenerator().impactOccurred()
    }
}

func successFeedback() {
    if #available(iOS 10.0, *) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

func errorFeedback() {
    if #available(iOS 10.0, *) {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

/// Converts date from Mail and Posts into readable expression
func cleverDate(_ date: String) -> String {
    guard let yearRange = date.range(of: "(\\d\\d\\d\\d)", options: .regularExpression),
        let year = Int(date[yearRange]),
        let monthRange = date.range(of: "(?<=.)(\\d\\d)(?=.)", options: .regularExpression),
        let month = Int(date[monthRange]),
        let dayRange = date.range(of: "(\\d\\d)(?=.)", options: .regularExpression),
        let day = Int(date[dayRange]),
        (NSCalendar.current as NSCalendar).components([.year], from: Date()).year == year else { return date }
    var monthName = ""
    switch month {
    case 1: monthName = "Янв"
    case 2: monthName = "Фев"
    case 3: monthName = "Мар"
    case 4: monthName = "Апр"
    case 5: monthName = "Мая"
    case 6: monthName = "Июн"
    case 7: monthName = "Июл"
    case 8: monthName = "Авг"
    case 9: monthName = "Сен"
    case 10: monthName = "Окт"
    case 11: monthName = "Ноя"
    case 12: monthName = "Дек"
    default: ()
    }
    return "\(day) \(monthName)"
}

struct User {
    var username: String
    var id: Int
}

func getSchedule() -> Int {
    return UserDefaults.standard.object(forKey: "Schedule") as? Int ?? 1
}

func getFirstUser() -> Int {
    return UserDefaults.standard.object(forKey: "SID0") as? Int ?? 0
}

func setFirstUser(_ user: Int) {
    let defaults = UserDefaults.standard
    defaults.set(user, forKey: "SID0")
    defaults.synchronize()
}

func setUsers(_ users:[User]) {
    var i = 0
    for user in users {
        UserDefaults.standard.set(user.username, forKey: "User\(i)")
        UserDefaults.standard.set(user.id, forKey: "SID\(i)")
        i += 1
    }
    UserDefaults.standard.set(i, forKey: "NumberOfUsers")
    UserDefaults.standard.synchronize()
}

func getUsers() -> [User] {
    let userCount = UserDefaults.standard.object(forKey: "NumberOfUsers") as? Int ?? -1
    var result = [User]()
    var i = 0
    while i < userCount {
        let user = User(
            username: UserDefaults.standard.object(forKey: "User\(i)") as? String ?? "Ошибка",
            id: UserDefaults.standard.object(forKey: "SID\(i)") as? Int ?? 0
        )
        result.append(user)
        i += 1
    }
    return result
}

func getReloadForum() -> Bool {
    return UserDefaults.standard.object(forKey: "ReloadForum") as? Bool ?? false
}
func getReloadForumMessage() -> Bool {
    return UserDefaults.standard.object(forKey: "ReloadForumMessage") as? Bool ?? false
}
