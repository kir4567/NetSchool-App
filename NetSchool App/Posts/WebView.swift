//
//  WebView.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 07.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
import WebKit
import Reachability
import SafariServices

class WebViewn: UIViewController, WKNavigationDelegate {
    
    var link, ADT, DDT: String?
    var indexPath: IndexPath?
    
    /// Web View
    private var webView = WKWebView()
    /// Loading activity indacator
    private var 📦 = UIView()
    private static var statusBarHeight = UIApplication.shared.statusBarFrame.height
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    
    var navigationBarHeight: CGFloat = 0
    
    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        let action1 = UIPreviewAction(title: "Открыть в Safari", style: .default) {_,_ in
            UIApplication.shared.openURL(self.link!.toURL as URL)
        }
        let action2 = UIPreviewAction(title: "Скопировать ссылку", style: .default) {_,_ in
            UIPasteboard.general.string = self.link
        }
        return [action1, action2]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewSetup()
        createAndSetupNavigationBar()
        getData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        task?.cancel()
    }
    
    /// Loads data
    private func getData() {
        📦 = self.view.loadingFooterView()
        📦.frame = CGRect(x: 0, y: navigationBarHeight + WebViewn.statusBarHeight + 10, width: view.frame.width, height: 40)
        self.view.addSubview(📦)
        loadURL()
    }
    
    /// Web View creation and configuration
    private func webViewSetup() {
        let wkWebView = WKWebView(frame: CGRect(x: 0, y: navigationBarHeight + WebViewn.statusBarHeight, width: self.view.frame.width, height: self.view.frame.height - navigationBarHeight - WebViewn.statusBarHeight))
        webView = wkWebView
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(wkWebView)
        let webTopSpaceToContainer = NSLayoutConstraint(item: self.view, attribute: .topMargin, relatedBy: .equal, toItem: webView, attribute: .top, multiplier: 1, constant: -navigationBarHeight)
        var constant:CGFloat = 0
        if #available(iOS 11.0, *) {
            constant = -(UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        }
        let webBottomSpaceToContainer = NSLayoutConstraint(item: self.view, attribute: .bottomMargin, relatedBy: .equal, toItem: webView, attribute: .bottom, multiplier: 1, constant: constant)
        let webLeadingSpaceToContainer = NSLayoutConstraint(item: self.view, attribute: .leadingMargin, relatedBy: .equal, toItem: webView, attribute: .leading, multiplier: 1, constant: 20)
        let webTrailingSpaceToContainer = NSLayoutConstraint(item: self.view, attribute: .trailingMargin, relatedBy: .equal, toItem: webView, attribute: .trailing, multiplier: 1, constant: -20)
        let webViewConstaints = [webTopSpaceToContainer,webBottomSpaceToContainer,webLeadingSpaceToContainer,webTrailingSpaceToContainer]
        self.view.addConstraints(webViewConstaints)
    }
    
    /// Navigation bar сreation and configuration
    private func createAndSetupNavigationBar() {
        view.backgroundColor = .white
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: navigationBarHeight))
        let navItem = UINavigationItem(title: "")
        let cancelItem = UIBarButtonItem(title: "Закрыть", style: .plain , target: self, action: #selector(cancel))
        navItem.rightBarButtonItem = createBarButtonItem(imageName: "share", selector: #selector(openLink))
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
    
    @objc private func cancel() {
        dismiss()
    }
    
    /// Loads URL
    private func loadURL() {
        if ReachabilityManager.shared.isNetworkAvailable {
            webView.navigationDelegate = self
            if let url = self.link?.toURL {
                _ = self.webView.load(URLRequest(url: url as URL))
            }
        } else {
            self.📦.removeFromSuperview()
            📦 = self.view.errorFooterView()
            📦.frame = CGRect(x: 0, y: 70 , width: view.frame.width, height: 23)
            self.view.addSubview(self.📦)
        }
    }
    
    /**
     Sets loading error.
     Internal due to access from Status and reload function
     */
    func setError() {
        DispatchQueue.main.async {
            self.📦.removeFromSuperview()
            self.📦 = self.view.errorFooterView()
            self.📦.frame = CGRect(x: 0, y: 70 , width: self.view.frame.width, height: 23)
            self.view.addSubview(self.📦)
        }
    }
    
    /// Show share screen
    @objc private func openLink(sender: UIButton) {
        let secondActivityItem: NSURL = NSURL(string: link!)!
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [secondActivityItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        self.present(activityViewController)
    }
    
    /// Removes activity indicator after loading is complete
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { 📦.removeFromSuperview() }
}

@available(iOS 9.0, *)
class CustomSafariViewController: SFSafariViewController {
    override func viewWillAppear(_ animated: Bool) {
//        UIApplication.shared.statusBarStyle = .default
    }
    override func viewWillDisappear(_ animated: Bool) {
//        UIApplication.shared.statusBarStyle = .schemeStyle
    }
}









