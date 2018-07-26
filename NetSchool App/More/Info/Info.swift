//
//  Info.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 10.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
class Info: UIViewController {
    
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAndSetupTableView()
    }
    
    /// Table View creation and configuration
    private func createAndSetupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.addConstraints(view: view, topConstraintConstant: -(self.navigationController?.navigationBar.frame.height ?? 44))
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 260
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
    }
}

extension Info: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    private static let titles = ["Тех. поддержка", "Оцените приложение", "Политика конфиденциальности"]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = Info.titles[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: TABLE VIEW HEADER
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 260 }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        let headerView = UIView(frame: CGRect(x: 10, y: 0, width: tableView.frame.size.width - 20, height: 260))
        let photo = UIImageView(frame: CGRect(x: (tableView.frame.size.width - 120)/2, y: 50, width: 120, height: 120))
        photo.image = UIImage(named: "NetLogo")
        photo.layer.cornerRadius = 30
        photo.clipsToBounds = true
        headerView.addSubview(photo)
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 150, width: tableView.frame.size.width - 20, height: 100))
        headerLabel.addProperties
        headerLabel.text = "Версия 2.4.1"
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 0 else {
            let settingsDetailVC = SettingsDetails()
            settingsDetailVC.settingsDetailType = .support
            show(settingsDetailVC)
            return
        }
        tableView.deselectSelectedRow
        if indexPath.row == 1 {
            UIApplication.shared.openURL(NSURL(string: "https://appsto.re/ru/D7hgib.i")! as URL)
        }
    }
}













