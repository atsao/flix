//
//  MoviesViewController.swift
//  Flix
//
//  Created by Andrew Tsao on 10/14/16.
//  Copyright © 2016 Andrew Tsao. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var MovieTableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MovieTableView.dataSource = self
        MovieTableView.delegate = self
        
        fetchMovies(endpoint: self.endpoint)
    }
    
    func fetchMovies(endpoint: String) {
        let api_key = "1963f8d3c739cf3c9117d9ef475f6935"
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(api_key)")
        let request = URLRequest(url: url! as URL)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
            
            if errorOrNil != nil {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.showNetworkError()
            } else {
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                        self.successCallback(responseDictionary: responseDictionary)
                    }
                }
            }
        });
        task.resume()
    }
    
    func showNetworkError() {
        self.networkErrorView.isHidden = false
    }
    
    func hideNetworkError() {
        self.networkErrorView.isHidden = true
    }
    
    func successCallback(responseDictionary: NSDictionary) {
        MBProgressHUD.hide(for: self.view, animated: true)
        hideNetworkError()
        self.movies = responseDictionary["results"] as? [NSDictionary]
        self.MovieTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MovieTableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath) as! URL
            cell.posterView.setImageWith(imageUrl)
        }
        
        cell.titleLabel.text = "\(title)"
        cell.overviewLabel.text = "\(overview)"

        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = MovieTableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]

        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
    }

}
