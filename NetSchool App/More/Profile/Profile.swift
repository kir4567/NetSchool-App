//
//  Profile.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 10.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
import UIKit

class Profile: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "сell1")
    }
    
    @objc fileprivate func logout() {
        print("log out")
        let loginVC = Login()
        loginVC.navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        loginVC.modalTransitionStyle = .coverVertical
        present(loginVC)
    }
    
    @objc fileprivate func deleteAccount() {
        print("delete accout")
    }
}

struct ProfileTitles {
    var title, description: String
}


extension Profile: UITableViewDelegate, UITableViewDataSource {
    
    private static let titles = [
        ProfileTitles(title: "Имя пользователя", description: "мКорнакова"),
        ProfileTitles(title: "Роль в системе", description: "Родитель"),
        ProfileTitles(title: "Учебный год", description: "2017/2018"),
        ProfileTitles(title: "Школа", description: "ЧУ ОО Европейская гимназия")
    ]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 4 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "сell1", for: indexPath) as UITableViewCell
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: view.frame.width - 30, height: 44))
            label.font = UIFont.systemFont(ofSize: 17)
            label.textColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
            label.text = Profile.titles[indexPath.row].title
            cell.addSubview(label)
            
            let subLabel = UILabel(frame: CGRect(x: 15, y: 0, width: view.frame.width-30, height: 44))
            subLabel.textAlignment = .right
            subLabel.font = UIFont.systemFont(ofSize: 14)
            subLabel.textColor = UIColor.lightGray
            subLabel.text = Profile.titles[indexPath.row].description
            cell.addSubview(subLabel)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileCell
            if indexPath.row == 0 {
                cell.exitButton.setTitle("Выйти", for: .normal)
                cell.exitButton.addTarget(self, action: #selector(logout), for:  .touchUpInside)
            } else {
                cell.exitButton.setTitle("Удалить аккаунт", for: .normal)
                cell.exitButton.addTarget(self, action: #selector(deleteAccount), for:  .touchUpInside)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return section == 0 ? 125 : 0 }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 { return nil }
        let headerView = UIView(frame: CGRect(x: 10, y: 0, width: tableView.frame.size.width - 20, height: 125))
        let photo = UIImageView(frame: CGRect(x: 15, y: 40, width: 45, height: 45)) // (tableView.frame.size.width - 120)/2
        photo.setImage(string: "Корнакова Ольга")
        headerView.addSubview(photo)
        let label = UILabel(frame: CGRect(x: 75, y: 40, width: view.frame.width - 90, height: 44))
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        label.text = "Корнакова Ольга"
        headerView.addSubview(label)
        
//        let headerLabel = UILabel(frame: CGRect(x: 10, y: (tableView.frame.height - 260)/2 + 50, width: tableView.frame.size.width - 20, height: 200))
//        headerLabel.addProperties
//        headerLabel.font = UIFont.systemFont(ofSize: 17)
//        headerLabel.text = "Корнакова Ольга Алексеевна\nЛогин: мКорнакова\nРоль в системе: родитель\n\nЧУ ОО \"Европейская гимназия\""
//        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}


class ProfileCell: UITableViewCell {
    @IBOutlet weak var exitButton: UIButton!
}
