//
//  ForumDetail.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 06.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation

class ForumDetail: UIViewController {
    
//    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    /// Forum detail table view
    
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var tableView: UITableView!
    /// Topic messages
    fileprivate var topics = [ForumDetailTopic]()
    /// Whether loaded group of messages is last
    fileprivate var last = false
    /// Number of last loaded page
    fileprivate var numberOfCurrentPage = 1
    /// topic ID
    var topicID: String!
    /// topic name
    var topic: String!
    /// number of pages in this topic
    var numberOfPages = 1
    /// refresh control
    private var refreshControl = UIRefreshControl()
    /// status of view
    var status: Status = .loading
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    /// colors represent author's role
    static let colors = [
        UIColor(red: 219/255, green: 45/255, blue: 69/255, alpha: 1),
        UIColor(red: 0, green: 170/255, blue: 150/255, alpha: 1),
        UIColor(red: 177/255, green: 179/255, blue: 215/255, alpha: 1)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getMessages(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        task?.cancel()
    }
    
    /// Setup basic UI
    private func setupUI() {
//        bottomConstraint.setBottomConstraint
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        self.navigationItem.rightBarButtonItem = createBarButtonItem(imageName: "write", selector: #selector(newMessage))
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        tableView.tableFooterView = UIView()
        view.updateConstraints()
        navigationItem.title = topic
    }
    
    /// Reload data
    @objc private func reload() {
        numberOfCurrentPage = 1
        last = false
        getMessages(true)
    }
    
    /// Loads data when internet connection appears
    func internetConnectionAppeared() {
        guard status == .error else { return }
        status = .loading
        tableView.reloadData()
        getMessages(numberOfCurrentPage == 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
        if getReloadForumMessage() {
            numberOfCurrentPage = 1
            setBool(forKey: "ReloadForumMessage", val: false)
            getMessages(true)
        }
    }
    
    /// Loads new messages group
    func getMessages(_ firstLoad: Bool) {
        topics = [
            ForumDetailTopic(date: "24.06.2018", message: "Типичный пользователь Apple", author: "Смирнов Максим", systemID: ""),
            ForumDetailTopic(date: "21.06.2018", message: "Лололо", author: "Кудрявцев Даниил", systemID: ""),
            ForumDetailTopic(date: "21.06.2018", message: "А я футблист и долблюсь в жопу", author: "Кудрявцев Даниил", systemID: ""),
            ForumDetailTopic(date: "19.06.2018", message: "Фигня твой Xiaomi. У них дисплей максимум HD. Бомжефон.", author: "Смирнов Максим", systemID: ""),
            ForumDetailTopic(date: "18.06.2018", message: "Сяоми love forever", author: "Соболева Варвара", systemID: ""),
            ForumDetailTopic(date: "08.02.2018", message: "Самые лучше телефоны - от Samsung!1!!11!! Apple сосатб!!11!", author: "Смирнов Максим", systemID: ""),
            ForumDetailTopic(date: "08.02.2018", message: "Пишите кто какие устройства любит", author: "Смирнов Максим", systemID: "")
        ]
        self.status = .successful
        self.tableView.reloadData()
    }
    
    /// Presents new message view
    @objc func newMessage() {
        let newMessageViewController = NewForumMessage()
//        newMessageViewController.navigationBarHeight = self.heightOfNavigationBar
        newMessageViewController.topic = topic
        newMessageViewController.isTopicNew = false
        newMessageViewController.topicID = topicID
        newMessageViewController.modalTransitionStyle = .coverVertical
        self.present(newMessageViewController)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? Details,
            let indexPath = tableView.indexPathForSelectedRow {
            destination.detailType = .forum
            destination.comment = topics[indexPath.row]
            destination.topic = topic
        }
    }
}

//MARK: - FORUM DETAIL TABLE VIEW
extension ForumDetail: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: TABLE VIEW SETUP
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == topics.count - 1 {
            if numberOfCurrentPage < numberOfPages {
                numberOfCurrentPage += 1
                getMessages(false)
            } else {
                last = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return topics.count + 1 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row == topics.count else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ForumDetailCell
            cell.backgroundColor = UIColor.clear
            let topic = topics[indexPath.row]
            cell.nameLabel.text = topic.author
            cell.dateLabel.text = cleverDate(topic.date)
            cell.systemIDLabel.backgroundColor = ForumDetail.colors[topic.systemID]
            cell.messageLabel.text = topic.message
            cell.setSelection
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.setClearSelectionColor
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
        if last {
            let numberOfMessages = topics.count
            cell.createFooterLabel(withText: String(numberOfMessages) + numberOfMessages.getMessageDeclension)
        } else if status == .error {
            cell.addSubview(view.errorFooterView())
        } else {
            cell.addSubview(view.loadingFooterView())
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != topics.count else { return }
        performSegue(withIdentifier: "details")
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row != topics.count else { return 30 }
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 40, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = topics[indexPath.row].message
        label.font =  UIFont(name: "BloggerSans", size: 18) ?? UIFont.systemFont(ofSize: 15)
        label.sizeToFit()
        return label.frame.height + 52
    }
}

//MARK: - 3D Touch peek and pop
extension ForumDetail: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if #available(iOS 9.0, *) {
            guard let indexPath = tableView.indexPathForRow(at: location),
                let cell = tableView.cellForRow(at: indexPath),
                let detailVC = storyboard?.instantiateViewController(withIdentifier: "Details") as? Details,
                indexPath.row != topics.count else { return nil }
            detailVC.detailType = .forum
            detailVC.comment = topics[indexPath.row]
            detailVC.topic = topic
            previewingContext.sourceRect = cell.frame
            return detailVC
        }
        return nil
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit)
    }
}

class ForumDetailCell: UITableViewCell {
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = systemIDLabel.backgroundColor
        super.setSelected(selected, animated: animated)
        systemIDLabel.backgroundColor = color
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = systemIDLabel.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        systemIDLabel.backgroundColor = color
    }
    
    @IBOutlet weak var systemIDLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
}

class ForumDetailTopic {
    let date, message, author, fullID: String
    let systemID: Int
    init(date: String, message: String, author: String, systemID: String) {
        (self.date, self.message, self.author, self.fullID) = (date.removePart("Добавлено: "), message, author, systemID)
        switch fullID {
        case "Ученик": self.systemID = 0
        case "Родитель": self.systemID = 1
        default: self.systemID = 2
        }
    }
}








