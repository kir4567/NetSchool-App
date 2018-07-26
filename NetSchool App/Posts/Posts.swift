//
//  Posts.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 29.06.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import UIKit

/// File structure represents file
struct File {
    var link, name: String
    var size: String?
}

class Posts: UIViewController {
    
    /// Struct represents a post
    fileprivate struct Post {
        let date, author, title, message: String
        let file: File?
        var hasFile: Bool {
            return file != nil
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var posts = [Post]()
    private var refreshControl = UIRefreshControl()
    var status: Status = .loading
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
    }
    
    private func setupUI() {
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56
    }
    
    func internetConnectionAppeared() {
        guard status == .error else { return }
        loadData()
    }
    
    @objc private func loadData() {
        status = .loading
        if posts.isEmpty { tableView.reloadData() }
        posts = [
            Post(date: "8.05.2018", author: "Павлова Ольга Вячеславовна", title: "NEW!!! ГРАФИК ЖИЗНИ ШКОЛЫ 2018-2019 гг.", message: "", file: File(link: "", name: "ГРАФИК_ЖИЗНИ_ШКОЛЫ_2018-2019.doc", size: "")),
            Post(date: "31.01.2018", author: "Хмельницкий Андрей Леонидович", title: "ЧЁРНЫЙ годовой календарный график 2017-2018 у.г", message: "", file: File(link: "", name: "ЧЁРНЫЙ годовой календарный график 2017-2018 у.г.xls", size: "")),
            Post(date: "14.06.2015", author: "Плескач Сергей Георгиевич", title: "По следам семинаров для родителей. Ссылки на видео", message: "Амонашвили Ш.А. с первого семинара с родителями:\nhttp://youtu.be/_L1hEDq90Xs\n\nГатанов Ю.Б. с первого семинара с родителями::\nhttp://youtu.be/PaJz5TEng58\n\nВыступление А.Э.Колмановского, которое мы просмотрели на втором семинаре с родителями 28.01.15:\nhttp://youtu.be/sucoP9PWk8U ", file: File(link: "", name: "Ссылки_на_видеозаписи,_которые_мы_просмотрели_на_семинарах_с_родителями.docx", size: ""))
        ]
    }
    
    fileprivate func createAttributeString(_ indexPath: IndexPath) -> NSMutableAttributedString {
        let post = posts[indexPath.row]
//        var attribute = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedStringKey.foregroundColor: UIColor.black]
//        let attributedString = NSMutableAttributedString(string: "\(post.title)\n", attributes: attribute)
//        attribute = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.black ]
//        attributedString.append(NSMutableAttributedString(string: "\(post.message)\n\n", attributes: attribute))
//        attribute = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: UIColor.gray ]
//        attributedString.append(NSMutableAttributedString(string: "\(post.date),\n\(post.author)\n", attributes: attribute))
        var attribute = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 24)!, NSAttributedStringKey.foregroundColor: UIColor(hex: "222222")]
        let attributedString = NSMutableAttributedString(string: "\(post.title)\n", attributes: attribute)
        attribute = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 5)!]
        attributedString.append(NSMutableAttributedString(string: "\n", attributes: attribute))
        attribute = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 14)!, NSAttributedStringKey.foregroundColor: UIColor(hex: "333333")]
        attributedString.append(NSMutableAttributedString(string: "\(post.message)\n\n", attributes: attribute))
        attribute = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor.gray ]
        attributedString.append(NSMutableAttributedString(string: "\(post.date),\n\(post.author)\n", attributes: attribute))
        return attributedString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? Details,
            let indexPath = tableView.indexPathForSelectedRow {
            destination.attrStr = createAttributeString(indexPath)
            destination.detailType = .posts
            if let file = posts[indexPath.row].file {
                destination.files = [file]
            }
        }
    }
}

//MARK: - 3D Touch peek and pop
extension Posts: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if #available(iOS 9.0, *) {
            guard let indexPath = tableView.indexPathForRow(at: location),
                let cell = tableView.cellForRow(at: indexPath),
                let detailVC = storyboard?.instantiateViewController(withIdentifier: "Details") as? Details else { return nil }
            detailVC.attrStr = createAttributeString(indexPath)
            if posts[indexPath.row].hasFile {
                detailVC.files = [posts[indexPath.row].file!]
            }
            detailVC.detailType = .posts
            detailVC.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
            previewingContext.sourceRect = cell.frame
            return detailVC
        }
        return nil
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit)
    }
}

// MARK: - TableView Setup
extension Posts: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return posts.isEmpty ? 35 : 0 }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if !posts.isEmpty { return nil }
        switch status {
        case .loading: return self.view.loadingFooterView()
        case .error: return self.view.errorFooterView()
        default:
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 23))
            footerView.backgroundColor = UIColor.clear
            let footerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: tableView.frame.size.width - 30, height: 23))
            footerLabel.addProperties
            footerLabel.text = "Объявлений нет"
            footerView.addSubview(footerLabel)
            return footerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        let attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor(hex: "424242")]
        label.attributedText = NSMutableAttributedString(string: "\(posts[indexPath.row].title)", attributes: attributes)
        label.sizeToFit()
        func messageHeight() -> CGFloat {
            if !(posts[indexPath.row].message.unicodeScalars.filter{$0.isASCII}.map{$0.value}).isEmpty {
                let messageLabel =  UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: .greatestFiniteMagnitude))
                messageLabel.numberOfLines = 0
                var attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 15)!]
                let attributeString = NSMutableAttributedString(string: "\n\(posts[indexPath.row].message)", attributes: attributes)
                attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 5)!]
                attributeString.append(NSMutableAttributedString(string: "\n", attributes: attributes))
                messageLabel.attributedText = attributeString
                messageLabel.sizeToFit()
                return messageLabel.frame.height
//                return min(messageLabel.frame.height, 45)
            }
            return 0
        }
        return label.frame.height + 82 + messageHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return posts.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostsCell
        let post = posts[indexPath.row]
        cell.dateLabel.text = cleverDate(post.date)
        cell.titleLabel.text = post.author
        var attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor(hex: "424242")]
        let attributedString = NSMutableAttributedString(string: "\(post.title)", attributes: attributes)
        if !(posts[indexPath.row].message.unicodeScalars.filter{$0.isASCII}.map{$0.value}).isEmpty {
            attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 5)!]
            attributedString.append(NSMutableAttributedString(string: "\n", attributes: attributes))
            attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 15)!, NSAttributedStringKey.foregroundColor: UIColor(hex: "9D9D9D")]
            attributedString.append(NSMutableAttributedString(string: "\n\(post.message)", attributes: attributes))
        }
        cell.messageLabel.attributedText = attributedString
        cell.icon.setImage(string: post.author)
        cell.setSelection
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "details")
    }
}

class PostsCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
}
