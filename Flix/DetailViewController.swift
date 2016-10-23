//
//  DetailViewController.swift
//  Flix
//
//  Created by Andrew Tsao on 10/17/16.
//  Copyright © 2016 Andrew Tsao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        let baseUrlLow = IMG.BaseURLLowRes
        let baseUrlHigh = IMG.BaseURLHighRes
//        if let posterPath = movie["poster_path"] as? String {
//            let imageUrl = NSURL(string: baseUrl + posterPath) as! URL
//            posterImageView.setImageWith(imageUrl)
//        }
        if let posterPath = movie["poster_path"] as? String {
            let lowResUrl = NSURL(string: baseUrlLow + posterPath) as! URL
            let highResUrl = NSURL(string: baseUrlHigh + posterPath) as! URL
            let lowResImageRequest = URLRequest(url: lowResUrl)
            let highResImageRequest = URLRequest(url: highResUrl)
            
            self.posterImageView.setImageWith(
                lowResImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) in
                    if smallImageResponse != nil {
                        self.posterImageView.alpha = 0
                        self.posterImageView.image = smallImage
                        UIView.animate(withDuration: 0.3,
                            animations: { () -> Void in
                                self.posterImageView.alpha = 1
                            },
                            completion: { (success) -> Void in
                                self.posterImageView.setImageWith(
                                    highResImageRequest,
                                    placeholderImage: nil,
                                    success: { (largeImageRequest, largeImageResponse, largeImage) in
                                        self.posterImageView.image = largeImage
                                    },
                                    failure: { (req, res, error) in
                                        print("Error!")
                                })
                    
                        })
                    } else {
                        self.posterImageView.image = smallImage
                    }
                },
                failure: { (req, res, error) in
                    print("Error!")
            })
        }
        
        
        titleLabel.text = movie["title"] as! String?
        overviewLabel.text = movie["overview"] as! String?
        overviewLabel.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
