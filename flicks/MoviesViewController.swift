//
//  MoviesViewController.swift
//  flicks
//
//  Created by Nick McDonald on 1/9/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate/*UISearchResultsUpdating*/ {

    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    private var movies: [NSDictionary]?
    private var refreshControl: UIRefreshControl!
    private var filteredMovies: [NSDictionary]?
    private var moviesSearchBarPreviouslyFilled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.moviesTableView.dataSource = self
        self.moviesTableView.delegate = self
        self.moviesSearchBar.delegate = self
        self.moviesSearchBar.keyboardAppearance = .dark
        
        self.loadMoviesData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShown(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDismissed(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.clear
        self.refreshControl.addTarget(self, action: #selector(self.refreshControlTriggered), for: .valueChanged)
        //self.setUpSearchController()
        self.moviesTableView.insertSubview(self.refreshControl, at: 0)
    }
    
//    func setUpSearchController() {
//        // Setup the UISearchBar --> TODO: - Move to separate function.
//        self.searchController = UISearchController(searchResultsController: nil)
//        self.searchController.searchResultsUpdater = self
//        self.searchController.dimsBackgroundDuringPresentation = false
//        self.searchController.searchBar.sizeToFit()
//        self.moviesTableView.tableHeaderView = self.searchController.searchBar
//        self.searchController.searchBar.barStyle = .blackTranslucent
//        self.searchController.searchBar.keyboardAppearance = .dark
//        definesPresentationContext = true
//    }
    
    func keyboardDismissed(notification: Notification) {
        self.moviesTableView.contentInset.bottom = 0
    }
    
    func keyboardShown(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.moviesTableView.contentInset.bottom = keyboardSize.height
        }
    }
    
    func refreshControlTriggered() {
        let url = URL(string: moviesDBNowPlayingEndpoint + moviesDBAPIKey)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary[moviesResultsPropertyIdentifier] as? [NSDictionary]
                    //self.updateSearchResults(for: self.searchController)
                    self.searchBar(self.moviesSearchBar, textDidChange: self.moviesSearchBar.text!)
                    self.moviesTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
        task.resume()
    }

    
    private func loadMoviesData() {
        let url = URL(string: moviesDBNowPlayingEndpoint + moviesDBAPIKey)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        self.showHUD()
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary[moviesResultsPropertyIdentifier] as? [NSDictionary]
                    //self.updateSearchResults(for: self.searchController)
                    self.searchBar(self.moviesSearchBar, textDidChange: self.moviesSearchBar.text!)
                    self.moviesTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
            self.hideHUD()
        }
        task.resume()
    }
    
    func showHUD() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
    }
    
    func hideHUD() {
        SVProgressHUD.dismiss()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let moviesToShow = self.filteredMovies {
            return moviesToShow.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: moviesCellReusableIdentifier) as? MoviesTableViewCell
        
        let movie = self.filteredMovies![indexPath.row]
        let title = movie[moviesTitlePropertyIdentifier] as! String
        let posterPath = movie[moviesBackdropPathPropertyIdentifier] as! String
        let imageURL = NSURL(string: moviesDBBaseImagePath + posterPath)
        let releaseDate = movie[moviesReleaseDatePropertyIdentifier] as! String
        let rating = movie[moviesVoteAveragePropertyIdentifier] as! Float
        
        cell?.title.text = title
        cell?.moviePosterImageView.setImageWith(imageURL as! URL)
        cell?.releaseDateLabel.text = releaseDate
        cell?.ratingLabel.text = String(rating)
        
        return cell!
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredMovies = searchText.isEmpty ? self.movies : self.movies!.filter({(dataDict: NSDictionary) -> Bool in
            let returnVal: Bool = (dataDict[moviesTitlePropertyIdentifier] as! String).lowercased().range(of: searchText.lowercased()) != nil
            return returnVal
        })
        
        let shouldShowCancelButton: Bool = searchText.isEmpty ? false : true
        
        if shouldShowCancelButton != self.moviesSearchBarPreviouslyFilled {
            //self.moviesSearchBar.setShowsCancelButton(shouldShowCancelButton, animated: true)
            print("animating!")
            self.moviesSearchBarPreviouslyFilled = !self.moviesSearchBarPreviouslyFilled
        }
        
        self.moviesTableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text!)
        if let searchText = searchController.searchBar.text {
            self.filteredMovies = searchText.isEmpty ? self.movies : self.movies!.filter({(dataDict: NSDictionary) -> Bool in
                let returnVal: Bool = (dataDict[moviesTitlePropertyIdentifier] as! String).lowercased().range(of: searchText.lowercased()) != nil
                print(returnVal)
                return returnVal
            })
            
            self.moviesTableView.reloadData()
        }
    }
    
    
    // MARK: - UISearchBarDelegate methods
    // TODO: - Keep search bar right below the navigationbar! Also make it behind the navigationBar when first opening!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
