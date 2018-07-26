//
//  Mail.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 06.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
import BTNavigationDropdownMenu

class Mail: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    /// Represents a deleted mail message
    fileprivate struct MailDeletedMessage {
        var message: MailMessage, indexPath: IndexPath
    }
    /// Drop down menu titles
    private static let titles = ["Входящие", "Черновики", "Отправленные", "Удаленные"]
    /// Loaded mail messages
    fileprivate var messages = [MailMessage]()
    /// Selected Group
    var key = 0
    /// Deleted mail messages queue
    fileprivate lazy var deletedMessages = [MailDeletedMessage]()
    /// Refresh control
    private var refreshControl = UIRefreshControl()
    /// Status of view
    var status: Status = .loading
    /// Whether view need to be reload after saved/send message
    var haveToReload = false
    /// Used to cancel URLSessionTask
    private var task: URLSessionTask?
    
    override func viewWillDisappear(_ animated: Bool) {
        if let menuView = self.navigationItem.titleView as? BTNavigationDropdownMenu {
            if menuView.isShown {
                menuView.hide()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /**
         Reloads section if new message was saved/send
         Otherwise reloads table view in case message was read
         */
        if haveToReload {
            status = .loading
            deletedMessages.removeAll()
            tableView.reloadData()
            loadData()
        } else {
            tableView.deselectSelectedRow
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    /// Loads messages in group
    @objc private func loadData() {
        status = .successful
        switch key {
        case 0:
            messages = [
                MailMessage(author: "Зыченко И. Б.", messageID: "", topic: "Пропуск урока французского языка", date: "26.05.2018 9:38", isUnread: true),
                MailMessage(author: "Рябцева Е. Б.", messageID: "", topic: "Пример сообщения с ссылками и файлами", date: "29.08.2017 19:54", isUnread: false),
                MailMessage(author: "Зибер И.А.", messageID: "", topic: "оценки за четверть", date: "23.10.2015 19:02", isUnread: false),
                MailMessage(author: "Зибер И.А.", messageID: "", topic: "День учителя", date: "03.10.2015 10:43", isUnread: false)
            ]
        case 1:
            messages = [
                MailMessage(author: "Корнакова О. А.", messageID: "", topic: "Fw: Re: Тема", date: "21.04.2018 0:48", isUnread: false),
            ]
        case 2:
            messages = []
        case 3:
            messages = [
                MailMessage(author: "Корнакова О. А.", messageID: "", topic: "Тема", date: "23.01.2018 14:34", isUnread: false),
            ]
        default: ()
        }
        
        tableView.reloadData()
    }
    
    /// Setups UI emenents
    private func setupUI() {
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = createBarButtonItem(imageName: "new", selector: #selector(newLetter))
        createAndSetupDropDownMenu()
    }
    
    /// Presents New Letter view
    @objc private func newLetter() {
        let newLetterVC = NewLetter()
        newLetterVC.navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        newLetterVC.modalTransitionStyle = .coverVertical
        newLetterVC.mailVC = self
        self.present(newLetterVC)
    }
    
    /// Drop down menu сreation and configuration
    private func createAndSetupDropDownMenu() {
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: "Входящие", items: Mail.titles as [AnyObject], schemeColor: .schemeTintColor)
        menuView.cellHeight = 44
        menuView.cellBackgroundColor = UIColor.white.withAlphaComponent(0.9) //lightSchemeColor()
        menuView.cellSelectionColor = UIColor(red: 239/255, green: 238/255, blue: 244/255, alpha: 1)
        menuView.shouldKeepSelectedCellColor = true
        menuView.cellTextLabelColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        menuView.arrowTintColor = .schemeTitleColor
        menuView.menuTitleColor = .schemeTitleColor
        menuView.cellTextLabelFont = UIFont.systemFont(ofSize: 17)
        menuView.cellTextLabelAlignment = .left
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.3
        menuView.maskBackgroundColor = UIColor.black
        menuView.maskBackgroundOpacity = 0.3
        menuView.isScrollEnabled = false
        menuView.didSelectItemAtIndexHandler = { indexPath in
            if self.key != indexPath {
                self.key = indexPath
                selectionFeedback()
                self.messages.removeAll()
                self.tableView.reloadData()
                self.loadData()
            }
        }
        self.navigationItem.titleView = menuView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? Details,
            let indexPath = tableView.indexPathForSelectedRow {
            destination.message = messages[indexPath.row]
            destination.mailVC = self
            destination.detailType = .mail
            destination.indexPath = indexPath
            destination.key = key
        }
    }
    
    /// Deletes mail message
    func deleteRowAt(_ indexPath: IndexPath) {
        self.deletedMessages.append(MailDeletedMessage(message: self.messages[indexPath.row], indexPath: indexPath))
        let messageID = messages[indexPath.row].messageID
        messages.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        deleteMessageAt(indexPath, messageID: messageID)
    }
    
    /// Presents new letter screen
    func messageAction(key: String, row: Int) {
        let newLetterVC = NewLetter()
        newLetterVC.AKey = key
        newLetterVC.MID = self.messages[row].messageID
        newLetterVC.MBID = self.key + 1
        newLetterVC.mailVC = self
        newLetterVC.navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        newLetterVC.modalTransitionStyle = .coverVertical
        UIApplication.shared.keyWindow?.rootViewController?.present(newLetterVC)
    }
    
    /// Creates alert controller with actions for mail
    func createActionsAlert(_ indexPath: IndexPath) -> UIAlertController {
        let 🚨 = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        func addActionToAlert(title: String, key: String) {
            🚨.addDefaultAction(title: title) {
                self.tableView.isEditing = false
                self.messageAction(key: key, row: indexPath.row)
            }
        }
        addActionToAlert(title: "Ответить", key: "R")
        addActionToAlert(title: "Ответить всем", key: "A")
        addActionToAlert(title: "Переслать", key: "F")
        if self.key == 1 {
            addActionToAlert(title: "Изменить", key: "E")
        }
        return 🚨
    }
    
    /// Updates bookmark sell status
    func updateCell(_ cell: MailCell, condition: Bool) {
        if condition {
            cell.dateConstraint.constant = 24
            cell.labelIcon.isHidden = false
        } else {
            cell.labelIcon.isHidden = true
            cell.dateConstraint.constant = 8
        }
    }
    
}


// MARK: - Mail Table View
extension Mail: UITableViewDelegate, UITableViewDataSource {
    // MARK: Basic Setup
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .normal, title: "Ещё") { _,_ in
            let 🚨 = self.createActionsAlert(indexPath)
            if self.messages[indexPath.row].isUnread {
                🚨.addDefaultAction(title: "Прочитать") {
                    self.tableView.isEditing = false
                    self.messages[indexPath.row].read()
                    self.tableView.isEditing = false
                    let cell = self.tableView.cellForRow(at: indexPath) as! MailCell
                    cell.unreadIcon.isHidden = true
                    cell.authorConstraint.constant = 40
                    self.readMessageAt(indexPath)
                }
            }
            🚨.addCancelAction
            🚨.popoverPresentationController?.sourceView = self.tableView
            🚨.popoverPresentationController?.sourceRect = tableView.cellForRow(at: indexPath)?.frame ?? .zero
            self.present(🚨)
        }
        more.backgroundColor = .lightGray
        
        let title = UserDefaults.standard.bool(forKey: "m\(self.messages[indexPath.row].messageID)") ? "Снять\nотметку" : "Пометить"
        let mark = UITableViewRowAction(style: .normal, title: title) { _,_ in
            let def = UserDefaults.standard
            let value = def.bool(forKey: "m\(self.messages[indexPath.row].messageID)")
            def.setValue(!value, forKey: "m\(self.messages[indexPath.row].messageID)")
            def.synchronize()
            self.updateCell(self.tableView.cellForRow(at: indexPath) as! MailCell, condition: !value)
            self.tableView.isEditing = false
        }
        mark.backgroundColor = .orange
        
        let delete = UITableViewRowAction(style: .destructive, title: "Удалить") { _,_ in
            self.deleteRowAt(indexPath)
        }
        
        return [delete, mark, more]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return status == .error ? 0 : messages.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MailCell
        let message = messages[indexPath.row]
        cell.titleLabel?.text = message.topic
        let r = message.date
        let range = r.startIndex..<r.index(r.startIndex, offsetBy: 10)
        updateCell(cell, condition: UserDefaults.standard.bool(forKey: "m\(message.messageID)"))
        cell.icon.setImage(string: message.author)
        cell.dateLabel?.text = cleverDate(String(r[range]))
        cell.explainLabel?.text = message.author
        if message.isUnread {
            cell.unreadIcon.isHidden = false
            cell.authorConstraint.constant = 62
            cell.unreadIcon.image = UIImage(named: "dot")
        } else {
            cell.unreadIcon.isHidden = true
            cell.authorConstraint.constant = 40
            cell.unreadIcon.image = nil
        }
        cell.unreadIcon?.setImageBackgroundColor(.schemeTintColor)
        cell.setSelection        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messages[indexPath.row].read()
        performSegue(withIdentifier: "details")
    }
    
    // MARK: Footer Setup
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return messages.isEmpty || status == .error ? 35 : 0 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if status == .error { return self.view.errorFooterView() }
        guard messages.isEmpty else { return nil }
        if status == .loading { return self.view.loadingFooterView() }
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 23))
        footerView.backgroundColor = UIColor.clear
        let footerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: tableView.frame.size.width - 20, height: 23))
        footerLabel.addProperties
        footerLabel.text = "Сообщений нет"
        footerView.addSubview(footerLabel)
        return footerView
    }
    
    /**
     Deletes message
     - parameter indexPath: indexPath of message
     - parameter messageID: ID of message
     */
    fileprivate func deleteMessageAt(_ indexPath: IndexPath, messageID: String) {
            
    }
    /**
     Marks message as read
     - parameter indexPath: indexPath of message
     */
    func readMessage(_ indexPath: IndexPath) {
        self.messages[indexPath.row].read()
        let cell = tableView.cellForRow(at: indexPath) as! MailCell
        cell.unreadIcon.isHidden = true
        cell.authorConstraint.constant = 40
    }
    
    /**
     Mark message as read
     - parameter indexPath: indexPath of message
     */
    fileprivate func readMessageAt(_ indexPath: IndexPath) {
        
    }
}

class MailCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explainLabel: UILabel!
    @IBOutlet weak var labelIcon: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var authorConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateConstraint: NSLayoutConstraint!
}

/// Represents Mail message
class MailMessage {
    let author, messageID, topic, date: String
    var isUnread: Bool
    init(author: String, messageID: String, topic: String, date: String, isUnread: Bool) {
        self.author = author
        self.messageID = messageID
        self.topic = topic
        self.date = date
        self.isUnread = isUnread
    }
    func read() { isUnread = false }
    func unRead() { isUnread = true }
}

//MARK: - 3D Touch peek and pop
extension Mail: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if #available(iOS 9.0, *) {
            guard let indexPath = tableView.indexPathForRow(at: location),
                let cell = tableView.cellForRow(at: indexPath),
                let detailVC = storyboard?.instantiateViewController(withIdentifier: "Details") as? Details else { return nil }
            detailVC.message = messages[indexPath.row]
            detailVC.detailType = .mail
            detailVC.key = key
            detailVC.mailVC = self
            detailVC.indexPath = indexPath
            previewingContext.sourceRect = cell.frame
            return detailVC
        }
        return nil
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit)
    }
}







