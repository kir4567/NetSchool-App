//
//  NewLetter.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 06.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
import BTNavigationDropdownMenu

class NewLetter: UIViewController  {
    
    /// View's table view
    fileprivate let tableView = UITableView()
    /// Receivers, Coppy receivers and BCC receivers
    fileprivate var mailReceivers = [MailReceiver](), ccReceivers = [MailReceiver](), bccReceivers = [MailReceiver]()
    /// Whether Coppy and BCC cells are shown
    fileprivate var isCoppySelected = false
    /// Number of rows that receiver's, Coppy receiver's or BCC receiver's labels take
    fileprivate var row = 0, ccRow = 0, bccRow = 0
    /// Cell's row index
    fileprivate var tag = 0
    /// Topic and Message of new mail message
    fileprivate var topic = "", message = ""
    /// TextView height
    fileprivate var textViewHeight:CGFloat = 40
    /// Whether keyboard is visible
    fileprivate var isKeyboardVisible = false
    /// keyboard size
    fileprivate var keyboardSize:CGFloat = 0
    /// Navigation bar height
    var navigationBarHeight:CGFloat = 0
    /// Bar button item represents sent action
    private var sendItem = UIBarButtonItem()
    /// Bar button item represents save changes action
    private var cancelItem = UIBarButtonItem()
    /// First letters of adress book users divided by groups
    fileprivate var letters = [String: [Character]]()
    fileprivate var classLetters = [Int: [Character]]()
    /// Adress book users divided by groups
    fileprivate var adressBook = [String: [Character: [AdressBookPerson]]]()
    
    fileprivate var classList = ["1 класс","2 класс","3 класс","4 класс","4 лингвистический класс","Кек класс"]
    fileprivate var classAdressBook = [Int: [Character: [AdressBookPerson]]]()
    /// List of classes
    fileprivate var classes = [AdressBookPerson]()
    /// Font for most table view cells
    fileprivate static let font = UIFont(name: "HelveticaNeue-Light", size: 16)!
    /// "A" key. Type of action
    lazy var AKey = ""
    /// index if selected row at drop menu on Mail view
    lazy var MBID = 0
    /// ID of message
    lazy var MID = ""
    /// Reference to Mail view controller to reload data in case of saved/send message
    var mailVC: Mail!
    /// Whether user need a notification when his message is read
    fileprivate var needToNotify = false
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    
    override func viewWillAppear(_ animated: Bool) {
        sendItem.isEnabled = !mailReceivers.isEmpty
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        if isCoppySelected {
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .none)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        task?.cancel()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Basic setup
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareForSetup()
        createAndSetupTableView(tableView: tableView, view: view, slf: self, navBarHeight: navigationBarHeight)
        createAndSetupNavigationBar()
    }
    
    /**
     Creates new Mail Receiver object with label
     - parameter name: Mail receiver's name
     - parameter ID: Mail receiver's ID
     - returns: Mail Receiver object
     */
    fileprivate static func createReceiver(name: String, ID: Int) -> MailReceiver {
        let person = AdressBookPerson(name: name, ID: ID)
        let name = person.name
        let font = NewLetter.font
        let size = (name as NSString).size(withAttributes: [NSAttributedStringKey.font: font])
        let label = UILabel()
        label.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        label.layer.cornerRadius = size.height/2 + 5
        label.layer.borderWidth = 1
        label.text = "       " + name
        label.font = font
        label.layer.masksToBounds = true
        let mailReceiver = MailReceiver(label: label, isSelected: false, width: size.width + size.height, height: size.height + 4, person: person)
        mailReceiver.deselect()
        mailReceiver.addRoundIcon()
        return mailReceiver
    }
    
    /// Prepare for setup
    private func prepareForSetup() {
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /// Navigation bar сreation and configuration
    private func createAndSetupNavigationBar() {
        view.backgroundColor = .white
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: navigationBarHeight))
        let navItem = UINavigationItem(title: "Новое")
        cancelItem = UIBarButtonItem(title: "Отменить", style: .plain , target: self, action: #selector(cancel))
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
        guard mailReceivers.isEmpty && message.isEmpty && topic.isEmpty && ccReceivers.isEmpty && bccReceivers.isEmpty else {
            let 🚨 = UIAlertController(title: "Вы внесли изменения.\nСохранить их?", message: nil, preferredStyle: .actionSheet)
            🚨.addDefaultAction(title: "Сохранить в черновиках") {
                self.sendMessage(isDraft: true, topic: self.topic, message: self.message)
            }
            🚨.addDefaultAction(title: "Не сохранять") {
                self.dismiss()
            }
            🚨.addCancelAction
            🚨.popoverPresentationController?.barButtonItem = cancelItem
            🚨.popoverPresentationController?.permittedArrowDirections = .up
            present(🚨)
            return
        }
        dismiss()
    }
    
    /// Sends mail
    @objc private func send() {
        view.endEditing(true)
        // Это актуально только для версий с кодировкой Windows1251
//        guard topic.isValid && message.isValid else {
//            let message = "В Вашем письме содержатся символы, неподдерживаемые почтой NetSchool. \n__________________________________\nДопустимые символы:\nabcdefghijklmnopqrstuvwxyz\nABCDEFGHIJKLKMNOPQRSTUVWXYZ\n0123456789\nабвгдеёжзийклмнопрстуфхцчшщъыьэюя\nАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ\n()<>[]{}#^*+=-_\\/|?!;:,.'\"~`№•@&%$€"
//            let 🚨 = UIAlertController(title: "Письмо содержит недопустимые символы", message: message, preferredStyle: .alert)
//            🚨.addOkAction
//            present(🚨)
//            return
//        }
        guard !topic.isEmpty else {
            let 🚨 = UIAlertController(title: "Отправить письмо без темы?", message: nil, preferredStyle: .actionSheet)
            🚨.addDefaultAction(title: "Отправить") {
                self.sendMessage(isDraft: false, topic: self.topic, message: self.message)
            }
            🚨.addCancelAction
            🚨.popoverPresentationController?.barButtonItem = sendItem
            🚨.popoverPresentationController?.permittedArrowDirections = .up
            present(🚨)
            return
        }
        self.sendMessage(isDraft: false, topic: self.topic, message: self.message)
    }
    
    /**
     Sends mail
     - parameter draft: Whether message is draft
     - parameter topic: Topic of mail message
     - parameter message: Body of mail message
     */
    private func sendMessage(isDraft: Bool, topic: String, message: String) {
        
    }
    
    // MARK: Keyboard setup
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        isKeyboardVisible = true
        let keyboard = view.convert(keyboardFrame, from: view.window)
        keyboardSize = tableView.frame.size.height - keyboard.origin.y
        if #available(iOS 11.0, *) {
            if let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                keyboardSize += bottomSafeArea + navigationBarHeight
            }
        }
        updateConstraint(newValue: keyboardSize, view: view, tableView: tableView)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyboardVisible = false
        updateConstraint(newValue: 0, view: view, tableView: tableView)
    }
    
    /**
     Presents adress book view
     */
    private func openAdressBook() {
        let adressBookVC = AdressBook()
        adressBookVC.modalTransitionStyle = .coverVertical
        adressBookVC.adressBookType = .defaultList
        adressBookVC.letterView = self
        present(adressBookVC)
    }
    
    //MARK: Touch detection
    
    /**
     Detect and response to touch
     */
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        sender.cancelsTouchesInView = true
        
        guard let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) else { return }
        let touchLocation = sender.location(in: firstCell)
        guard !firstCell.frame.contains(touchLocation) else {
            // To whom
            deleteRow()
            detectTouch(inRow: 0, withReceivers: mailReceivers, atLocation: touchLocation, firstCell: firstCell, receiversType: 0)
            sendItem.isEnabled = !mailReceivers.isEmpty
            return
        }
        
        guard let secondCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) else { return }
        guard !secondCell.frame.contains(touchLocation) else {
            if isCoppySelected {
                // Coppy
                detectTouch(inRow: 1, withReceivers: ccReceivers, atLocation: touchLocation, firstCell: firstCell, receiversType: 1)
            } else {
                // Coppy / BCC
                isCoppySelected = true
                tableView.insertRows(at: [IndexPath(row: 2, section: 0), IndexPath(row: 3, section: 0)], with: .automatic)
                tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            }
            return
        }
        
        guard let thirdCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) else { return }
        guard !thirdCell.frame.contains(touchLocation) else {
            if isCoppySelected {
                // BCC
                detectTouch(inRow: 2, withReceivers: bccReceivers, atLocation: touchLocation, firstCell: firstCell, receiversType: 2)
            } else {
                // Topic
                deleteRow()
                sender.cancelsTouchesInView = false
            }
            return
        }
        deleteRow()
        sender.cancelsTouchesInView = false
    }
    
    /**
     Detect mail receiver that was tapped
     - parameter row: Cell's row
     - parameter receivers: All cell's mail receivers
     - parameter touchLocation: Touch location coordinates
     - parameter firstCell: Forst cell in table view
     */
    private func detectTouch(inRow row: Int, withReceivers receivers: [MailReceiver], atLocation touchLocation: CGPoint, firstCell: UITableViewCell, receiversType : UInt8) {
        var receivers = receivers
        for index in 0..<receivers.count {
            let label = receivers[index].label
            let labelFrame = firstCell.convert(label.frame, from: label.superview)
            
            guard labelFrame.contains(touchLocation) else { continue }
            for location in label.subviews {
                let frame = CGRect(x: labelFrame.minX, y: labelFrame.minY, width: location.frame.width + 6, height: location.frame.height + 6)
                if receivers[index].isSelected && frame.contains(touchLocation) {
                    receivers.remove(at: index)
                    switch receiversType {
                    case 0: mailReceivers = receivers
                    case 1: ccReceivers = receivers
                    default: bccReceivers = receivers
                    }
                    tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                    return
                }
            }
            receivers[index].select()
            switch receiversType {
            case 0: mailReceivers = receivers
            case 1: ccReceivers = receivers
            default: bccReceivers = receivers
            }
            tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
            return
        }
        tag = row
        openAdressBook()
    }
    
    /**
     Converts Coppy and BCC rows into one Coppy / BCC
     */
    fileprivate func deleteRow() {
        guard isCoppySelected && ccReceivers.isEmpty && bccReceivers.isEmpty && !needToNotify else { return }
        isCoppySelected = false
        guard let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) else { return }
        cell.subviews.filter{ $0 is UIImageView || $0 is UISwitch }
            .forEach{ $0.removeFromSuperview() }
        for case let label as UILabel in cell.subviews {
            label.text = "Копия/Ск. копия/Ув. о прочтении"
            label.frame = CGRect(x: label.frame.minX, y: label.frame.minY, width: view.frame.width - 52, height: label.frame.height)
        }
        tableView.deleteRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .automatic)
    }
}

//MARK: - TextField extension
extension NewLetter: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        topic = textField.text ?? ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.subviews.filter{$0 is UITextView }.forEach{ $0.becomeFirstResponder() }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        deleteRow()
    }
}

//MARK: - Text View extension
extension NewLetter: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        message = textView.text
        let textSize = CGSize(width: CGFloat(textView.frame.size.width), height: CGFloat(MAXFLOAT))
        let textViewHeight = CGFloat(textView.sizeThatFits(textSize).height) + 10
        self.textViewHeight = textViewHeight
        tableView.updateCellHeigths()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        deleteRow()
    }
}

//MARK: - TableView Setup
extension NewLetter: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Basic setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isCoppySelected ? 6 : 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return CGFloat(32*row + 40)
        case 1,2: return isCoppySelected ? CGFloat(32*(indexPath.row == 1 ? ccRow : bccRow) + 40) : 40
        case 3: return isCoppySelected ? 40 : heightForTextView()
        case 4: return 40
        case 5: return heightForTextView()
        default: return 40
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        cell.layoutMargins = .zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        cell.subviews.filter{ $0 is UILabel || $0 is UIImageView || $0 is UITextField || $0 is UITextView || $0 is UISwitch }
            .forEach{ $0.removeFromSuperview() }
        
        /// Adds UISwitch to cell
        func createSwitch() {
            createCellNameLabel("Уведомить о прочтении:")
            let cellSwitch = UISwitch()
            cellSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            cellSwitch.onTintColor = .schemeTintColor
            cellSwitch.translatesAutoresizingMaskIntoConstraints = false
            cellSwitch.isOn = needToNotify
            cellSwitch.addTarget(self, action: #selector(self.switchStateChanged), for: .valueChanged)
            cell.addSubview(cellSwitch)
            let topConstraint = NSLayoutConstraint(item: cellSwitch, attribute: .topMargin, relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1, constant: cell.frame.height/2 - cellSwitch.frame.height*0.75/2)
            let trailingConstraint = NSLayoutConstraint(item: cellSwitch, attribute: .trailingMargin, relatedBy: .equal, toItem: cell.contentView, attribute: .trailing, multiplier: 1, constant: -10)
            view.addConstraints([topConstraint, trailingConstraint])
        }
        
        /**
         Adds cell name label
         - parameter title: Title for label
         */
        func createCellNameLabel(_ title: String) {
            let font = UIFont(name: "HelveticaNeue-Light", size: 15)!
            let size = (title as NSString).size(withAttributes: [NSAttributedStringKey.font: font])
            let label = UILabel(frame: CGRect(x: 8, y: 20 - size.height/2, width: size.width, height: size.height))
            label.text = title
            label.font = font
            label.textColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
            cell.addSubview(label)
        }
        
        /// Adds topic label
        func createTopic() {
            createCellNameLabel("Тема:")
            let width = cell.subviews.filter{ $0 is UILabel }.first?.frame.width ?? 0
            let textField = UITextField()
            textField.delegate = self
            textField.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
            textField.font = NewLetter.font
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.text = topic
            cell.addSubview(textField)
            let topConstraint = NSLayoutConstraint(item: textField, attribute: .topMargin, relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1, constant: 8)
            let leadingConstraint = NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: width + 16)
            let trailingConstraint = NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailing, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
            view.addConstraints([topConstraint, heightConstraint, trailingConstraint, leadingConstraint])
        }
        
        /// Adds add button to cell
        func createAddButton() {
            let addImageView = UIImageView(frame: CGRect(x: Int(view.frame.width - 30), y: 14*row + 10, width: 20, height: 20))
            addImageView.image = UIImage(named: "add_user")
            addImageView.setImageBackgroundColor(.schemeTintColor)
            addImageView.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(addImageView)
            let topConstraint = NSLayoutConstraint(item: addImageView, attribute: .topMargin, relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1, constant: 18)
            let trailingConstraint = NSLayoutConstraint(item: addImageView, attribute: .trailingMargin, relatedBy: .equal, toItem: cell.contentView, attribute: .trailing, multiplier: 1, constant: -18)
            let widthConstraint = NSLayoutConstraint(item: addImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
            let heightConstraint = NSLayoutConstraint(item: addImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
            view.addConstraints([topConstraint, trailingConstraint, widthConstraint, heightConstraint])
        }
        
        /// Adds text view to cell
        func createTextView() {
            cell.backgroundColor = .white
            let textView = UITextView()
            textView.font = NewLetter.font
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
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
        }
        
        /**
         Adds all mail receiver labels to cell
         - parameter receivers: All mail receivers to be added
         - parameter row: Number of rows that mail receivers labels take
         - parameter title: Cell title
         */
        func setup(receivers: [MailReceiver], andRow row: Int, title: String) -> Int {
            var row = 0
            createCellNameLabel(title)
            var x:CGFloat = 12 + (cell.subviews.filter{ $0 is UILabel }.first?.frame.width ?? 0)
            let addButtonPadding:CGFloat = 32
            for receiver in receivers {
                let height = receiver.height
                let width = receiver.width + 20
                var y = 32*row + 17 - Int(height/2)
                if x + (row == 0 ? addButtonPadding : 0) + width >= view.frame.size.width {
                    row += 1
                    y += 32
                    x = 4
                }
                receiver.label.frame = CGRect(x: Int(x), y: y, width: Int(width), height: Int(height) + 6)
                x += width + 2
                cell.addSubview(receiver.label)
            }
            createAddButton()
            return row
        }
        
        switch indexPath.row {
        case 0:
            row = setup(receivers: mailReceivers, andRow: row, title: "Кому:")
        case 1:
            if isCoppySelected {
                ccRow = setup(receivers: ccReceivers, andRow: ccRow, title: "Копия:")
            } else {
                createCellNameLabel("Копия/Ск. копия/Ув. о прочтении")
            }
        case 2:
            if isCoppySelected {
                bccRow = setup(receivers: bccReceivers, andRow: bccRow, title: "Скрытая копия:")
            } else {
                createTopic()
            }
        case 3:
            isCoppySelected ? createSwitch() : createTextView()
        case 4:
            createTopic()
        case 5:
            createTextView()
        default: ()
        }
        return cell
    }
    
    /// Response to UISwitch state changed
    @objc private func switchStateChanged(_ sender: UISwitch) {
        needToNotify = sender.isOn
    }
    
    /// Calculates Text View height
    private func heightForTextView() -> CGFloat {
        var minHeight = view.frame.height - CGFloat(32*(ccRow + bccRow + row) + 40*(isCoppySelected ? 5 : 3)) - navigationBarHeight - UIApplication.shared.statusBarFrame.height
        if isKeyboardVisible { minHeight -= keyboardSize }
        return minHeight < textViewHeight ? textViewHeight : minHeight
    }
}

// MARK: - MailReceiver Class
fileprivate class MailReceiver {
    /// Label represents mail receiver
    fileprivate let label: UILabel
    /// Whether mail receiver is selected
    fileprivate var isSelected: Bool
    /// Label width and height
    fileprivate var width, height: CGFloat
    /// Represents mail receiver name and ID
    private let person: AdressBookPerson
    
    init(label: UILabel, isSelected: Bool, width: CGFloat, height: CGFloat, person: AdressBookPerson) {
        self.label = label
        self.isSelected = isSelected
        self.width = width
        self.height = height
        self.person = person
    }
    
    /**
     Increase mail receiver width
     */
    func addWidth(_ width: CGFloat) { self.width += width }
    /**
     - returns: Mail receiver ID
     */
    func getID() -> Int { return person.ID }
    /**
     - returns: Mail receiver name
     */
    func getName() -> String { return person.name }
    /**
     Select mail receiver
     */
    func select() {
        guard !isSelected else {
            deselect()
            return
        }
        isSelected = true
        label.backgroundColor = .schemeTintColor
        label.textColor = UIColor.white
        label.layer.borderColor = darkSchemeColor().cgColor
        label.subviews.forEach{$0.removeFromSuperview()}
        let imageView = UIImageView(frame: CGRect(x: 4, y: 4, width: height - 2, height: height - 2))
        imageView.image = UIImage(named: "clear")
        label.addSubview(imageView)
    }
    
    /// Deselect mail receiver
    func deselect() {
        isSelected = false
        label.backgroundColor = .white
        label.textColor = UIColor(red: 58/255, green: 58/255, blue: 58/255, alpha: 1)
        label.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        label.subviews.forEach{$0.removeFromSuperview()}
        addRoundIcon()
    }
    
    /// Add round icon
    func addRoundIcon() {
        let imageView = UIImageView(frame: CGRect(x: 4, y: 4, width: height - 2, height: height - 2))
        imageView.setImage(string: label.text!, multiply: 1.05)
        label.addSubview(imageView)
    }
}

//MARK: - Adress Book Person Struct
/// Struct represents user or title group of users
struct AdressBookPerson {
    var name: String
    var ID: Int
}

enum AdressBookType {
    case classes, schoolList, defaultList, undefined
}

// MARK: - Receivers Class
class AdressBook: UIViewController, UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    // Table View and Search Controller constants
    var adressBookType:AdressBookType = .undefined
    
    
    let tableView = UITableView()
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    /// Drop down menu
    fileprivate var menuView: BTNavigationDropdownMenu?
    /// Link to new letter view
    fileprivate var letterView: NewLetter?
    /// Link to new login view
    var loginView: Login?
    /// First letters of sorted users
    fileprivate var sortedLetters = [Character]()
    /// Users responding to searchbar filter
    fileprivate var filteredUsers = [Character: [AdressBookPerson]]()
    /// Users responding to searchbar filter
    fileprivate var filteredSchools = [Character: [School]]()
    /// Represents view status
    var status: Status = .loading
    /// Selected group in drop down menu
    fileprivate var selectedGroup = 0
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    /// Drop down menu titles
    fileprivate var groups = [
        Group(name: "Все пользователи", ID: "U"), Group(name: "Учителя", ID: "T"),
        Group(name: "Администраторы", ID: "A"), Group(name: "Завучи", ID: "P"),
        Group(name: "Все сотрудники", ID: "S"), Group(name: "Родители", ID: "R"),
        Group(name: "Ученики", ID: "D")
    ]
    
    fileprivate struct Group {
        var name, ID: String
    }
    
    let navItem = UINavigationItem(title: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareForSetup()
        createAndSetupTableView(tableView: tableView, view: view, slf: self, navBarHeight: letterView?.navigationBarHeight ?? 44, true)
        setupSearchController()
        if adressBookType == .defaultList || adressBookType == .classes {
            setupDropDownMenu()
        }
        createAndSetupNavigationBar()
        getData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        task?.cancel()
    }
    
    /// Prepare for setup
    private func prepareForSetup() {
        tableView.sectionIndexColor = darkSchemeColor()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        if adressBookType == .defaultList {
            filteredUsers = letterView?.adressBook["U"] ?? [:]
            sortedLetters = letterView?.letters["U"] ?? []
        }
    }
    
    // MARK: UI Setup
    
    /// Search controller configuration
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.showsBookmarkButton = false
        searchController.searchBar.layer.borderWidth = 1
        searchController.searchBar.layer.borderColor = UIColor.white.cgColor
        searchController.searchBar.sizeToFit()
        if #available(iOS 9.0, *) {
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey.font : NewLetter.font], for: .normal)
        }
        searchController.searchBar.setValue("Отменить", forKey:"_cancelButtonText")
        searchController.searchBar.tintColor = darkSchemeColor()
        guard searchController.searchBar.subviews.count > 0 else { return }
        guard let searchField = (searchController.searchBar.subviews[0].subviews.filter{ $0 is UITextField }).first as? UITextField else { return }
        searchField.clearButtonMode = .never
        if #available(iOS 9.0, *) { searchField.font = NewLetter.font }
        searchField.textColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        searchField.backgroundColor = .white
        searchField.attributedPlaceholder = NSAttributedString(string: "Поиск", attributes: [NSAttributedStringKey.font : UIFont(name: "HelveticaNeue", size: 17)!])
    }
    
    /// Navigation bar сreation and configuration
    private func createAndSetupNavigationBar() {
        view.backgroundColor = .white
        let screenSize: CGRect = UIScreen.main.bounds
        let height = letterView?.navigationBarHeight ?? loginView?.navigationBarHeight ?? 44
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: height))
        switch adressBookType {
        case .defaultList:
            navItem.leftBarButtonItem = createBarButtonItem(imageName: "back", selector: #selector(cancel))
            navItem.rightBarButtonItem = createBarButtonItem(imageName: "users", selector: #selector(showClasses))
        case .schoolList:
            navItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain , target: self, action: #selector(cancel))
        case .classes:
            navItem.leftBarButtonItem = createBarButtonItem(imageName: "back", selector: #selector(cancel))
        default:
            ()
        }
        navBar.isTranslucent = false
        navBar.barTintColor = darkSchemeColor()
        navBar.alpha = 0.86
        navBar.setItems([navItem], animated: false)
        view.addSubview(navBar)
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: UIApplication.shared.statusBarFrame.height))
        statusBarView.backgroundColor = darkSchemeColor().withAlphaComponent(0.86)
        view.addSubview(statusBarView)
        navItem.titleView = menuView
    }
    
    private func createDropDownMenu() -> BTNavigationDropdownMenu? {
        if adressBookType == .defaultList {
            return BTNavigationDropdownMenu(title: "Все пользователи", items: groups.map{$0.name} as [AnyObject], schemeColor: lightSchemeColor())
        }
        if let letterView = letterView, letterView.classList.count > 0 {
            return BTNavigationDropdownMenu(title: letterView.classList[0], items: letterView.classList as [AnyObject], schemeColor: lightSchemeColor())
        }
        return nil
    }
    
    /// Drop down menu configuration
    private func setupDropDownMenu() {
        menuView = createDropDownMenu()
        menuView?.isScrollEnabled = true
        menuView?.cellHeight = 44
        menuView?.cellBackgroundColor = UIColor.white.withAlphaComponent(0.9) //lightSchemeColor()
        menuView?.cellSelectionColor = UIColor(red: 239/255, green: 238/255, blue: 244/255, alpha: 1) //lightSchemeColor()
        menuView?.shouldKeepSelectedCellColor = true
        menuView?.cellTextLabelColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)//.schemeTitleColor
        menuView?.cellTextLabelFont = .systemFont(ofSize: 17)
        menuView?.cellTextLabelAlignment = .left
        menuView?.arrowPadding = 15
        menuView?.animationDuration = 0.3
        menuView?.maskBackgroundColor = .black
        menuView?.maskBackgroundOpacity = 0.3
        menuView?.menuTitleColor = .schemeTitleColor
        menuView?.arrowTintColor = .schemeTitleColor
        menuView?.didSelectItemAtIndexHandler = { indexPath in
            if self.selectedGroup != indexPath {
                self.searchController.searchBar.resignFirstResponder()
                selectionFeedback()
                self.selectedGroup = indexPath
                self.filteredUsers.removeAll()
                self.sortedLetters.removeAll()
                if self.adressBookType == .defaultList {
                    if (self.letterView?.adressBook[self.groups[indexPath].ID] ?? [:]).isEmpty {
                        self.tableView.tableHeaderView = nil
                        self.tableView.reloadData()
//                      self.formUrl()
                    } else {
                        self.setupSearchBar()
                        self.updateSearchResults(for: self.searchController)
                    }
                } else if self.adressBookType == .classes {
                    if (self.letterView?.classAdressBook[indexPath] ?? [:]).isEmpty {
                        self.tableView.tableHeaderView = nil
                        self.tableView.reloadData()
//                       self.formUrl()
                    } else {
                        self.setupSearchBar()
                        self.updateSearchResults(for: self.searchController)
                    }
                }
            }
        }
    }
    
    func setupSearchBar() {
        let searchContainerView = UIView(frame: self.searchController.searchBar.frame)
        searchContainerView.layer.masksToBounds = true
        searchContainerView.clipsToBounds = true
        self.tableView.tableHeaderView = searchContainerView
        self.searchController.searchBar.layer.masksToBounds = true
        self.searchController.searchBar.clipsToBounds = true
        searchContainerView.addSubview(self.searchController.searchBar)
    }
    
    // MARK: Keyboard setup
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboard = view.convert(keyboardFrame, from: view.window)
        updateConstraint(newValue: view.frame.size.height - keyboard.origin.y, view: view, tableView: tableView)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        updateConstraint(newValue: 0, view: view, tableView: tableView)
    }
    
    //MARK: Data Loading
    
    /// Get list of users
    private func getData() {
        guard filteredUsers.isEmpty || filteredSchools.isEmpty else {
            self.setupSearchBar()
            return
        }
        loadAdressBook()
    }
    
    func internetConnectionAppeared() {
        guard status == .error else { return }
        status = .loading
        tableView.reloadData()
    }
    
    
    /**
     Loads users
     */
    private func loadAdressBook() {
        switch adressBookType {
        case .schoolList:
            loginView?.adressBook = [
                "Е": [School(name: "Европейская гимназия", link: "http://62.117.74.43/", letter: "ЕГ", ID: 1)],
                "Н": [School(name: "Новая гуманитарная школа", link: "http://91.200.226.70/", letter: "НГ", ID: 2)],
                "К": [School(name: "Школа \"26 Кадр\"", link: "http://keks.com", letter: "К", ID: 3)],
                "О": [School(name: "СОШ «Образование Плюс»", link: "http://123.67.92.1", letter: "ОП", ID: 4)],
                "1": [School(name: "Школа №1489", link: "http://school-1489.ru", letter: "Ш", ID: 5),School(name: "Школа №1329", link: "http://1329school.ru", letter: "Ш", ID: 6),School(name: "Школа №157", link: "http://157.43.54.23", letter: "Ш", ID: 7)]
            ]
            loginView?.letters = ["1", "Е", "Н", "К", "О"]
            status = .successful
            self.setupSearchBar()
            self.updateSearchResults(for: self.searchController)
        case .defaultList:
            letterView?.adressBook["U"] = [
                "К": [AdressBookPerson(name: "Корнакова Ольга Алексеевна", ID: 1),AdressBookPerson(name: "Корнаков Кирилл", ID: 2),AdressBookPerson(name: "Корнаков Максим", ID: 3),AdressBookPerson(name: "Корнаков Олег Анатольевич", ID: 4)],
                "Р": [AdressBookPerson(name: "Рябцев Кирилл", ID: 6),AdressBookPerson(name: "Рябцева Мария", ID: 5),AdressBookPerson(name: "Рябцева Ольга Витальевна", ID: 7)]
            ]
            letterView?.adressBook["D"] = [
                "К": [AdressBookPerson(name: "Корнаков Кирилл", ID: 2),AdressBookPerson(name: "Корнаков Максим", ID: 3)],
                "Р": [AdressBookPerson(name: "Рябцев Кирилл", ID: 6),AdressBookPerson(name: "Рябцева Мария", ID: 5)]
            ]
            letterView?.adressBook["R"] = [
                "К": [AdressBookPerson(name: "Корнакова Ольга Алексеевна", ID: 1),AdressBookPerson(name: "Корнаков Олег Анатольевич", ID: 4)],
                "Р": [AdressBookPerson(name: "Рябцева Ольга Витальевна", ID: 7)]
            ]
            letterView?.letters["U"] = ["К", "Р"]
            letterView?.letters["D"] = ["К", "Р"]
            letterView?.letters["R"] = ["К", "Р"]
            status = .successful
            self.setupSearchBar()
            self.updateSearchResults(for: self.searchController)
        case .classes:
            letterView?.classAdressBook[1] = [
                "К": [AdressBookPerson(name: "Корнакова Ольга Алексеевна", ID: 1),AdressBookPerson(name: "Корнаков Кирилл", ID: 2),AdressBookPerson(name: "Корнаков Максим", ID: 3),AdressBookPerson(name: "Корнаков Олег Анатольевич", ID: 4)],
                "Р": [AdressBookPerson(name: "Рябцев Кирилл", ID: 6),AdressBookPerson(name: "Рябцева Мария", ID: 5),AdressBookPerson(name: "Рябцева Ольга Витальевна", ID: 7)]
            ]
            letterView?.classAdressBook[2] = [
                "К": [AdressBookPerson(name: "Корнаков Кирилл", ID: 2),AdressBookPerson(name: "Корнаков Максим", ID: 3)],
                "Р": [AdressBookPerson(name: "Рябцев Кирилл", ID: 6),AdressBookPerson(name: "Рябцева Мария", ID: 5)]
            ]
            letterView?.classAdressBook[3] = [
                "К": [AdressBookPerson(name: "Корнакова Ольга Алексеевна", ID: 1),AdressBookPerson(name: "Корнаков Олег Анатольевич", ID: 4)],
                "Р": [AdressBookPerson(name: "Рябцева Ольга Витальевна", ID: 7)]
            ]
            letterView?.classLetters[1] = ["К", "Р"]
            letterView?.classLetters[2] = ["К", "Р"]
            letterView?.classLetters[3] = ["К", "Р"]
            status = .successful
            self.setupSearchBar()
            self.updateSearchResults(for: self.searchController)
        default:
            ()
        }
    }
    
    //MARK: Closing View
    
    /// Closes adress book
    @objc private func cancel() {
        if menuView?.isShown ?? false { menuView?.hide() }
        dismiss()
    }
    
    @objc private func showClasses() {
        let keybordConstant = view.constraints.filter{ $0.firstAttribute == .bottomMargin && $0.secondItem is UITableView }.map{$0.constant}.first
        if Int(keybordConstant ?? 0) == 0 {
            let adressBookVC = AdressBook()
            adressBookVC.adressBookType = .classes
            adressBookVC.modalTransitionStyle = .coverVertical
            adressBookVC.letterView = self.letterView
            self.present(adressBookVC)
        }
    }
    
    deinit {
        searchController.view.removeFromSuperview()
    }
}

//MARK: - Table View Protocols
extension AdressBook: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Basic setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard sortedLetters.count > section else { return 0 }
        switch adressBookType {
        case .schoolList:
            return (filteredSchools[sortedLetters[section]] ?? []).count
        case .defaultList, .classes:
            return (filteredUsers[sortedLetters[section]] ?? []).count
        default:
            return 0
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int { return sortedLetters.isEmpty ? 1 : sortedLetters.count }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? { return sortedLetters.map{String($0)} }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard sortedLetters.count > section else { return nil }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 22))
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: 40, height: 22))
        label.font = UIFont(name: "HelveticaNeue", size: 15) ?? .systemFont(ofSize: 15)
        label.text = String(sortedLetters[section])
        view.addSubview(label)
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1).cgColor, UIColor.white.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height)
        view.layer.insertSublayer(gradient, at: 0)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard sortedLetters.count > section else { return 0 }
        return 22
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell     {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.setSelection
        
        switch adressBookType {
        case .defaultList, .classes:
            let imageView = UIImageView(frame: CGRect(x: 8, y: 0, width: 35, height: 35 ))
            let person = filteredUsers[sortedLetters[indexPath.section]]?[indexPath.row]
            imageView.setImage(string: person!.name)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(imageView)
            let label = UILabel()
            label.text = person!.name
            label.font = UIFont(name: "HelveticaNeue", size: 16) ?? UIFont.systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
            cell.addSubview(label)
            let topConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: cell.contentView, attribute: .centerY, multiplier: 1, constant: 22)
            var leadingConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 16)
            var widthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            cell.addConstraints([topConstraint, leadingConstraint, widthConstraint, heightConstraint])
            leadingConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 60)
            widthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cell.frame.width - 50)
            let centerAllignment = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: cell.contentView, attribute: .centerY, multiplier: 1, constant: 22)
            cell.addConstraints([centerAllignment, widthConstraint, leadingConstraint])
        case .schoolList:
            let imageView = UIImageView(frame: CGRect(x: 8, y: 0, width: 45, height: 45 ))
            let person = filteredSchools[sortedLetters[indexPath.section]]?[indexPath.row]
            imageView.setImage(string: person!.name, person!.letter)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(imageView)
            let label = UILabel()
            label.text = person!.name
            label.font = UIFont(name: "HelveticaNeue", size: 16) ?? UIFont.systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
            cell.addSubview(label)
            let detailLabel = UILabel()
            detailLabel.text = person!.link
            detailLabel.font = UIFont(name: "HelveticaNeue", size: 14) ?? UIFont.systemFont(ofSize: 14)
            detailLabel.textColor = UIColor.gray.withAlphaComponent(0.7)
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(detailLabel)
            var topConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: cell.contentView, attribute: .centerY, multiplier: 1, constant: 30)
            var leadingConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 16)
            var widthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 45)
            let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 45)
            cell.addConstraints([topConstraint, leadingConstraint, widthConstraint, heightConstraint])
            leadingConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 75)
            widthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cell.frame.width - 50)
            topConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1, constant: 27)
            cell.addConstraints([topConstraint, widthConstraint, leadingConstraint])
            leadingConstraint = NSLayoutConstraint(item: detailLabel, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 75)
            widthConstraint = NSLayoutConstraint(item: detailLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cell.frame.width - 50)
            topConstraint = NSLayoutConstraint(item: detailLabel, attribute: .top , relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1, constant: 32)
            cell.addConstraints([topConstraint, widthConstraint, leadingConstraint])
        default:
            ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch adressBookType {
        case .defaultList, .classes:
            guard let person = filteredUsers[sortedLetters[indexPath.section]]?[indexPath.row],
            let letterView = letterView else { return }
            let mailReceiver = NewLetter.createReceiver(name: person.name, ID: person.ID)
            switch letterView.tag {
            case 0:
                if (letterView.mailReceivers.filter{ $0.getName() == mailReceiver.getName() }).isEmpty {
                    letterView.mailReceivers.append(mailReceiver)
                }
            case 1:
                if (letterView.ccReceivers.filter{ $0.getName() == mailReceiver.getName() }).isEmpty {
                    letterView.ccReceivers.append(mailReceiver)
                }
            case 2:
                if (letterView.bccReceivers.filter{ $0.getName() == mailReceiver.getName() }).isEmpty {
                    letterView.bccReceivers.append(mailReceiver)
                }
            default: ()
            }
        case .schoolList:
            guard let school = filteredSchools[sortedLetters[indexPath.section]]?[indexPath.row] else { return }
            loginView!.school = school
        default:
            ()
        }
        searchController.isActive = false
        if adressBookType == .classes {
            self.presentingViewController?.presentingViewController?.dismiss(animated: true)
        } else {
            dismiss()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return adressBookType == .schoolList ? 60 : 44
    }
    
    //MARK: Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch adressBookType {
        case .defaultList:
            return (letterView?.adressBook[groups[selectedGroup].ID] ?? [:]).isEmpty ? 35 : 0
        case .schoolList:
            return (loginView?.adressBook ?? [:]).isEmpty ? 35 : 0
        case .classes:
            return (letterView?.classAdressBook[selectedGroup] ?? [:]).isEmpty ? 35 : 0
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch adressBookType {
        case .defaultList:
            guard let letterView = letterView,
                (letterView.adressBook[groups[selectedGroup].ID] ?? [:]).isEmpty else { return nil }
            switch status {
            case .loading: return view.loadingFooterView()
            case .error: return view.errorFooterView()
            default:
                let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 23))
                footerView.backgroundColor = UIColor.clear
                let footerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: tableView.frame.size.width - 20, height: 23))
                footerLabel.addProperties
                footerLabel.text = "Раздел пуст"
                footerView.addSubview(footerLabel)
                return footerView
            }
        case .schoolList:
            guard let loginView = loginView,
                loginView.adressBook.isEmpty else { return nil }
            switch status {
            case .loading: return view.loadingFooterView()
            case .error: return view.errorFooterView()
            default:
                let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 23))
                footerView.backgroundColor = UIColor.clear
                let footerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: tableView.frame.size.width - 20, height: 23))
                footerLabel.addProperties
                footerLabel.text = "Раздел пуст"
                footerView.addSubview(footerLabel)
                return footerView
            }
        case .classes:
            guard let letterView = letterView,
                (letterView.classAdressBook[selectedGroup] ?? [:]).isEmpty else { return nil }
            switch status {
            case .loading: return view.loadingFooterView()
            case .error: return view.errorFooterView()
            default:
                let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 23))
                footerView.backgroundColor = UIColor.clear
                let footerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: tableView.frame.size.width - 20, height: 23))
                footerLabel.addProperties
                footerLabel.text = "Раздел пуст"
                footerView.addSubview(footerLabel)
                return footerView
            }
        default:
            return nil
        }
    }
}

// MARK: - Filtering Searshind Results
extension AdressBook: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        switch adressBookType {
        case .defaultList:
            guard !searchText.isEmpty else {
                filteredUsers = letterView?.adressBook[groups[selectedGroup].ID] ?? [:]
                sortedLetters = letterView?.letters[groups[selectedGroup].ID] ?? []
                tableView.reloadData()
                return
            }
            filteredUsers.removeAll()
            sortedLetters.removeAll()
            for group in letterView?.adressBook[groups[selectedGroup].ID] ?? [:] {
                let filteredGroup = group.value.filter{ $0.name.lowercased().contains(searchText.lowercased()) }
                if !filteredGroup.isEmpty {
                    sortedLetters.append(group.key)
                    filteredUsers[group.key] = filteredGroup
                }
            }
        case .schoolList:
            guard !searchText.isEmpty else {
                filteredSchools = loginView?.adressBook ?? [:]
                sortedLetters = loginView?.letters ?? []
                tableView.reloadData()
                return
            }
            filteredSchools.removeAll()
            sortedLetters.removeAll()
            for group in loginView?.adressBook ?? [:] {
                let filteredGroup = group.value.filter{ $0.name.lowercased().contains(searchText.lowercased()) }
                if !filteredGroup.isEmpty {
                    sortedLetters.append(group.key)
                    filteredSchools[group.key] = filteredGroup
                }
            }
        case .classes:
            guard !searchText.isEmpty else {
                filteredUsers = letterView?.classAdressBook[selectedGroup] ?? [:]
                sortedLetters = letterView?.classLetters[selectedGroup] ?? []
                tableView.reloadData()
                return
            }
            filteredUsers.removeAll()
            sortedLetters.removeAll()
            for group in letterView?.classAdressBook[selectedGroup] ?? [:] {
                let filteredGroup = group.value.filter{ $0.name.lowercased().contains(searchText.lowercased()) }
                if !filteredGroup.isEmpty {
                    sortedLetters.append(group.key)
                    filteredUsers[group.key] = filteredGroup
                }
            }
        default:
            ()
        }
        sortedLetters.sort(by: {$0 < $1})
        tableView.reloadData()
    }
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

fileprivate func createAndSetupTableView(tableView: UITableView, view: UIView, slf: UIViewController, navBarHeight: CGFloat, _ iaAdressBook: Bool = false) {
    var topConstraintConstant:CGFloat = -UIApplication.shared.statusBarFrame.height - navBarHeight
    if #available(iOS 11.0, *), (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) > 0  {
        topConstraintConstant += navBarHeight
    }
    tableView.delegate = slf as? UITableViewDelegate
    tableView.dataSource = slf as? UITableViewDataSource
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 40
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    view.addSubview(tableView)
    tableView.addConstraints(view: view, topConstraintConstant:  topConstraintConstant, iaAdressBook)
}




