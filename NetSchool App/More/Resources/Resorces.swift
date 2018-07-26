//
//  Resorces.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 07.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
import SafariServices

class Files : UIViewController, SFSafariViewControllerDelegate {
    
//    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var status: Status = .loading
    fileprivate var groupSets = [GroupSet]()
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    
    //MARK: - LOAD VIEW
    override func viewDidLoad() {
        super.viewDidLoad()
//        bottomConstraint.setBottomConstraint
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        task?.cancel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        if let destination = segue.destination as? FilesDetail {
            destination.group = groupSets[indexPath.section].getGroup(indexPath.row)
        }
    }
    
    func internetConnectionAppeared() {
        guard status == .error else { return }
        groupSets.removeAll()
        status = .loading
        tableView.reloadData()
        loadData()
    }
    
    //MARK: - LOAD DATA
    private func loadData() {
        let groups = [Group("Математика", "Математика"),Group("Информатика", "Информатика"),Group("Списки летнего чтения", "Списки летнего чтения")]
        groups[0].addFile(file: File(link: "Тесты.docx", name: "Тесты", size: ""))
        groups[0].addFile(file: File(link: "Материалы для подготовке к экзаменам.pdf", name: "Материалы для подготовки к экзаменам", size: ""))
        groups[1].addFile(file: File(link: "ЕГЭ.pdf", name: "ЕГЭ", size: ""))
        groups[1].addFile(file: File(link: "Тесты.docx", name: "Тесты", size: ""))
        groups[2].addFile(file: File(link: "Для 6 класса.pdf", name: "Для 6 класса", size: ""))
        groups[2].addFile(file: File(link: "Для 7 класса.pdf", name: "Для 7 класса", size: ""))
        groups[2].addFile(file: File(link: "Для 8 класса.pdf", name: "Для 8 класса", size: ""))
        groups[2].addFile(file: File(link: "Для 9 класса.pdf", name: "Для 9 класса", size: ""))
        groupSets = [GroupSet(groups, title: "Учебные курсы")]
        status = .successful
        tableView.reloadData()
    }
}

//MARK: - TABLE VIEW SETUP
extension Files: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { return groupSets.count > 0 ? groupSets.count : 1 }
    
    //MARK: FOOTER
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return groupSets.isEmpty ? 23 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch status {
        case .loading: return self.view.loadingFooterView()
        case .error: return self.view.errorFooterView()
        default: return nil
        }
    }
    
    //MARK: HEADER
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard status == .successful else { return nil }
        return groupSets[section].title.isEmpty ? "Школьные ресурсы" : groupSets[section].title
    }
    
    
    //MARK: TABLE SETUP
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard status == .successful else { return 0 }
        return groupSets[section].groupCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SchoolResCell
//        cell.setSelection
        let title = groupSets[indexPath.section].getGropuTitle(indexPath.row)
        cell.titleLabel.text = title
        if groupSets[indexPath.section].title.range(of: "Материалы для экзаменов") != nil {
            cell.separatorInset = UIEdgeInsetsMake(0, 62, 0, 0)
            cell.accessoryType = .disclosureIndicator
            cell.leftConstraint.constant = 47
            cell.iconImageView.layer.cornerRadius = 8.0
            cell.iconImageView.clipsToBounds = true
            cell.iconImageView.isHidden = false
            func getImageName() -> String {
                switch title {
                case "Английский язык": return "english"
                case "Биология": return "biology"
                case "География": return "geogr"
                case "История": return "history"
                case "Литература": return "litriture"
                case "Математика": return "math"
                case "Русский язык": return "russian"
                case "Физика": return "ph"
                case "Химия": return "chemistry"
                default: return "universal"
                }
            }
            cell.iconImageView?.image = UIImage(named: getImageName())
        } else {
            cell.accessoryType = .disclosureIndicator
//            cell.accessoryType = .none
            cell.iconImageView.isHidden = true
            cell.leftConstraint.constant = 8
            cell.separatorInset = UIEdgeInsetsMake(0, 23, 0, 0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail")
    }
}

//MARK: - Group File Classes
fileprivate class GroupSet {
    var groups: [Group]
    let title: String
    init(_ groups: [Group], title: String) {
        self.title = title
        self.groups = groups
    }
    func groupCount() -> Int { return groups.count }
    func addGroups(groups: [Group]) { self.groups.append(contentsOf: groups) }
    func getGropuTitle(_ index: Int) -> String { return groups[index].title }
    func getGroup(_ index: Int) -> Group { return groups[index] }
}

class Group {
    var title: String
    private var files: [File]
    var prefix:String? = nil
    init(_ title: String, _ prefix: String) {
        self.title = title
        self.prefix = prefix
        self.files = []
    }
    func addFile(file: File) {
        self.files.append(file)
//        if let prefix = prefix {
//            self.prefix = prefix.commonPrefixWith(another: file.name)
//        } else {
//            prefix = file.name
//        }
    }
    func getUrlfor(_ index: Int) -> String { return files[index].link }
    func getNamefor(_ index: Int) -> String { return files[index].name }
    func getSizefor(_ index: Int) -> String? { return files[index].size }
    func getFilesCount() -> Int { return files.count }
//    func setupPrefix() {
//        guard files.count > 1 && prefix?.range(of: ",") != nil else {
//            var newPrefix = title
//            for index in 0..<files.count {
//                newPrefix = newPrefix.commonPrefixWith(another: files[index].name)
//            }
//            if newPrefix == title {
//
//            }
//            prefix = newPrefix == title ? nil : newPrefix
//            if let prefix = prefix, title.hasPrefix(prefix) {
//                self.prefix = title
//            }
//            if !newPrefix.isEmpty {
//                for index in 0..<files.count {
//                    let name = files[index].name.removePart(newPrefix).capitalizeFirst
//                    if name[name.startIndex] == " " {
//                        files[index].name = String(name[name.index(name.startIndex, offsetBy: 1)..<name.endIndex])
//                    } else {
//                        files[index].name = name
//                    }
//                }
//            }
//            return
//        }
//        prefix = prefix?.components(separatedBy: ",").first
//        for index in 0..<files.count {
//            files[index].name = files[index].name.removePart(prefix! + ", ")
//        }
//    }
}

class SchoolResCell: UITableViewCell {
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}

extension String {
    func commonPrefixWith(another: String) -> String {
        let a = Array(self)
        let b = Array(another)
        return String(
            a.enumerated()
                .filter { b.count > $0.offset && b[0...$0.offset] == a[0...$0.offset] }
                .map { $0.1 }
        )
    }
}

class FilesDetail: UIViewController, SFSafariViewControllerDelegate {
    
    var group: Group!
    
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
//    let data = [
//        ["Руководство по программе CAS", "331 Киб", "pdf"],
//        ["Список литературы на лето для 7 класса", "25 Киб", "docx"],
//        ["Список литературы на лето для 9 класса", "27 Киб", "docx"],
//        ["Химические реакции", "1.48 Миб", "pptx"],
//        ["Молекулярная физика", "1.8 МиБ", "pptx"],
//        ["Периодическая таблица", "744 Киб", "jpeg"],
//        ["Формулы сокращенного умножения", "526 КиБ", "png"]
//    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        if group.prefix != nil && !group.title.hasPrefix(group.prefix!) {
            navigationItem.title = group.title
        }
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
//        tableViewBottomConstraint.setBottomConstraint
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
    }
}

// MARK: - TABLE VIEW SETUP
extension FilesDetail: UITableViewDataSource, UITableViewDelegate {
    // MARK: Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let prefix = group.prefix {
            return prefix
        }
        return group.title
    }
    // MARK: Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 40 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 23))
        footerView.backgroundColor = UIColor.clear
        let footerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: tableView.frame.size.width - 20, height: 23))
        footerLabel.addProperties
        let FileCount = group.getFilesCount()
        footerLabel.text = FileCount > 0 ? String(FileCount) + FileCount.getFileDeclension : "Раздел пуст"
        footerView.addSubview(footerLabel)
        return footerView
    }
    // MARK: Body
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.getFilesCount()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FileDetailCell
        cell.separatorInset = UIEdgeInsetsMake(0, 64, 0, 0)
//        cell.setSelection
        cell.fileNameLabel.text = group.getNamefor(indexPath.row)
        let filePathExtension = (group.getUrlfor(indexPath.row) as NSString).pathExtension
        let image = (UIImage(named: filePathExtension) ?? UIImage(named: "file")!)
        cell.fileType.image = image
        if let size = group.getSizefor(indexPath.row) {
            cell.fileSizeLabel.text = size
        } else {
            cell.fileSizeLabel.text = " "
            let myUrl = group.getUrlfor(indexPath.row)
            let request = NSMutableURLRequest(url: myUrl.toURL)
            request.httpMethod = "HEAD"
            URLSession.shared.dataTask(with: request as URLRequest) {
                (_, response, error) in
                if let response = response {
                    DispatchQueue.main.async {
                        cell.fileSizeLabel.text = response.expectedContentLength.updateSize()
                    }
                }
            }.resume()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openURL(group.getUrlfor(indexPath.row))
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 72, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = group.getNamefor(indexPath.row)
        label.font = UIFont.systemFont(ofSize: 17)
        label.sizeToFit()
        return label.frame.height + 39
    }
}

//MARK: - 3D Touch peek and pop
extension FilesDetail: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard #available(iOS 9.0, *),
            let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) else { return nil }
        let safariVC = CustomSafariViewController(url: group.getUrlfor(indexPath.row).toURL)
        safariVC.delegate = self
        previewingContext.sourceRect = cell.frame
        return safariVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit)
    }
}

class FileDetailCell: UITableViewCell {
    @IBOutlet weak var fileType: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
}














