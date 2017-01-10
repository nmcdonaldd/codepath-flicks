//
//  MoviesTableViewCell.swift
//  flicks
//
//  Created by Nick McDonald on 1/9/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class MoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let gradient = CAGradientLayer()
        gradient.frame = self.moviePosterImageView.bounds
        let blackColor: CGColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.70).cgColor
        gradient.colors = [UIColor.clear.cgColor, blackColor]
        gradient.locations = [0.5, 1.0]
        self.moviePosterImageView.layer.insertSublayer(gradient, at: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
