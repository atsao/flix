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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var MovieTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var MovieCollectionView: UICollectionView!
    @IBOutlet weak var layoutControl: UISegmentedControl!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var searchActive: Bool = false
    var endpoint: String!
    var layout: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize = UIScreen.main.bounds
        
        MovieTableView.dataSource = self
        MovieTableView.delegate = self
        searchBar.delegate = self
        
        MovieCollectionView.dataSource = self
        MovieCollectionView.delegate = self
        
        layoutControl.selectedSegmentIndex = layout
        setLayout()
        
        fetchMovies(endpoint: self.endpoint)
        filteredMovies = movies
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!")
        MovieTableView.insertSubview(refreshControl, at: 0)
        
        let tableInsets = UIEdgeInsetsMake(0, 0, 50, 0)
        MovieTableView.contentInset = tableInsets
        
        let tiles: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        tiles.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        tiles.itemSize = CGSize(width: screenSize.width / 3, height: 185)
        tiles.minimumInteritemSpacing = 0
        tiles.minimumLineSpacing = 0
        MovieCollectionView.collectionViewLayout = tiles
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red: 76/255, green: 104/255, blue: 117/255, alpha: 1.0)
            navigationBar.tintColor = UIColor(red: 56/255, green: 75/255, blue: 86/255, alpha: 1.0)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor(red: 56/255, green: 75/255, blue: 86/255, alpha: 1.0)
            shadow.shadowOffset = CGSize(width: 1, height: 1)
            shadow.shadowBlurRadius = 1;
            navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.white,
                NSShadowAttributeName: shadow
            ]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let indexPath = self.MovieTableView.indexPathForSelectedRow
        if let selectedIndexPath = indexPath {
            self.MovieTableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        
        tabBarController?.tabBar.tintColor = COLOR.Slate
    }
    
    @IBAction func changeLayout(_ sender: AnyObject) {
        if layout == 0 {
            layout = 1
        } else {
            layout = 0
        }
        self.setLayout()
    }
    
    func setLayout() {
        if (layout == 0) {
            MovieCollectionView.isHidden = true
            MovieTableView.isHidden = false
        } else {
            MovieCollectionView.isHidden = false
            MovieTableView.isHidden = true
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies?.filter({ movie in
            let title = movie["title"] as! String
            return title.range(of: searchText, options: .caseInsensitive) != nil
        })

        searchActive = !(filteredMovies?.isEmpty)!
        
        self.MovieTableView.reloadData()
        self.MovieCollectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        filteredMovies = movies
        self.MovieTableView.reloadData()
        self.MovieCollectionView.reloadData()
        self.searchBar.resignFirstResponder()
    }
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        print("refreshing!!!!!!!!!!!")
        let url = URL(string:"\(API.URL)/\(endpoint!)?api_key=\(API.Key)")
        let request = URLRequest(url: url! as URL)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
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
            refreshControl.endRefreshing()
        });
        task.resume()
    }
    
    func fetchMovies(endpoint: String) {
        let url = URL(string:"\(API.URL)/\(endpoint)?api_key=\(API.Key)")
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
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            var networkErrorFrame = self.networkErrorView.frame
            networkErrorFrame.origin.y += self.networkErrorView.frame.size.height
            self.networkErrorView.frame = networkErrorFrame
            }, completion: { finished in
                
        })
    }
    
    func hideNetworkError() {
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            var networkErrorFrame = self.networkErrorView.frame
            networkErrorFrame.origin.y -= self.networkErrorView.frame.size.height
            self.networkErrorView.frame = networkErrorFrame
            }, completion: { finished in
                
        })
        
        self.networkErrorView.isHidden = true
    }
    
    func successCallback(responseDictionary: NSDictionary) {
        MBProgressHUD.hide(for: self.view, animated: true)
        hideNetworkError()
        let movieData = responseDictionary["results"] as? [NSDictionary]
        self.movies = movieData
        self.filteredMovies = movieData
        self.MovieTableView.reloadData()
        self.MovieCollectionView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let movies = self.filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MovieTableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = IMG.BaseURL
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath) as! URL
            let imageRequest = URLRequest(url: imageUrl)
            cell.posterView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) in
                    if imageResponse != nil {
                        cell.posterView.alpha = 0
                        cell.posterView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1
                        })
                    } else {
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, image) in
                    print("Error!")
            })
        }
        
        cell.titleLabel.text = "\(title)"
        cell.overviewLabel.text = "\(overview)"
        cell.selectionStyle = .blue
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if let movies = self.filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = MovieCollectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionCell", for: indexPath) as! MovieCollectionCell
        let movie = filteredMovies![indexPath.row]
        let baseUrl = IMG.BaseURL
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath) as! URL
            let imageRequest = URLRequest(url: imageUrl)
            cell.posterView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) in
                    if imageResponse != nil {
                        cell.posterView.alpha = 0
                        cell.posterView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1
                        })
                    } else {
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, image) in
                    print("Error!")
            })
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableCellSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = MovieTableView.indexPath(for: cell)
            let movie = filteredMovies![indexPath!.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
        
        if (segue.identifier == "collectionCellSegue") {
            let cell = sender as! UICollectionViewCell
            let indexPath = MovieCollectionView.indexPath(for: cell)
            let movie = filteredMovies![indexPath!.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
        
    }

}
