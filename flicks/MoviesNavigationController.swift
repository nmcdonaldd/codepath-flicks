//
//  MoviesNavigationController.swift
//  flicks
//
//  Created by Nick McDonald on 1/17/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class MoviesNavigationController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.delegate = self
        self.navigationBar.tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        // Below is testing if the viewController passed in is of type MoviesViewController, else it is of type MovieDetailsViewController
        if let vc = viewController as? MoviesViewController {
            self.navigationBar.setBackgroundImage(nil, for: .default)
            self.navigationBar.shadowImage = nil
            vc.title = vc.titleString
        } else {
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.topItem?.title = ""
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
