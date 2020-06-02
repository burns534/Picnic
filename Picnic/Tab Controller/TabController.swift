//
//  Tab ControllerViewController.swift
//  Picnic
//
//  Created by Kyle Burns on 5/25/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class TabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controllers = [Featured(collectionViewLayout: CustomFlowLayout())]
        
        viewControllers = controllers.map {
            UINavigationController(rootViewController: $0)
        }
        
        selectedIndex = 0
        // Do any additional setup after loading the view.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
