//
//  SettingsDetail.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 13.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
import MessageUI
import UIKit

/// Enumeration represents detail types
enum SettingsDetailType {
    case schedule, support, notification, doNotDisturb, subscription, notificationDetail, undefined
}

// MARK: - Schedule Settings
class SettingsDetails: UIViewController {
    /// View's table view
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    var settingsDetailType: SettingsDetailType = .undefined
    var settingsVC: Settings?
    /// Navigation bar height
    var navigationBarHeight: CGFloat = 0
    fileprivate let enterItem = UIBarButtonItem(title: "Готово", style: .done , target: self, action: #selector(done))
    fileprivate var hour, minute: Int?
    var navigationBarTitle = ""
    fileprivate var selectedRow: Int?
    fileprivate var date = Date()
    fileprivate var notificationGroupIndex: Int?
    fileprivate var notificationSettingsDetail: SettingsDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAndSetupTableView()
        
        switch settingsDetailType {
        case .doNotDisturb:
            createAndSetupNavigationBar()
        case .notificationDetail, .notification:
            navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.title = navigationBarTitle
        default: ()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
    }
    
    private func createAndSetupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "сell")
        view.addSubview(tableView)
        tableView.addConstraints(view: view, topConstraintConstant: -navigationBarHeight)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    /// Navigation bar сreation and configuration
    private func createAndSetupNavigationBar() {
        view.backgroundColor = .white
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: navigationBarHeight))
        let navItem = UINavigationItem(title: "Не беспокоить")
        enterItem.isEnabled = false
        navItem.rightBarButtonItem = enterItem
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain , target: self, action: #selector(cancel))
        navBar.isTranslucent = false
        navBar.barTintColor = darkSchemeColor()
        navBar.alpha = 0.86
        navBar.barStyle = .black
        navBar.setItems([navItem], animated: false)
        view.addSubview(navBar)
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: UIApplication.shared.statusBarFrame.height))
        statusBarView.backgroundColor = darkSchemeColor().withAlphaComponent(0.86)
        view.addSubview(statusBarView)
    }
    
    @objc private func cancel() {
        dismiss()
    }
    
    @objc private func done() {
        dismiss()
    }
}

struct NotificationGroup {
    var title: String
    var subHeaders: [String]
    var subTitles: [[String]]
}

struct Support {
    var icon, title, description: String
    var link, shortcut: String?
}

// MARK: - Settings Table View
extension SettingsDetails: UITableViewDataSource, UITableViewDelegate {
    private static let doNotDisturb = ["Очистить", "1 час", "6 часов", "24 часа", "До времени"]
    private static let support = [
        Support(icon: "email", title: "E-mail", description: "support@netschool.app", link: nil, shortcut: nil),
        Support(icon: "vk", title: "ВКонтакте", description: "/netschoolapp", link: "vk.com/netschoolapp", shortcut: "vk"),
        Support(icon: "twitter", title: "Twitter", description: "@netschoolapp", link: "twitter.com/netschoolapp", shortcut: "twitter"),
        Support(icon: "facebook", title: "Facebook", description: "/groups/netschoolapp", link: "www.facebook.com/groups/netschoolapp/", shortcut: "fb"),
        Support(icon: "instagram", title: "Instagram", description: "@netschoolapp", link: "www.instagram.com/netschoolapp/", shortcut: "instagram")
    ]
    private static let notificationGroups = [
        NotificationGroup(title: "Задания и оценки", subHeaders: ["Оценки","Задания"] ,subTitles: [["Все", "Только важные", "Никакие"], ["Все", "Только домашние задания", "Никакие"]]),
        NotificationGroup(title: "Объявления", subHeaders: ["Объявления"] , subTitles: [["Все","Выключено"]]),
        NotificationGroup(title: "Изменения в расписании", subHeaders: ["Расписание"] , subTitles: [["Предупреждать об изменениях", "Выключено"]]),
        NotificationGroup(title: "Почта", subHeaders: ["Письма"] , subTitles: [["Входящие", "Выключено"]]),
        NotificationGroup(title: "Сообщения на форуме", subHeaders: ["Сообщения"] , subTitles: [["Все", "Выключено"]]),
        NotificationGroup(title: "Новые учебные материалы", subHeaders: ["Изменения"] , subTitles: [["Появление новых файлов", "Выключено"]])
    ]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsDetailType == .notificationDetail ? SettingsDetails.notificationGroups[notificationGroupIndex ?? 0].subTitles.count : 1
    }
    
    //MARK: TABLE VIEW SETUP
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch settingsDetailType {
            case .support : return 5
            case .schedule: return 4
            case .doNotDisturb: return 5
            case .notification: return 6
            case .notificationDetail:
                return SettingsDetails.notificationGroups[notificationGroupIndex ?? 0].subTitles[section].count
            default: return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "сell", for: indexPath) as UITableViewCell
        cell.accessoryType = .none
        switch settingsDetailType {
            case .support :
                cell.subviews.filter{$0 is UILabel || $0 is UIImageView}.forEach{$0.removeFromSuperview()}
                let imageView = UIImageView(frame: CGRect(x: 8, y: 0, width: 44, height: 44 ))
                imageView.image = UIImage(named: "support_\(SettingsDetails.support[indexPath.row].icon)")
                imageView.translatesAutoresizingMaskIntoConstraints = false
                cell.addSubview(imageView)

                var topConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: cell.contentView, attribute: .centerY, multiplier: 1, constant: 30)
                var leadingConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 16)
                var widthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
                let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
                cell.addConstraints([topConstraint, leadingConstraint, widthConstraint, heightConstraint])
                let label = UILabel()
                label.text = SettingsDetails.support[indexPath.row].title
                label.font = UIFont(name: "HelveticaNeue", size: 16) ?? UIFont.systemFont(ofSize: 16)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
                cell.addSubview(label)
                leadingConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 75)
                widthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cell.frame.width - 50)
                topConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1, constant: 27)
                cell.addConstraints([topConstraint, widthConstraint, leadingConstraint])
                let detailLabel = UILabel()
                detailLabel.text = SettingsDetails.support[indexPath.row].description
                detailLabel.font = UIFont(name: "HelveticaNeue", size: 14) ?? UIFont.systemFont(ofSize: 14)
                detailLabel.textColor = UIColor.gray.withAlphaComponent(0.7)
                detailLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.addSubview(detailLabel)
                leadingConstraint = NSLayoutConstraint(item: detailLabel, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 75)
                widthConstraint = NSLayoutConstraint(item: detailLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cell.frame.width - 50)
                topConstraint = NSLayoutConstraint(item: detailLabel, attribute: .top , relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1, constant: 32)
                cell.addConstraints([topConstraint, widthConstraint, leadingConstraint])
                cell.separatorInset = UIEdgeInsetsMake(0, 75, 0, 0)
                cell.accessoryType = .disclosureIndicator
            case .schedule:
                if getSchedule() == (Settings.scheduleCases[1][indexPath.row] as! Int) { cell.accessoryType = .checkmark }
                cell.textLabel?.text = Settings.scheduleCases[0][indexPath.row] as? String
            case .doNotDisturb:
                cell.textLabel?.text = SettingsDetails.doNotDisturb[indexPath.row]
                cell.subviews.filter{$0.tag == 1}.forEach{$0.removeFromSuperview()}
                if indexPath.row == 4 {
                    let label = UILabel(frame: CGRect(x: 15, y: 8, width: view.frame.width - (selectedRow == 4 ? 50 : 30), height: 28))
                    label.textColor = UIColor.lightGray
                    label.tag = 1
                    label.textAlignment = .right
                    let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                    self.hour = components.hour
                    self.minute = components.minute
                    if let hour = components.hour, let minute = components.minute {
                        let zero = minute < 10 ? "0" : ""
                        label.text = "\(hour):\(zero)\(minute )"
                    }
                    cell.addSubview(label)
                    if selectedRow == 4 { cell.accessoryType = .checkmark }
                }
            case .notification:
                cell.subviews.filter{$0 is UILabel || $0 is UIImageView}.forEach{$0.removeFromSuperview()}
                let imageView = UIImageView(frame: CGRect(x: 8, y: 0, width: 44, height: 44 ))
                imageView.image = UIImage(named: "notification_\(indexPath.row)")
                imageView.translatesAutoresizingMaskIntoConstraints = false
                cell.addSubview(imageView)
                
                var topConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: cell.contentView, attribute: .centerY, multiplier: 1, constant: 30)
                var leadingConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 16)
                var widthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
                let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
                cell.addConstraints([topConstraint, leadingConstraint, widthConstraint, heightConstraint])
                let label = UILabel()
                label.text = SettingsDetails.notificationGroups[indexPath.row].title
                label.font = UIFont(name: "HelveticaNeue", size: 16) ?? UIFont.systemFont(ofSize: 16)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
                cell.addSubview(label)
                leadingConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 75)
                widthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cell.frame.width - 50)
                topConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1, constant: 27)
                cell.addConstraints([topConstraint, widthConstraint, leadingConstraint])
                let detailLabel = UILabel()
                if indexPath.row != 0 {
                    detailLabel.text = SettingsDetails.notificationGroups[indexPath.row].subTitles[0][getInt(forKey: "notification_\(indexPath.row)0")]
                } else {
                    detailLabel.text = SettingsDetails.notificationGroups[indexPath.row].subTitles[1][getInt(forKey: "notification_\(indexPath.row)1")] + " / " + SettingsDetails.notificationGroups[indexPath.row].subTitles[0][getInt(forKey: "notification_\(indexPath.row)0")]
                }
                detailLabel.font = UIFont(name: "HelveticaNeue", size: 14) ?? UIFont.systemFont(ofSize: 14)
                detailLabel.textColor = UIColor.gray.withAlphaComponent(0.7)
                detailLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.addSubview(detailLabel)
                leadingConstraint = NSLayoutConstraint(item: detailLabel, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 75)
                widthConstraint = NSLayoutConstraint(item: detailLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cell.frame.width - 50)
                topConstraint = NSLayoutConstraint(item: detailLabel, attribute: .top , relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1, constant: 32)
                cell.addConstraints([topConstraint, widthConstraint, leadingConstraint])
                
                cell.separatorInset = UIEdgeInsetsMake(0, 75, 0, 0)
                
                cell.accessoryType = .disclosureIndicator
            case .notificationDetail:
                guard let notificationGroupIndex = notificationGroupIndex else { return cell }
                cell.textLabel?.text = SettingsDetails.notificationGroups[notificationGroupIndex].subTitles[indexPath.section][indexPath.row]
                if getInt(forKey: "notification_\(notificationGroupIndex)\(indexPath.section)") == indexPath.row {
                    cell.accessoryType = .checkmark
                }
            default: ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (settingsDetailType == .notification || settingsDetailType == .support) ? 60 : 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch settingsDetailType {
            case .support :
                switch indexPath.row {
                case 0:
                    let 🚨 = UIAlertController(title: "Email", message:
                        "Выберите причину, по которой Вы хотите обратиться в тех поддержку", preferredStyle: .actionSheet)
                    ["Сообщение об ошибке", "Вопрос по использованию", "Предложение по улучшению", "Другая причина"].forEach { title in
                        🚨.addDefaultAction(title: title) { self.openMail(title) }
                    }
                    🚨.addCancelAction
                    🚨.popoverPresentationController?.sourceView = tableView
                    🚨.popoverPresentationController?.sourceRect = tableView.cellForRow(at: indexPath)!.frame
                    self.present(🚨)
                case 1,2,3,4:
                    let supportGroup = SettingsDetails.support[indexPath.row]
                    let appURL = "\(supportGroup.shortcut ?? "")://\(supportGroup.link ?? "")"
                    let safariURL = "https://\(supportGroup.link ?? "")"
                    UIApplication.shared.openURL(UIApplication.shared.canOpenURL(appURL.toURL as URL) ? appURL.toURL as URL : safariURL.toURL as URL)
                default: ()
                }
                tableView.deselectSelectedRow
            case .schedule:
                if let index = (Settings.scheduleCases[1] as! [Int]).index(of: getSchedule()),
                    let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                    cell.accessoryType = .none
                    if index != indexPath.row {
                        selectionFeedback()
                    }
                }
                if let settingsVC = settingsVC,
                    let firstCell = settingsVC.tableView.cellForRow(at: IndexPath(row: 0, section: 1)),
                    let cell = firstCell as? SettingsCell {
                    cell.descriptionLabel.text = Settings.scheduleCases[0][indexPath.row] as? String
                }
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .checkmark
                }
                tableView.deselectSelectedRow
                switch indexPath.row {
                    case 0: setInt(forKey: "Schedule", val: 0)
                    case 1: setInt(forKey: "Schedule", val: 1)
                    case 2: setInt(forKey: "Schedule", val: 3)
                    case 3: setInt(forKey: "Schedule", val: 6)
                default: ()
                    
                }
            case .doNotDisturb:
                if let cell = tableView.cellForRow(at: indexPath) {
                    if let cell = tableView.cellForRow(at: IndexPath(row: selectedRow ?? -5, section: 0)) {
                        cell.accessoryType = .none
                    }
                    cell.accessoryType = .checkmark
                    if (selectedRow ?? -5) != indexPath.row {
                        selectionFeedback()
                        enterItem.isEnabled = true
                        let wasSelected = selectedRow
                        selectedRow = indexPath.row
                        if indexPath.row == 4 || wasSelected == 4 {
                            tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
                        }
                    }
                }
                tableView.deselectSelectedRow
            case .notification:
                let detailedVC = SettingsDetails()
                detailedVC.settingsDetailType = .notificationDetail
                detailedVC.navigationBarTitle = SettingsDetails.notificationGroups[indexPath.row].title
                detailedVC.notificationSettingsDetail = self
                detailedVC.notificationGroupIndex = indexPath.row
                show(detailedVC)
            case .notificationDetail:
                tableView.deselectSelectedRow
                guard let notificationGroupIndex = notificationGroupIndex else { return }
                let oldValue = getInt(forKey: "notification_\(notificationGroupIndex)\(indexPath.section)")
                if oldValue != indexPath.row {
                    if let cell = tableView.cellForRow(at: IndexPath(row: oldValue, section: indexPath.section)) {
                        cell.accessoryType = .none
                    }
                    setInt(forKey: "notification_\(notificationGroupIndex)\(indexPath.section)", val: indexPath.row)
                    notificationSettingsDetail?.tableView.reloadRows(at: [IndexPath(row: notificationGroupIndex, section: 0)], with: .none)
                    selectionFeedback()
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.accessoryType = .checkmark
                    }
                }
            default: ()
        }
    }
    
    //MARK: HEADER
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch settingsDetailType {
        case .support : return "Тех. поддержка"
        case .schedule: return "Расписание"
        case .notificationDetail: return SettingsDetails.notificationGroups[notificationGroupIndex ?? 0].subHeaders[section]
        case .doNotDisturb, .notification: return ""
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return settingsDetailType == .doNotDisturb ? 260 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard settingsDetailType == .doNotDisturb else { return nil }
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        date = sender.date
        if let cell = tableView.cellForRow(at: IndexPath(row: selectedRow ?? -5, section: 0)) {
            cell.accessoryType = .none
        }
        selectionFeedback()
        enterItem.isEnabled = true
        self.selectedRow = 4
        if let cell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) {
            cell.accessoryType = .checkmark
            tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
        }
    }
}

// MARK: - MFMail
extension SettingsDetails: MFMailComposeViewControllerDelegate {
    fileprivate func openMail(_ emailTitle: String) {
        let modelName = UIDevice.current.modelName
        let os = ProcessInfo().operatingSystemVersion
        let IOS = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        let messageBody = "\n\n\n\n\n\nУстройство:  \(modelName)\nВерсия IOS:  \(IOS)\nВерсия NetSchool App:  3.0\nПользователь:  мКорнакова\n"
        let toRecipents = ["NetSchoolApp@mail.ru"]
        let mc = MailExtended()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        mc.navigationBar.tintColor = .schemeTitleColor
        if MFMailComposeViewController.canSendMail() {
            self.present(mc, animated: true) {
                UIApplication.shared.statusBarStyle = .lightContent
            }
        } else {
            let 🚨 = UIAlertController(title: "Ошибка:", message: "Ваше устройство не может отправить email. Попробуйте проверить настройки почты и повторить попытку.", preferredStyle: .alert)
            🚨.addOkAction
            self.present(🚨)
        }
    }
    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        dismiss()
        switch result {
        case .sent:
            let 🚨 = UIAlertController(title: "Информация:", message: "Сообщение помещено в раздел \"Исходящие\". Проверить отправилось сообщение или нет можно в стандартном приложении \"Почта\".", preferredStyle: .alert)
            🚨.addOkAction
            self.present(🚨)
        case .failed:
            let 🚨 = UIAlertController(title: "Информация:", message: "Произошла ошибка во время отправки сообщения. Проверьте интернет соединение и повторите попытку.", preferredStyle: .alert)
            🚨.addOkAction
            self.present(🚨)
        default: ()
        }
    }
}

class MailExtended: MFMailComposeViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var childViewControllerForStatusBarStyle : UIViewController? {
        return nil
    }
}









