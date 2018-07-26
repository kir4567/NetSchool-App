//
//  Forum.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 06.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation

class Forum: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    /// Strunc represents forum topic
    fileprivate struct ForumTopic {
        let topic, topicID, messagesCount, date, author: String
    }
    /// Current page index (Starts from 1)
    fileprivate var currentPage = 1
    /// Number of max page
    fileprivate var maxPages = 1
    /// Loaded forum topics
    fileprivate var topics = [ForumTopic]()
    /// Represents whether current page is last
    fileprivate var last = false
    /// View status
    var status: Status = .loading
    /// Refresh controll
    private var refreshControl = UIRefreshControl()
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    
    //MARK: - VIEW SETUP
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setupUI()
        loadTopics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
//        if getReloadForum() {
//            currentPage = 1
//            topics.removeAll()
////            setBool(forKey: "ReloadForum", val: false)
//            loadTopics()
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        task?.cancel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ForumDetail,
            let indexPath = tableView.indexPathForSelectedRow {
            let topic = topics[indexPath.row]
            destination.topicID = topic.topicID
            destination.topic = topic.topic
            let messagesCount = Int(topic.messagesCount)!
            destination.numberOfPages = messagesCount % 20 == 0 ? messagesCount / 20 :  messagesCount / 20 + 1
        }
    }
    
    /// Setups basic UI
    private func setupUI() {
//        bottomConstraint.setBottomConstraint
        view.updateConstraints()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        tableView?.addSubview(refreshControl)
        navigationItem.rightBarButtonItem = createBarButtonItem(imageName: "write", selector: #selector(createNewTopic))
    }
    
    /// Reload data
    @objc private func reload() {
        currentPage = 1
        last = false
        loadTopics()
    }
    
    /// Loads data when internet connection appears
    func internetConnectionAppeared() {
        guard status == .error else { return }
        status = .loading
        tableView.reloadData()
        loadTopics(isLoadFirst: currentPage == 1)
    }
    
    /// Loads next topics group
    fileprivate func loadTopics(isLoadFirst: Bool = true) {
        topics = [
            ForumTopic(topic: "Minecraft", topicID: "", messagesCount: "156", date: cleverDate("21.06.2018"), author: "Соболева Варвара"),
            ForumTopic(topic: "English exam", topicID: "", messagesCount: "14", date: cleverDate("4.05.2018"), author: "Хилл Е.В."),
            ForumTopic(topic: "Топ телефонов", topicID: "", messagesCount: "7", date: cleverDate("24.06.2018"), author: "Смирнов Максим")
        ]
        status = .successful
        tableView.reloadData()
    }
    
    /// Present new topic view
    @objc private func createNewTopic() {
        let newTopicViewController = NewForumMessage()
        newTopicViewController.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        newTopicViewController.isTopicNew = true
        newTopicViewController.modalTransitionStyle = .coverVertical
        self.present(newTopicViewController)
    }
}

//MARK: - FORUM TABLE VIEW
extension Forum: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: TABLE VIEW SETUP
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == topics.count - 1 {
            if currentPage < maxPages {
                currentPage += 1
                loadTopics(isLoadFirst: false)
            } else {
                last = true
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row == topics.count  else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ForumCell
            let topic = topics[indexPath.row]
            cell.TemaLabel.text = topic.topic
            cell.NumberOfMessages.text = "\(topic.messagesCount) " + Int(topic.messagesCount)!.getMessageDeclension
            cell.NumberOfMessages.textColor = .schemeTintColor
            cell.DateLabel.text = cleverDate(topic.date)
            cell.authorLabel.text = topic.author
            cell.backgroundColor = UIColor.clear
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
        performSegue(withIdentifier: "messages")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return topics.count + 1 }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == topics.count ? 30 : 80
    }
}

// MARK: - HELPFUL CLASSES
class ForumCell: UITableViewCell {
    @IBOutlet weak var TemaLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var NumberOfMessages: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
}
