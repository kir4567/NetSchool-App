//
//  Details.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 07.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
//import Kanna
import SafariServices
import MessageUI

enum DetailType {
    case diary, mail, posts, forum, undefined
}


class Details: UIViewController, UITextViewDelegate {
    
//    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var detailType: DetailType = .undefined
    
    // For Diary
    var lesson: JournalLesson?, fullDate: String?
    // For Forum
    var comment: ForumDetailTopic?, topic: String?
    // For Mail
    var message: MailMessage?, key: Int?, mailVC: Mail?, indexPath: IndexPath?
    /// pointer to Diary Content View Controller
    weak var diaryVC: DiaryContentViewController?
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    /// represents navigation bar height
    var navigationBarHeight: CGFloat = 0
    /// array of attached files
    lazy var files = [File]()
    /// attributed string with all text
    var attrStr: NSMutableAttributedString?
    /// view status
    var status: Status = .loading
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "mailto" {
            if interaction == .invokeDefaultAction {
                openMail(URL.absoluteString.removePart("mailto:"))
            }
            return false
        }
        return true
    }
    
    /// Same function as above, but for iOS versions lower than 10
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "mailto" {
            openMail(URL.absoluteString.removePart("mailto:"))
            return false
        }
        return true
    }
    
    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        switch detailType {
        case .diary:
            if lesson?.homework ?? false {
                let defaults = UserDefaults.standard
                let not = defaults.bool(forKey: self.lesson!.key) ? "не" : ""
                let action = UIPreviewAction(title: "Отметить как \(not)выполненное", style: .default) { _,_ in
                    self.setDone()
                    self.diaryVC?.tableView.reloadData()
                }
                return [action]
            }
        case .mail:
            guard let mailVC = mailVC,
                let indexPath = indexPath else { return [] }
            var actions = [UIPreviewAction]()
            let title = UserDefaults.standard.bool(forKey: "m\(message!.messageID)") ? "Снять\nотметку" : "Пометить"
            let markAction = UIPreviewAction(title: title, style: .default) { _,_ in
                let def = UserDefaults.standard
                let value = def.bool(forKey: "m\(self.message!.messageID)")
                def.setValue(!value, forKey: "m\(self.message!.messageID)")
                def.synchronize()
                mailVC.tableView.reloadRows(at: [indexPath], with: .none)
            }
            actions.append(markAction)
            func createPreviewAction(title: String, key: String) {
                actions.append(UIPreviewAction(title: title, style: .default) { _,_ in
                    mailVC.messageAction(key: key, row: indexPath.row)
                })
            }
            createPreviewAction(title: "Переслать", key: "F")
            createPreviewAction(title: "Ответить", key: "R")
            createPreviewAction(title: "Ответить всем", key: "A")
            if self.key == 1 {
                createPreviewAction(title: "Изменить", key: "E")
            }
            let deleteAction = UIPreviewAction(title: "Удалить", style: .destructive) { _,_ in
                mailVC.deleteRowAt(indexPath)
            }
            actions.append(deleteAction)
            return actions
        case .posts:
            var actions = [UIPreviewAction]()
            for file in files {
                let action = UIPreviewAction(title: file.name, style: .default) { _,_ in
                    let safariVC = CustomSafariViewController(url:  file.link.toURL)
                    safariVC.delegate = self
                    UIApplication.shared.keyWindow?.rootViewController?.present(safariVC)
                }
                actions.append(action)
            }
            return actions
        default:
            ()
        }
        return []
    }
    
    //MARK: - VIEW SETUP
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        load()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        task?.cancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
    }
    
    private func setupUI() {
//        bottomConstraint.setBottomConstraint
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 144
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell3")
        tableView.tableFooterView = UIView()
        updateBookmark()
    }
    
    private func updateBookmark() {
        if let message = message {
            let name = UserDefaults.standard.bool(forKey: "m\(message.messageID)") ? "bookmark_f" : "bookmark_e"
            let labelButton = createBarButtonItem(imageName: name, selector: #selector(mark))
            let showActionsBTN = createBarButtonItem(imageName: "actions", selector: #selector(showActions))
            navigationItem.rightBarButtonItems = [showActionsBTN, labelButton]
        }
    }
    
    @objc private func mark() {
        let defaults = UserDefaults.standard
        let value = defaults.bool(forKey: "m\(message!.messageID)")
        defaults.setValue(!value, forKey: "m\(message!.messageID)")
        defaults.synchronize()
        mailVC!.updateCell(mailVC!.tableView.cellForRow(at: indexPath!) as! MailCell, condition: !value)
        updateBookmark()
    }
    
    @objc private func showActions(sender: AnyObject) {
        guard let mailVC = mailVC,
            let indexPath = indexPath,
            let message = message,
            let sender = sender as? UIView else { return }
        let 🚨 = mailVC.createActionsAlert(indexPath)
        let title = UserDefaults.standard.bool(forKey: "m\(message.messageID)") ? "Снять отметку" : "Пометить"
        🚨.addDefaultAction(title: title) {
            let defaults = UserDefaults.standard
            let value = defaults.bool(forKey: "m\(message.messageID)")
            defaults.setValue(!value, forKey: "m\(message.messageID)")
            defaults.synchronize()
            mailVC.updateCell(mailVC.tableView.cellForRow(at: indexPath) as! MailCell, condition: !value)
            self.updateBookmark()
        }
        🚨.addDestructiveAction(title: "Удалить") {
            mailVC.deleteRowAt(indexPath)
            self.navigationController?.popViewController(animated: true)
        }
        🚨.addCancelAction
        if let presenter = 🚨.popoverPresentationController {
            presenter.sourceView = sender
            presenter.sourceRect = sender.bounds
        }
        self.present(🚨)
    }
    
    @objc private func load() {
        if status != .loading {
            status = .loading
            tableView.reloadData()
        }
        UIApplication.shared.keyWindow?.tintColor = UIColor(hex: "650794")
        switch detailType {
        case .diary:
//            if lesson?.homework ?? false { createDoneBTN() }
            self.files = [File(link: "", name: "Критерии.pdf", size: nil)]
            var attribute = self.createAttribute(color: self.lesson!.color)
            let string = self.attributedString(string: "\n\(self.lesson!.fullWorkType)\n\n", attribute)
            attribute = self.createAttribute()
            string.append(self.attributedString(string: "\(self.lesson!.subject)\n\n", attribute))
            attribute = self.createAttribute(fontSize: 24, bold: true)
            string.append(self.attributedString(string: "\(self.lesson!.task)\n", attribute))
            attribute = self.createAttribute(fontSize: 14)
            let taskDescription =
                //            "Формулировка задания - с. 247, в. 8 \n\nОбразцы:\nроман Ж.-Ж. Руссо \"Юлия или Новая Элоиза\" (https://www.e-reading.club/book.php?book=1023373)\nроман И.-В. Гете \"Страдания молодого Вертера\" (https://www.e-reading.club/bookreader.php/14656/Gete_-_Stradaniya_yunogo_Vertera.html)\n\nОба романа написаны как серия писем. После задания напишите короткое объяснение приемов, образов и тем, которые вы использовали. Критерии оценивания см. в присоединенном файле\n\nРаботы пришлите мне на почту: galina1267@inbox.ru"
            "Выполнить ту работу, которую мы обсудили (завтра на уроке у каждого должен быть оформленный титульный лист с названием (если вы придумываете название), содержание, 1-2 написанных \"главы\"). Если вы пишете о родителях и других родственниках - подумайте, о чём именно уместно, важно и интересно рассказать. Порасспрашивайте их, возможно, узнаете много нового :) Ещё раз присылаю ссылку на автобиографию Маяковского, которую он назвал \"Я сам\" https://ru.wikisource.org/wiki/%D0%AF_%D1%81%D0%B0%D0%BC_(%D0%9C%D0%B0%D1%8F%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D0%B8%D0%B9) - посмотрите, как можно выстраивать текст, о чём писать и т.д. Работы пришлите мне на почту: galina1267@netschool.app!!"
            //            "Подготовьте презентацию о звуке, его свойствах и применении в жизни человека. Возможные темы:\n- Звуковые гранаты, звук как оружие\n- Как звук влияет на психику человека?\n- Ультразвуковое исследование в медицине\n- Генерация звука (любой музыкальный инструмент)\n- Инфразвук\n- Ухо человека - идеальный детектор звука"
            string.append(self.attributedString(string: "\n\(taskDescription)\n\n", attribute))
            attribute = self.createAttribute(color: .gray)
            string.append(self.attributedString(string: "\(self.fullDate!),\nМихайлюк Галина Эдуардовна\n", attribute))
            self.attrStr = string
            self.status = .successful
        case .mail:
            var attribute = self.createAttribute(fontSize: 24, bold: true)
            let string = self.attributedString(string: "Обновлённая версия Насреддина\n", attribute)
            attribute = self.createAttribute(fontSize: 14)
            string.append(self.attributedString(string: "\nВо вложении более удобная версия пьесы с номерами страниц и разными шрифтами.\n\nНа среду, 27 января, Дина, Никита и Артём Мещерин готовят 6 эпизод: учат наизусть слова, думают про характер.\n\nНа четверг, 28 января, Артём Слуцкий и Марат учат наизусть эпизод 7 (Джафар у Эмира); Фёдор учит слова Нияза из 8 эпизода\n\n", attribute))
            attribute = self.createAttribute(color: .gray)
            string.append(self.attributedString(string: "22.01.2016  17:46,\nКазбек-Казиева М. М.\n", attribute))
            self.files = [File(link: "%D0%9D%D0%90%D0%A1%D0%A0%D0%95%D0%94%D0%94%D0%98%D0%9D.docx", name: "НАСРЕДДИН.docx", size: "34.89 Миб")]
            if let mailVC = self.mailVC,
                let indexPath = self.indexPath {
                mailVC.readMessage(indexPath)
            }
            self.attrStr = string
            self.status = .successful
            self.tableView.reloadData()
        case .forum:
            guard let comment = comment else { return }
            var attribute = createAttribute(color: ForumDetail.colors[comment.systemID])
            let string = attributedString(string: "\n\(comment.fullID)\n\n", attribute)
            attribute = createAttribute(fontSize: 24, bold: true)
            string.append(attributedString(string: "\(topic!)\n", attribute))
            attribute = createAttribute(fontSize: 14)
            string.append(attributedString(string: "\n\(comment.message)\n\n", attribute))
            attribute = createAttribute(color: .gray)
            string.append(attributedString(string: "\(comment.date),\n\(comment.author)\n", attribute))
            attrStr = string
            status = .successful
            tableView.reloadData()
        case .posts:
            self.status = .successful
        default:
            ()
        }
    }
    
    func internetConnectionAppeared() {
        guard status == .error else { return }
        load()
    }
    
    private func createAttribute(fontSize: CGFloat = 13, color: UIColor = .black, bold: Bool = false) -> [NSAttributedStringKey : NSObject] {
        let font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        return [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: color]
    }
    
    private func attributedString(string: String,_ attribute: [NSAttributedStringKey : NSObject]) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string, attributes: attribute )
    }
    
//    private func createDoneBTN() {
//        let done = UserDefaults.standard.bool(forKey: lesson!.key)
//        navigationItem.rightBarButtonItem = createBarButtonItem(imageName: done ? "done_f" : "done_e", selector: #selector(makeDone))
//    }
    
    private func setDone() {
        let defaults = UserDefaults.standard
        let key = self.lesson!.key
        defaults.set(!defaults.bool(forKey: key), forKey: key)
        defaults.synchronize()
    }
    
    @objc private func makeDone() {
        setDone()
        if let diaryVC = diaryVC {
            diaryVC.tableView.reloadRows(at: [diaryVC.actionIndexPath], with: .none)
        }
//        createDoneBTN()
    }
    
    fileprivate func updateSize(s: Int64) {
        var (ind, size) = (0, Double(s))
        while size > 1024 {
            size /= 1024
            ind += 1
        }
        var letter = ""
        switch ind {
        case 1: letter = "КиБ"
        case 2: letter = "МиБ"
        case 3: letter = "ГиБ"
        default: letter = "Б"
        }
        for index in 0..<files.count {
            if files[index].size == nil {
                files[index].size = "\(String(format: "%.2f", size)) \(letter)"
                return
            }
        }
    }
}

// MARK: - MFMail
extension Details: MFMailComposeViewControllerDelegate {
    fileprivate func openMail(_ email: String) {
        let mc = MailExtended()
        mc.mailComposeDelegate = self
        mc.setToRecipients([email])
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

extension Details: NSURLConnectionDataDelegate {
    func connection(_: NSURLConnection, didReceive response: URLResponse) {
        updateSize(s: response.expectedContentLength)
        self.tableView.reloadData()
    }
}

extension Details: UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    //MARK: TABLE VIEW SETUP
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        func fileCell(index: Int) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskCell
            if files[index].size == nil {
                if let url = NSURL(string: files[index].link) {
                    let request:NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
                    request.httpMethod = "HEAD"
                    var _:NSURLConnection = NSURLConnection(request: request as URLRequest, delegate: self)!
                }
            }
            cell.SizeLabel.text = files[index].size ?? ""
            cell.FileLabel.text = files[index].name
            let filePathExtension = (files[index].name as NSString).pathExtension
            let image = (UIImage(named: filePathExtension) ?? UIImage(named: "file")!)
            cell.IconImage.image = image
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
            cell.setSelection
            return cell
        }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! TaskTextCell
            cell.TaskTextView.attributedText = attrStr
            cell.TaskTextView.delegate = self
            cell.separatorInset = UIEdgeInsets(top: 0, left: lesson?.homework ?? false ? 15 : cell.bounds.size.width, bottom: 0, right: 0)
            return cell
        } else {
            if lesson?.homework ?? false {
                if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3" , for: indexPath)
                    cell.textLabel?.text = "Отметить как выполненное"
                    cell.textLabel?.textColor = darkSchemeColor()
                    cell.setSelection
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                    return cell
                } else {
                    return fileCell(index: indexPath.row - 2)
                }
            } else {
                return fileCell(index: indexPath.row - 1)
            }
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        func openWebView(index: Int) {
            if #available(iOS 9.0, *) {
                let safariVC = CustomSafariViewController(url: files[index].link.toURL)
                safariVC.delegate = self
                present(safariVC)
            } else {
                let webView = WebViewn()
                webView.link = files[index].link
                webView.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
                webView.modalTransitionStyle = .coverVertical
                present(webView)
            }
        }
        if indexPath.row == 0 { return }
        if lesson?.homework ?? false {
            if indexPath.row == 1 {
                tableView.deselectSelectedRow
                makeDone()
            } else {
                openWebView(index: indexPath.row - 2)
            }
        } else {
            openWebView(index: indexPath.row - 1)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? UITableViewAutomaticDimension : 44
    }
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if detailType == .diary && status == .successful && (lesson?.homework ?? false)  {
            return files.count + 2
            
        }
        return status == .successful ? 1 + files.count : 0
    }
    
    //MARK: FOOTER
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return status == .successful ? 0 : 35 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch status {
        case .loading: return view.loadingFooterView()
        case .error: return view.errorFooterView()
        default: return nil
        }
    }
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss()
    }
}



//MARK: - 3D Touch peek and pop
extension Details: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if #available(iOS 9.0, *) {
            guard let indexPath = tableView.indexPathForRow(at: location),
                let cell = tableView.cellForRow(at: indexPath),
                indexPath.row != 0 else { return nil }
            let safariVC = CustomSafariViewController(url: files[indexPath.row - (lesson?.homework ?? false ? 2 : 1)].link.toURL)
            safariVC.delegate = self
            previewingContext.sourceRect = cell.frame
            return safariVC
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit)
    }
}

class TaskCell: UITableViewCell {
    @IBOutlet weak var FileLabel: UILabel!
    @IBOutlet weak var IconImage: UIImageView!
    @IBOutlet weak var SizeLabel: UILabel!
}

class TaskTextCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var TaskTextView: UITextView!
}

























