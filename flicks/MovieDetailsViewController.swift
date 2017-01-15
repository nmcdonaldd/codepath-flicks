//
//  MovieDetailsViewController.swift
//  flicks
//
//  Created by Nick McDonald on 1/14/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    // Key-value info about movie.
    var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: self.contentView.frame.origin.y + self.contentView.frame.size.height)
        
        self.titleLabel.text = movie[moviesTitlePropertyIdentifier] as? String
        self.descriptionLabel.text = movie[moviesOverviewPropertyIdentifier] as? String
        self.descriptionLabel.sizeToFit()
        
        if let posterPath = movie[moviesPosterPathPropertyIdentifier] as? String {
            let imageURL = NSURL(string: moviesDBBaseImagePath + posterPath)
            self.moviePosterImageView.setImageWith(imageURL as! URL)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
