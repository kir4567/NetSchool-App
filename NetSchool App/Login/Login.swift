//
//  Login.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 12.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation

struct School {
    var name, link, letter : String
    var ID : Int
}

fileprivate class CustomTextField : UITextField {
    override public var hasText: Bool {
        get {
            return UserDefaults.standard.object(forKey: "enterPermission") as? Bool ?? false
        }
    }
}

class Login: UIViewController, UITextFieldDelegate {
    
    /// Navigation bar height
    var navigationBarHeight: CGFloat = 44
    /// Table view with textFields
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    /// First letters of adress book users divided by groups
    var letters = [Character]()
    /// Adress book users divided by groups
    var adressBook = [Character: [School]]()
    /// Old password
    fileprivate var username = ""
    /// New password
    fileprivate var password = ""
    ///Selected school
    var school: School?
    /// Error text
    fileprivate var footerText = ""
    /// Ready bar button item
    fileprivate let enterItem = UIBarButtonItem(title: "Войти", style: .done , target: self, action: Selector(("enterAction")))
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    
    fileprivate var footerTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAndSetupTableView()
        createAndSetupNavigationBar()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    private func setEnterPermission(_ value: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "enterPermission")
        defaults.synchronize()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        task?.cancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        enterItem.isEnabled = !username.isEmpty && !password.isEmpty && school != nil
        setEnterPermission(enterItem.isEnabled)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        if !footerText.isEmpty {
            footerText = ""
            footerTextView.attributedText = getFooterText()
            footerTextView.textAlignment = .center
        }
    }
    
    /// Table View creation and configuration
    private func createAndSetupTableView() {
        footerTextView.frame = CGRect(x: 0, y: 7, width: view.frame.size.width, height: 100)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = .zero
        tableView.allowsSelection = false
        view.addSubview(tableView)
        tableView.addConstraints(view: view, topConstraintConstant: -navigationBarHeight)
    }
    
    /// Navigation bar сreation and configuration
    private func createAndSetupNavigationBar() {
        view.backgroundColor = .white
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: navigationBarHeight))
        let navItem = UINavigationItem(title: "Авторизация")
        enterItem.isEnabled = false
        setEnterPermission(false)
        navItem.rightBarButtonItem = enterItem
        navBar.isTranslucent = false
        navBar.barTintColor = darkSchemeColor()
        navBar.alpha = 0.86
        navBar.barStyle = .black
        navBar.setItems([navItem], animated: false)
        view.addSubview(navBar)
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: UIApplication.shared.statusBarFrame.height))
        statusBarView.backgroundColor = darkSchemeColor().withAlphaComponent(0.86)
        view.addSubview(statusBarView)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    //MARK: Touch detection
    
    /**
     Detect and response to touch
     */
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        guard let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) else { return }
        let touchLocation = sender.location(in: tableView)
        if firstCell.frame.contains(touchLocation) {
            sender.cancelsTouchesInView = true
            let adressBookVC = AdressBook()
            adressBookVC.adressBookType = .schoolList
//            adressBookVC.modalTransitionStyle = .coverVertical
            adressBookVC.loginView = self
            show(adressBookVC)
            return
        }
    }
    
    @objc fileprivate func textFieldDidChange(_ textField: UITextField) {
        switch textField.tag {
        case 1: username = textField.text ?? ""
        case 2: password = textField.text ?? ""
        default: ()
        }
        enterItem.isEnabled = !username.isEmpty && !password.isEmpty && school != nil
        setEnterPermission(enterItem.isEnabled)
        if !footerText.isEmpty {
            footerText = ""
            footerTextView.attributedText = getFooterText()
            footerTextView.textAlignment = .center
        }
    }
    
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            guard let cell = tableView.cellForRow(at: IndexPath(row: textField.tag + 1, section: 0)),
                let textField = (cell.subviews.filter{ $0 is UITextField }).first else { return false }
            (textField as! UITextField).becomeFirstResponder()
        } else if !username.isEmpty && !password.isEmpty && school != nil {
            enterAction()
            textField.resignFirstResponder()
        }
        return false
    }
    
    func setError(_ title: String) {
        footerText = title
        tableView.reloadData()
    }
    
    @objc func enterAction() {
        dismiss()
//        setError("Неверные данные")
//        errorFeedback()
//        guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)),
//            let textField = (cell.subviews.filter{ $0 is UITextField }).first else { return }
//        dangle(textfield: textField as! UITextField)
//        guard let cell2 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)),
//            let textField2 = (cell2.subviews.filter{ $0 is UITextField }).first else { return }
//        dangle(textfield: textField2 as! UITextField)
        print(username)
        print(password)
        print(school!.name)
        print(school!.ID)
        print(school!.link)
    }
    
    fileprivate func getFooterText() -> NSMutableAttributedString {
        var attribute = [NSAttributedStringKey.font:  UIFont.systemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)]
        let text = "Авторизуясь в приложении, вы принимаете пользовательское соглашение: https://netschool.app"
        let string = NSMutableAttributedString(string: text + "\n\n", attributes: attribute)
        attribute = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor(hex: "EA5E54")]
        string.append(NSMutableAttributedString(string: footerText, attributes: attribute))
        return string
    }
}

extension Login: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 3 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0)
        cell.subviews.filter{ $0 is UITextField || $0 is UILabel }.forEach{ $0.removeFromSuperview() }
        guard indexPath.row != 0 else {
            cell.accessoryType = .disclosureIndicator
            var font = UIFont(name: "HelveticaNeue-Light", size: 17)!
            var label = UILabel()
            var title = "Школа"
            var size = (title as NSString).size(withAttributes: [NSAttributedStringKey.font: font])
            label.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
            label.frame = CGRect(x: 15, y: 22 - size.height/2, width: size.width, height: size.height)
            label.text = title
            label.font = font
            cell.addSubview(label)
            if let school = school {
                font = UIFont(name: "HelveticaNeue-Light", size: 16)!
                label = UILabel()
                title = school.name
                size = (title as NSString).size(withAttributes: [NSAttributedStringKey.font: font])
                label.textColor = UIColor.gray.withAlphaComponent(0.7)
                label.frame = CGRect(x: 80, y: 22 - size.height/2, width: view.frame.width-105, height: size.height)
                label.textAlignment = .right
                label.text = title
                label.font = font
                cell.addSubview(label)
            }
            return cell
        }
        let textField = indexPath.row == 1 ? UITextField() : CustomTextField()
        textField.delegate = self
        textField.tag = indexPath.row
        textField.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        textField.font = UIFont(name: "HelveticaNeue-Light", size: 17)!
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.isSecureTextEntry = indexPath.row == 2
        textField.returnKeyType = indexPath.row == 2 ? .send : .next
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        cell.accessoryType = .none
        cell.addSubview(textField)
        let (placeholder, text) = indexPath.row == 1 ? ("Логин", username) : ("Пароль", password)
        textField.text = text
        let attributes = [
            NSAttributedStringKey.foregroundColor: UIColor.gray.withAlphaComponent(0.7),
            NSAttributedStringKey.font : UIFont(name: "HelveticaNeue-Light", size: 17)!
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes:attributes)
        let yConstraint = NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1, constant: 16)
        let trailingConstraint = NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1, constant: -16)
        let heightConstraint = NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
        cell.addConstraints([yConstraint, heightConstraint, trailingConstraint, leadingConstraint])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 100 }//23 }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 23))
        footerView.backgroundColor = UIColor.clear
        footerTextView.isScrollEnabled = false
        footerTextView.isEditable = false
        footerTextView.backgroundColor = .clear
        footerTextView.attributedText = getFooterText()
        footerTextView.textAlignment = .center
        footerTextView.dataDetectorTypes = .link
        footerView.addSubview(footerTextView)
        return footerView
    }
}
