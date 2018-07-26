//
//  More.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 29.06.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import UIKit

class More: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let titles = ["Почта","Форум","Учебные материалы","Настройки","Информация"]
    let icons = ["mail","forum","files","settings","info"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! ProfileMoreCell
            cell.name.text = "Корнакова Ольга"
            cell.profileImage.setImage(string: "Корнакова Ольга")
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MoreCell
        cell.accessoryType = .disclosureIndicator
        cell.title.text = titles[indexPath.row]
        cell.icon.image = UIImage(named: "more_" + icons[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 100 : 44
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            switch indexPath.row {
                case 0: performSegue(withIdentifier: "mail")
                case 1: performSegue(withIdentifier: "forum")
                case 2: performSegue(withIdentifier: "resources")
                case 3: performSegue(withIdentifier: "settings")
                case 4: show(Info())
                default: tableView.deselectSelectedRow
            }
        } else {
            performSegue(withIdentifier: "profile")
        }
    }
}

class MoreCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
}

class ProfileMoreCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
}
