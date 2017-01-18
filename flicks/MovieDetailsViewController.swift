//
//  MovieDetailsViewController.swift
//  flicks
//
//  Created by Nick McDonald on 1/14/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import SwiftDate

class MovieDetailsViewController: UIViewController {
    
    // Key-value info about movie.
    var movie: NSDictionary!
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieRatingLabel: UILabel!
    @IBOutlet weak var movieReleaseDateLabel: UILabel!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    @IBOutlet weak var moviePopularityLabel: UILabel!
    @IBOutlet weak var movieNumOfVotesLabel: UILabel!
    @IBOutlet weak var movieBackdropImageView: UIImageView!
    @IBOutlet weak var movieInfoContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionContentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        
        var gradient = CAGradientLayer()
        gradient.frame = self.movieInfoContentView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 1.0]
        self.movieInfoContentView.layer.insertSublayer(gradient, at: 0)
        
        gradient = CAGradientLayer()
        gradient.frame = self.movieBackdropImageView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.85, 1.0]
        self.movieBackdropImageView.layer.insertSublayer(gradient, at: 0)
        
        if let posterPath = movie[moviesPosterPathPropertyIdentifier] as? String {
            let imageURL = NSURL(string: moviesDBBaseImagePath + posterPath)
            self.movieBackdropImageView.alpha = 0.0
            self.movieBackdropImageView.setImageWith(imageURL as! URL)
            UIView.animate(withDuration: 0.3, animations: { Void in
                self.movieBackdropImageView.alpha = 1.0
            })
        }
        
        self.movieTitleLabel.text = movie[moviesTitlePropertyIdentifier] as? String
        self.movieRatingLabel.text = String(movie[moviesVoteAveragePropertyIdentifier] as! Float)
        self.movieOverviewLabel.text = movie[moviesOverviewPropertyIdentifier] as? String
        self.movieOverviewLabel.sizeToFit()
        self.movieNumOfVotesLabel.text = "\(movie[moviesVoteCountPropertyIdentifier] as! Int) votes"
        self.moviePopularityLabel.text = String(movie[moviesPopularityPropertyIdentifier] as! Float)
        
        let releaseDate = self.parseDate(asString: movie[moviesReleaseDatePropertyIdentifier] as! String)
        self.movieReleaseDateLabel.text = releaseDate
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.descriptionContentView.frame.maxY)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func parseDate(asString input: String) -> String {
        let date: DateInRegion = try! DateInRegion(string: input, format: .custom("yyyy-MM-dd"))
        let relevantTime = date.string(dateStyle: .medium, timeStyle: .none)
        
        return relevantTime
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
