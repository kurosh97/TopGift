//
//  WebKitViewController.swift
//  TopGift
//
//  Created by iosdev on 3.12.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit
import WebKit

/// WebKitViewController.swift
/// TopGift
///
/// Loads and displays website by using the url given in this class
class WebKitViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var url = URL(string: "https://www.google.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //makes UrlRequest with predefined url from segue or uses google.com
        let request = URLRequest(url: (url ?? URL( string: "https://www.google.com"))!)
        //loads webview
        webView.load(request)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
}
