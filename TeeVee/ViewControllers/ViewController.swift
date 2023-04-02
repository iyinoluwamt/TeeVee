//
//  ViewController.swift
//  TeeVee
//
//  Created by Iyinoluwa Tugbobo on 4/2/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ApplicationManager.shared.getShowsFromAPI(endpoints: ["popular"]) {result in
            
        }
    }


}

