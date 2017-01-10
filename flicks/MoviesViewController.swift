//
//  MoviesViewController.swift
//  flicks
//
//  Created by Nick McDonald on 1/9/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var moviesTableView: UITableView!
    private var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.moviesTableView.dataSource = self
        self.moviesTableView.delegate = self
        
        self.loadMoviesData()
        
    }
    
    private func loadMoviesData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    self.moviesTableView.reloadData()
                }
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = self.movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let baseURL = "https://image.tmdb.org/t/p/w500"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as? MoviesTableViewCell
        
        let movie = self.movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        let imageURL = NSURL(string: baseURL + posterPath)
        
        cell?.title.text = title
        cell?.overview.text = overview
        cell?.moviePosterImageView.setImageWith(imageURL as! URL)
        
        return cell!
        
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
