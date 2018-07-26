//
//  NewForumMessage.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 06.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
import Reachability

class NewForumMessage: UIViewController {
    
    var topic = "", isTopicNew = false, topicID: String!
    
    var message = ""
    var navigationBarHeight: CGFloat = 0
    fileprivate let tableView = UITableView()
    /// Bar button item represents sent action
    fileprivate var sendItem = UIBarButtonItem()
    fileprivate var keyboardSize:CGFloat = 0
    /// TextView height
    fileprivate var textViewHeight:CGFloat = 40
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        createAndSetupTableView()
        createAndSetupNavigationBar()
        sendItem.isEnabled = !topic.isEmpty && !message.isEmpty
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        task?.cancel()
    }
    
    /// Table View creation and configuration
    private func createAndSetupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = .zero
        view.addSubview(tableView)
        var topConstraintConstant:CGFloat = -UIApplication.shared.statusBarFrame.height - navigationBarHeight
        if #available(iOS 11.0, *), (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) > 0  {
            topConstraintConstant += navigationBarHeight
        }
        tableView.addConstraints(view: view, topConstraintConstant: topConstraintConstant)
    }
    
    /// Navigation bar сreation and configuration
    private func createAndSetupNavigationBar() {
        view.backgroundColor = .white
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: navigationBarHeight))
        let navItem = UINavigationItem(title: "Новое")
        let cancelItem = UIBarButtonItem(title: "Отменить", style: .plain , target: self, action: #selector(cancel))
        sendItem = UIBarButtonItem(title: "Отправить", style: .done , target: self, action: #selector(send))
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
    }
    
    /// Close New Letter view
    @objc private func cancel() {
        view.endEditing(true)
        dismiss()
    }
    
    // MARK: Keyboard setup
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboard = view.convert(keyboardFrame, from: view.window)
        let height = view.frame.size.height
        keyboardSize = height - keyboard.origin.y
        updateConstraint(newValue: keyboardSize, view: view, tableView: tableView)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardSize = 0
        updateConstraint(newValue: 0, view: view, tableView: tableView)
    }
    
    /**
     Updates table view bottom constraint to new value
     - parameter newValue: New constraint constant value
     - parameter view: View where table view is located
     - parameter tableView: Table view for update
     */
    fileprivate func updateConstraint(newValue: CGFloat, view: UIView, tableView: UITableView) {
        view.constraints.filter{ $0.firstAttribute == .bottomMargin && $0.secondItem is UITableView }
            .forEach{ $0.constant = newValue }
        tableView.updateCellHeigths()
    }
    
    
    @objc private func send() {
        view.endEditing(true)
        
        guard !topic.removePart(" ").isEmpty, !message.removePart(" ").isEmpty,
            topic.count > 2, message.count > 2  else {
                let 🚨 = UIAlertController(title: "Тема и сообщение должны состоять минимум из 3 символов", message: nil, preferredStyle: .alert)
                🚨.addOkAction
                present(🚨)
                return
        }
//        guard topic.isValid && message.isValid else {
//            let mess = "В Вашем письме содержатся символы, неподдерживаемые почтой NetSchool. \n__________________________________\nДопустимые символы:\nabcdefghijklmnopqrstuvwxyz\nABCDEFGHIJKLKMNOPQRSTUVWXYZ\n0123456789\nабвгдеёжзийклмнопрстуфхцчшщъыьэюя\nАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ\n()<>[]{}#^*+=-_\\/|?!;:,.'\"~`№•@&%$€"
//            let 🚨 = UIAlertController(title: "Письмо содержит недопустимые символы", message: mess, preferredStyle: .alert)
//            🚨.addOkAction
//            present(🚨)
//            return
//        }
    }
    
    func showError() {
        let 🚨 = UIAlertController(title: "Неизвестная ошибка", message:
            "Запрашиваемое действие не выполнено", preferredStyle: .alert)
        🚨.addOkAction
        self.present(🚨)
    }
    
    func check(📦: UIView, error: Error?, response: URLResponse) {
        DispatchQueue.main.async {
            📦.removeFromSuperview()
            guard error == nil else {
                let title = ReachabilityManager.shared.isNetworkAvailable ? "Неизвестная ошибка" : "Соединение с интернетом прервано"
                let 🚨 = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                🚨.addOkAction
                self.present(🚨)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
//                self.present(unknownError())
                return
            }
            guard String(describing: httpResponse.url).range(of: "AddReply") != nil else {
                let 🚨 = UIAlertController(title: "Ошибка: новая тема не создана", message:
                    "Возможно, сессия NetSchool устарела. Перезайдите на форум и повторите попытку.", preferredStyle: .alert)
                🚨.addOkAction
                self.present(🚨)
                return
            }
//            setBool(forKey: "ReloadForum", val: true)
//            setBool(forKey: "ReloadForumMessage", val: true)
            self.dismiss()
        }
    }
}

extension NewForumMessage: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        if indexPath.row == 0 {
            /**
             Adds cell name label
             - parameter title: Title for label
             */
            cell.subviews.filter{ $0 is UILabel }.forEach{ $0.removeFromSuperview() }
            func createCellNameLabel(_ title: String) {
                let font = UIFont(name: "HelveticaNeue-Light", size: 15)!
                let size = (title as NSString).size(withAttributes: [NSAttributedStringKey.font: font])
                let label = UILabel(frame: CGRect(x: 8, y: 20 - size.height/2, width: size.width, height: size.height))
                label.text = title
                label.font = font
                label.textColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
                cell.addSubview(label)
            }
            cell.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            createCellNameLabel("Тема:")
            let width = cell.subviews.filter{ $0 is UILabel }.first?.frame.width ?? 0
            let textField = UITextField()
            textField.delegate = self
            textField.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
            textField.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.text = topic
            textField.isUserInteractionEnabled = isTopicNew
            cell.addSubview(textField)
            let topConstraint = NSLayoutConstraint(item: textField, attribute: .topMargin, relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1, constant: 8)
            let leadingConstraint = NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: width + 16)
            let trailingConstraint = NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailing, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
            view.addConstraints([topConstraint, heightConstraint, trailingConstraint, leadingConstraint])
        } else {
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
            cell.backgroundColor = .white
            let textView = UITextView()
            textView.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
            textView.sizeToFit()
            textView.isScrollEnabled = false
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.delegate = self
            textView.text = message
            cell.addSubview(textView)
            let topConstraint = NSLayoutConstraint(item: textView, attribute: .topMargin, relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1, constant: 8)
            let leadingConstraint = NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 8)
            let trailingConstraint = NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailing, multiplier: 1, constant: -8)
            let bottomConstraint = NSLayoutConstraint(item: textView, attribute: .bottomMargin, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1, constant: -8)
            view.addConstraints([topConstraint, bottomConstraint, trailingConstraint, leadingConstraint])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /// Calculates Text View height
        func heightForTextView() -> CGFloat {
            var minHeight = view.frame.height - navigationBarHeight - UIApplication.shared.statusBarFrame.height
            minHeight -= keyboardSize
            return minHeight < textViewHeight ? textViewHeight : minHeight
        }
        return indexPath.row == 0 ? 40 : heightForTextView()
    }
}

//MARK: - TextField extension
extension NewForumMessage: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        topic = textField.text ?? ""
        sendItem.isEnabled = !topic.isEmpty && !message.isEmpty
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.subviews.filter{$0 is UITextView }.forEach{ $0.becomeFirstResponder() }
        return true
    }
}

//MARK: - Text View extension
extension NewForumMessage: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        message = textView.text
        let textSize = CGSize(width: CGFloat(textView.frame.size.width), height: CGFloat(MAXFLOAT))
        let textViewHeight = CGFloat(textView.sizeThatFits(textSize).height) + 10
        self.textViewHeight = textViewHeight
        tableView.updateCellHeigths()
        sendItem.isEnabled = !topic.isEmpty && !message.isEmpty
    }
}


















