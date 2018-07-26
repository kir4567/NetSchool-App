//
//  Extensions.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 04.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
import SafariServices

extension UITableView {
    var deselectSelectedRow: Void {
        if let indexPath = self.indexPathForSelectedRow {
            self.deselectRow(at: indexPath, animated: true)
        }
    }
    func updateCellHeigths() {
        self.beginUpdates()
        self.endUpdates()
    }
    func addConstraints(view: UIView, topConstraintConstant: CGFloat, _ isAdressBook: Bool = false) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var topConstant = topConstraintConstant
        if #available(iOS 11.0, *) {
            view.insetsLayoutMarginsFromSafeArea = false
            if let topSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.top {
                topConstant -= topSafeArea
            }
        }
        let tableViewTopConstraint = NSLayoutConstraint(item: view, attribute: .topMargin, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: topConstant)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottomMargin, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let tableViewLeadingConstraint = NSLayoutConstraint(item: view, attribute: .leadingMargin, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20)
        let tableViewTrailingConstraint = NSLayoutConstraint(item: view, attribute: .trailingMargin, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: isAdressBook ? -15 : -20)
        view.addConstraints([tableViewTopConstraint, bottomConstraint, tableViewLeadingConstraint, tableViewTrailingConstraint])
    }
}

extension UITableViewCell {
    var setSelection: Void {
        let myBackView = UIView(frame: self.frame)
        myBackView.backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 244/255, alpha: 1)
        self.selectedBackgroundView = myBackView
    }
    var setClearSelectionColor: Void {
        let backView = UIView(frame: self.frame)
        backView.backgroundColor = .clear
        self.selectedBackgroundView = backView
    }
    func createFooterLabel(withText text: String) {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 23))
        footerView.backgroundColor = UIColor.clear
        let footerLabel = UILabel(frame: CGRect(x: 0, y: 7, width: self.frame.size.width, height: 23))
        footerLabel.addProperties
        footerLabel.text = text
        footerView.addSubview(footerLabel)
        self.addSubview(footerView)
    }
}

extension String {
    
    var capitalizeFirst: String {
        if isEmpty { return "" }
        var result = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).uppercased())
        return result
    }
    func removePart(_ Part: String) -> String {
        return self.replacingOccurrences(of: Part, with: "")
    }
    var toURL: URL {
        var url = self
        if !url.lowercased().hasPrefix("http://") && !url.lowercased().hasPrefix("https://"){
            url = "http://\(url)"
        }
        if let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let url = URL(string: encoded) {
            return url
        }
        return URL(string: url) ?? URL(string: "https://www.google.ru/")!
    }
}

extension UIStatusBarStyle {
    static var schemeStyle: UIStatusBarStyle {
        return .lightContent
//        return isSchemeLight() ? .lightContent : .default
    }
}

extension Int64 {
    func updateSize() -> String {
        var (ind, size) = (0, Double(self))
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
        return "\(String(format: "%.2f", size)) \(letter)"
    }
}

extension UIViewController {
    func createBarButtonItem(imageName: String, selector: Selector) -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        button.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        button.addTarget(self, action: selector, for:  .touchUpInside)
        if #available(iOS 9.0, *) {
            button.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
            button.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        } else {
            // Fallback on earlier versions
        }
        button.tintColor = .schemeTitleColor //e6e6e6
        return UIBarButtonItem(customView: button)
    }
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    func performSegue(withIdentifier: String) {
        self.performSegue(withIdentifier: withIdentifier, sender: nil)
    }
    func openURL(_ url: String) {
        if #available(iOS 9.0, *) {
            if let slf = self as? SFSafariViewControllerDelegate {
                let safariVC = CustomSafariViewController(url: url.toURL)
                safariVC.delegate = slf
                present(safariVC)
                return
            }
        }
        let webView = WebViewn()
        webView.link = url
        webView.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        webView.modalTransitionStyle = .coverVertical
        self.present(webView)
    }
    func show(_ VCToShow: UIViewController) {
        self.show(VCToShow, sender: nil)
    }
    func openTableFromJSON(_ data: String, name: String, type: Int) {
        let mainController = CollectionViewController(nibName: name, bundle: nil)
        let json = JSONParser(data:data, type: type)
        let full_data = json.load_data()
        setInt(forKey: "sectionLength", val: full_data.maxLength)
        let temp:TableData = TableData(countOfSections: full_data.countOfSections ?? 0, countOfRows:full_data.countOfRows ?? 0, data: full_data.data)
        mainController.load_data(data:temp)
        show(mainController)
    }
}

extension UIColor {
    static var schemeTitleColor: UIColor {
        return isSchemeLight() ? UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1) : UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
    }
    
    static var schemeTintColor: UIColor {
        return isSchemeLight() ? darkSchemeColor().withAlphaComponent(0.8) : UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
    }
    
    var redValue: CGFloat{
        return cgColor.components! [0]
    }
    
    var greenValue: CGFloat{
        return cgColor.components! [1]
    }
    
    var blueValue: CGFloat{
        return cgColor.components! [2]
    }
    
    var isWhiteText: Bool {
        let color = self.withAlphaComponent(0.86)
        if cgColor.numberOfComponents == 2 {
            return 0.0...0.5 ~= cgColor.components!.first! ? true : false
        }
        
        let red = color.redValue * 255
        let green = color.greenValue * 255
        let blue = color.blueValue * 255
        
        // https://en.wikipedia.org/wiki/YIQ
        // https://24ways.org/2010/calculating-color-contrast/
        let yiq = ((red * 299) + (green * 587) + (blue * 114)) / 1000
        return yiq < 192
    }
    
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension UIImageView {
    func setImageBackgroundColor(_ color: UIColor) {
        let imageView = self
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = color
    }
    fileprivate struct Colorify {
        static let colors = [
            UIColor(hex: "EB8B51"), UIColor(hex: "EAA949"), UIColor(hex: "E9BE3F"),
            UIColor(hex: "E9D53F"), UIColor(hex: "CFCA3F"), UIColor(hex: "A1C869"),
            UIColor(hex: "34A668"), UIColor(hex: "34AAA0"), UIColor(hex: "3DB7E0"),
            UIColor(hex: "3995C8"), UIColor(hex: "3575AC"), UIColor(hex: "89949C"),
            UIColor(hex: "475662"), UIColor(hex: "49599E"), UIColor(hex: "7F5C9F"),
            UIColor(hex: "A2599E"), UIColor(hex: "EA6695"), UIColor(hex: "EA5E54"),
        ]
    }
    
    open func setImage(string: String, _ letter: String? = nil, multiply: CGFloat = 1.0) {
        func shortString() -> String {
            let displayString = NSMutableString.init()
            var words = string.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
            words = words.filter{ !$0.isEmpty }
            if words.count > 1 {
                displayString.append(String(words[1][words[1].startIndex]))
            } else if words.count == 1 {
                displayString.append(String(words[0][words[0].startIndex]))
            }
            return displayString.uppercased as String
        }
        
        let displayString = letter == nil ? shortString() : letter!
        self.image = self.imageSnap(text: string, displayString: displayString, multiply: multiply)
    }
    
    private func imageSnap(text: String, displayString: String, multiply: CGFloat) -> UIImage? {
        let scale:Float = Float(UIScreen.main.scale)
        func colorHash(name: String) -> UIColor {
            let index = name.map{ String($0).unicodeScalars }
                .map{ Int($0[$0.startIndex].value) }
                .reduce(0, {$0 + $1})
            return Colorify.colors[(index + 4) % Colorify.colors.count]
        }
        let color = colorHash(name: text)
        
        var size:CGSize = self.bounds.size
        if (contentMode == .scaleToFill || contentMode == .scaleAspectFill || contentMode == .scaleAspectFit || contentMode == .redraw) {
            size.width = CGFloat(floorf((Float(self.bounds.width*multiply) * scale) / scale))
            size.height = CGFloat(floorf((Float(self.bounds.height*multiply) * scale) / scale))
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale))
        let context = UIGraphicsGetCurrentContext()
        let path = CGPath(ellipseIn: self.bounds, transform: nil)
        context!.addPath(path)
        context?.clip()
        
        // Fill
        context!.setFillColor(color.cgColor)
        context!.fill(CGRect(x:0, y:0, width:size.width, height:size.height))
        
        // Text
        let textAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font :  UIFont(name: "HelveticaNeue", size: size.height*0.5)!]
        let textSize:CGSize = displayString.size(withAttributes: textAttributes)
        let bounds:CGRect = self.bounds
        displayString.draw(in: CGRect(x:bounds.size.width/2 - textSize.width/2, y:bounds.size.height/2 - textSize.height/2, width:textSize.width, height:textSize.height), withAttributes: textAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIView {
    func loadingFooterView() -> UIView {
        let view = self
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: view.frame.size.width/2 - 20, y: 0, width: 40, height: 40))
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.color = .gray
        activityIndicatorView.startAnimating()
        footerView.addSubview(activityIndicatorView)
        return footerView
    }
    func errorFooterView() -> UIView {
        let view = self
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 23))
        footerView.backgroundColor = UIColor.clear
        let footerLabel = UILabel(frame: CGRect(x: 0, y: 7, width: view.frame.size.width, height: 23))
        footerLabel.addProperties
        footerLabel.text = ReachabilityManager.shared.isNetworkAvailable ? "Произошла ошибка" : "Вероятно, соединение с интернетом прервано"
        footerView.addSubview(footerLabel)
        return footerView
    }
}

extension UILabel {
    var addProperties: Void {
        let label = self
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        label.numberOfLines = 0
    }
}

extension UIAlertController {
    var addCancelAction: Void {
        self.addAction(UIAlertAction(title: "Отменить", style: .cancel))
    }
    var addOkAction: Void {
        self.addAction(UIAlertAction(title: "Хорошо", style: .default))
    }
    func addDefaultAction(title: String, handler: @escaping (() -> Void)) {
        self.addAction(UIAlertAction(title: title, style: .default, handler: { _ in handler() }))
    }
    func addDestructiveAction(title: String, handler: @escaping (() -> Void)) {
        self.addAction(UIAlertAction(title: title, style: .destructive, handler: { _ in handler() }))
    }
    
//    func popoverPresentitaionForiPad(for table: UITableView) {
//        self.popoverPresentationController?.sourceView = table
//        self.popoverPresentationController?.sourceRect = table.cellForRow(at: table.indexPathForSelectedRow!)!.frame
//    }
}

extension Int {
    var getFileDeclension: String {
        let count = self
        let r = count % 100
        if r > 10 && r < 20 {
            return " файлов"
        } else {
            switch count % 10 {
            case 1: return " файл"
            case 2...4: return " файла"
            default: return " файлов"
            }
        }
    }
    
    var getTopicDeclension: String {
        let count = self
        let r = count % 100
        if r > 10 && r < 20 {
            return " тем"
        } else {
            switch count % 10 {
            case 1: return " тема"
            case 2...4: return " темы"
            default: return " тем"
            }
        }
    }
    
    var getMessageDeclension: String {
        let count = self
        let r = count % 100
        if r > 10 && r < 20 {
            return " сообщений"
        } else {
            switch count % 10 {
            case 1: return " сообщение"
            case 2...4: return " сообщения"
            default: return " сообщений"
            }
        }
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2", "iPhone5,3", "iPhone5,4", "iPhone6,1", "iPhone6,2", "iPhone8,4":return "iPhone 5"
        case "iPhone7,2", "iPhone8,1":                  return "iPhone 6"
        case "iPhone7,1", "iPhone8,2":                  return "iPhone 6 Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "9.7 Inch"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "9.7 Inch"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "9.7 Inch"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "9.7 Inch"
        case "iPad7,5", "iPad7,6":                      return "9.7 Inch"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "9.7 Inch"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "9.7 Inch"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "9.7 Inch"
        case "iPad5,1", "iPad5,2":                      return "9.7 Inch"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}



