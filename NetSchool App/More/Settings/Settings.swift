//
//  Settings.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 11.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
import IGColorPicker
import UIKit

class Settings: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var colorPickerView: ColorPickerView!
    var colorPaletteAlert: UIAlertController!
    var colInfo: ColorPickerInformation = ColorPickerInformation(model_name: UIDevice.current.modelName)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
    }
}


extension Settings: UITableViewDataSource, UITableViewDelegate {
    
    private static let headerTitles = ["Уведомления","Основные","Пароль","Подписка"]
    
    private static let titles = [
        ["Push-уведомления", "Не беспокоить"],
        ["Расписание","Цветовая схема"],
        ["Изменение пароля"],
        ["Подписка"]
    ]
    private static let imageNames = [
        ["alarm", "doNotDisturb"],
        ["calendar", "brush"],
        ["password"],
        ["subscription"]
    ]
    static let scheduleCases = [
        ["Только сегодня", "Сегодня и завтра", "4 дня", "Неделя"],
        [0, 1, 3, 6]
    ]

    static let colorsHEXs = [
        "f54335", "3d78be", "ffc207",
        "ed1c22", "2196f3", "ff9700",
        "ea1e63", "00bcd5", "fe5722",
        "9c28b1", "009788", "795549",
        "673bb7", "4cb050", "607d8b",
        "3e52b5", "8ac44b", "444444"
    ]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section > 1 ? 1 : 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SettingsCell
        cell.icon.image = UIImage(named: Settings.imageNames[indexPath.section][indexPath.row])
        cell.titleLabel.text = Settings.titles[indexPath.section][indexPath.row]
        cell.selectionStyle = .default
//        cell.icon.setImageBackgroundColor(.schemeTintColor)
        cell.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0)
        if indexPath.row == 0 && indexPath.section == 1 {
            cell.descriptionLabel.text = Settings.scheduleCases[0][(Settings.scheduleCases[1] as! [Int]).index(of: 1)!] as? String
        } else {
            cell.descriptionLabel.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0 else {
            let settingsDetailVC = SettingsDetails()
            if indexPath.row == 0 {
                settingsDetailVC.settingsDetailType = .notification
                settingsDetailVC.navigationBarTitle = "Уведомления"
                show(settingsDetailVC)
            } else {
                settingsDetailVC.settingsDetailType = .doNotDisturb
                settingsDetailVC.modalTransitionStyle = .coverVertical
                settingsDetailVC.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
                present(settingsDetailVC)
            }
            return
        }
        guard indexPath.section != 1 else {
            if indexPath.row == 0 {
                let detailVC = SettingsDetails()
                detailVC.settingsVC = self
                detailVC.settingsDetailType = .schedule
                show(detailVC)
            } else {
//                func getValues() -> (title: String, frame: CGRect) {
//                    let title = "\n\n\n\n\n\n\n\n"
//                    let f = view.frame.width - 20 - 50*6
//                    let g:CGFloat =  5*8 + 34
//                    let x = (f-g) / 2
//                    return (title: title, frame: CGRect(x: x, y: -10, width: 50*6 + 5*8 + 30, height: 3*50 + 2*16 + 16))
//                }
//                let (title, frame) = getValues()
//                colorPaletteAlert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
//                colorPickerView = ColorPickerView(frame: frame)
//                colorPaletteAlert.addCancelAction
//                colorPickerView.delegate = self
//                colorPickerView.layoutDelegate = self
//                colorPickerView.colors = Settings.colorsHEXs.map{UIColor(hex: $0).withAlphaComponent(0.86)}
//                colorPaletteAlert.view.addSubview(colorPickerView)
//                colorPaletteAlert.popoverPresentationController?.sourceView = tableView
//                colorPaletteAlert.popoverPresentationController?.sourceRect = tableView.cellForRow(at: indexPath)!.frame
//                self.present(colorPaletteAlert)
//                tableView.deselectSelectedRow
                let w = view.frame.width / colInfo.k
                print(UIDevice.current.modelName)
                func getValues() -> (title: String, frame: CGRect) {
                    let title = colInfo.title
                    return (title: title, frame: CGRect(x: colInfo.x_marg, y: colInfo.y_marg, width: w*6 + 5*8 + 16, height: 3*w + 2*16 + 17))
                }
                let (title, frame) = getValues()
                colorPaletteAlert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
                colorPickerView = ColorPickerView(frame: frame)
                colorPaletteAlert.addCancelAction
                colorPickerView.delegate = self
                colorPickerView.layoutDelegate = self
                colorPickerView.colors = Settings.colorsHEXs.map{UIColor(hex: $0).withAlphaComponent(0.86)}
                colorPaletteAlert.view.addSubview(colorPickerView)
                colorPaletteAlert.popoverPresentationController?.sourceView = tableView
                colorPaletteAlert.popoverPresentationController?.sourceRect = tableView.cellForRow(at: indexPath)!.frame
                self.present(colorPaletteAlert)
                tableView.deselectSelectedRow
            }
            return
        }
        guard indexPath.section != 2 else {
            let changePasswordVC = ChangePassword()
            changePasswordVC.navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
            changePasswordVC.modalTransitionStyle = .coverVertical
            changePasswordVC.settingsVC = self
            present(changePasswordVC)
            return
        }
        let settingsDetailVC = SettingsDetails()
        settingsDetailVC.settingsDetailType = .subscription
        show(settingsDetailVC)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Settings.headerTitles[section]
    }
}

extension Settings: ColorPickerViewDelegate, ColorPickerViewDelegateFlowLayout {
    /// Color selected
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        setInt(forKey: "Color", val: indexPath.row)
        selectionFeedback()
        let navigationBarAppearance = UINavigationBar.appearance()
        let sharedApplication = UIApplication.shared
        navigationBarAppearance.barTintColor = darkSchemeColor()
        sharedApplication.keyWindow?.tintColor = UIColor(hex: "424242")//darkSchemeColor().darker()
        UITabBar.appearance().tintColor = darkSchemeColor()
        navigationController?.navigationBar.barTintColor = darkSchemeColor()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.schemeTitleColor]
        sharedApplication.statusBarStyle = .lightContent//.schemeStyle
        navigationBarAppearance.tintColor = .schemeTitleColor
        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.schemeTitleColor]
        UITabBar.appearance().tintColor = darkSchemeColor()
        if let tapBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            tapBarController.tabBar.tintColor = darkSchemeColor()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.colorPaletteAlert.dismiss()
        }
    }
    /// Size of color circle
    func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = view.frame.width / colInfo.k
        return CGSize(width: w, height: w)
    }
    /// Space between cells
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    /// Space between rows
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}


class SettingsCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}

class ChangePassword: UIViewController, UITextFieldDelegate {
    
    /// Settings super view controller
    var settingsVC: Settings!
    /// Navigation bar height
    var navigationBarHeight: CGFloat = 0
    /// Table view with textFields
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    /// Old password
    fileprivate var oldPassword = ""
    /// New password
    fileprivate var newPassword = ""
    /// Repeated new password
    fileprivate var newRepetedPassword = ""
    /// Error text
    fileprivate var footerText = ""
    /// Ready bar button item
    fileprivate let sendItem = UIBarButtonItem(title: "Готово", style: .done , target: self, action: #selector(changePassAction))
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAndSetupTableView()
        createAndSetupNavigationBar()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        task?.cancel()
//        settingsVC.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
    }
    
    /// Table View creation and configuration
    private func createAndSetupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = .zero
        view.addSubview(tableView)
        tableView.addConstraints(view: view, topConstraintConstant: -navigationBarHeight)
    }
    
    /// Navigation bar сreation and configuration
    private func createAndSetupNavigationBar() {
        view.backgroundColor = .white
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: navigationBarHeight))
        let navItem = UINavigationItem(title: "Смена пароля")
        let cancelItem = UIBarButtonItem(title: "Отменить", style: .plain , target: self, action: #selector(self.cancel))//#selector(cancel))
        sendItem.isEnabled = false
        navItem.rightBarButtonItem = sendItem
        navItem.leftBarButtonItem = cancelItem
        navBar.isTranslucent = false
        navBar.barTintColor = darkSchemeColor()
        navBar.alpha = 0.86
        navBar.setItems([navItem], animated: false)
        
        view.addSubview(navBar)
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: UIApplication.shared.statusBarFrame.height))
        statusBarView.backgroundColor = darkSchemeColor().withAlphaComponent(0.86)
        view.addSubview(statusBarView)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func cancel() {
        dismiss()
    }
    
    @objc fileprivate func textFieldDidChange(_ textField: UITextField) {
        switch textField.tag {
        case 0: oldPassword = textField.text ?? ""
        case 1: newPassword = textField.text ?? ""
        case 2: newRepetedPassword = textField.text ?? ""
        default: ()
        }
        sendItem.isEnabled = !oldPassword.isEmpty && !newPassword.isEmpty && !newRepetedPassword.isEmpty
    }
    
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag != 2 {
            guard let cell = tableView.cellForRow(at: IndexPath(row: textField.tag + 1, section: 0)),
                let textField = (cell.subviews.filter{ $0 is UITextField }).first else { return false }
            (textField as! UITextField).becomeFirstResponder()
        } else if !newRepetedPassword.isEmpty && !newPassword.isEmpty && !oldPassword.isEmpty {
            changePassAction()
            textField.resignFirstResponder()
        }
        return false
    }
    
    func setError(_ title: String) {
        footerText = title
        tableView.reloadData()
    }
    
    @objc func changePassAction() {
        guard newPassword.count > 5 else {
            setError("Новый пароль должен состоять хотя бы из 6 символов")
            errorFeedback()
            guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)),
                let textField = (cell.subviews.filter{ $0 is UITextField }).first else { return }
            dangle(textfield: textField as! UITextField)
            guard let cell2 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)),
                let textField2 = (cell2.subviews.filter{ $0 is UITextField }).first else { return }
            dangle(textfield: textField2 as! UITextField)
            return
        }
        guard newPassword == newRepetedPassword else {
            setError("Пароли не совпадают")
            errorFeedback()
            guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)),
                let textField = (cell.subviews.filter{ $0 is UITextField }).first else { return }
            dangle(textfield: textField as! UITextField)
            guard let cell2 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)),
                let textField2 = (cell2.subviews.filter{ $0 is UITextField }).first else { return }
            dangle(textfield: textField2 as! UITextField)
            return
        }
    }
}

extension ChangePassword: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 3 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0)
        cell.subviews.filter{ $0 is UITextField }.forEach{ $0.removeFromSuperview() }
        let textField = UITextField()
        textField.delegate = self
        textField.tag = indexPath.row
        textField.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        textField.font = UIFont(name: "HelveticaNeue-Light", size: 17)!
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.isSecureTextEntry = true
        textField.returnKeyType = indexPath.row == 2 ? .send : .next
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(textField)
        let (placeholder, text) = indexPath.row == 0 ? ("Старый пароль", oldPassword) : indexPath.row == 1 ? ("Новый пароль", newPassword) : ("Повторите новый пароль", newRepetedPassword)
        textField.text = text
        let attributes = [
            NSAttributedStringKey.foregroundColor: UIColor.gray.withAlphaComponent(0.7),
            NSAttributedStringKey.font : UIFont(name: "HelveticaNeue-Light", size: 17)!
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes:attributes)
        let yConstraint = NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1, constant: 16)
        let trailingConstraint = NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
        cell.addConstraints([yConstraint, heightConstraint, trailingConstraint, leadingConstraint])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 23 }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 23))
        footerView.backgroundColor = UIColor.clear
        let footerLabel = UILabel(frame: CGRect(x: 0, y: 7, width: view.frame.size.width, height: 23))
        footerLabel.addProperties
        footerLabel.textColor = UIColor.init(hex: "EA5E54")
        footerLabel.text = footerText
        footerView.addSubview(footerLabel)
        return footerView
    }
}

