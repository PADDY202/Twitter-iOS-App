//
//  TweetsTVC.swift
//  TwitterStartupCode
//
//  Created by Padraig Mitchell on 24/03/2017.
//  Copyright © 2017 CS_UCD. All rights reserved.
//
import Foundation
import UIKit
class TweetsTVC: UITableViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // 1. Use textfield to display list of tweets
    @IBOutlet weak var tweetsTextView: UITextView! {
        didSet {
            tweetsTextView.text = ""
        }
    }
    
    // 2. Tweeter request (default search string is #UCD retrieving at most 2 tweets for any given request)
    static let ucdRequest = TwitterRequest(search: "#UCD", count: 2)
    private var twitterRequest: TwitterRequest?
    
    // 3. Data model: array of tweets
    private var tweets = [TwitterTweet]() {
        didSet {
            // For each tweet, print screen name and total of mentions + hashtags... contained in tweet
            let text = tweets.reduce("") { return "\($0)\n\($1.user.screenName) (\($1.hashtags.count + $1.urls.count + $1.userMentions.count + $1.media.count))" }
            self.tweetsTextView.text = text.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        }
    }
    
    // 4. Fetch older tweets using twitterRequest (connected to UIButton More)
    @IBAction func more(_ sender: AnyObject?) {
        // if request does not exist, create new one
        let request = twitterRequest?.requestForOlder ?? TweetsTVC.ucdRequest
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            request.fetchTweets { (oldTweets) -> Void in
                if oldTweets.count > 0 {
                    self.twitterRequest = request
                    DispatchQueue.main.async { () -> Void in
                        self.tweets.append(contentsOf: oldTweets)
                    }
                }
            }
        }
    }
    
    // 5. Fetch newer tweets using twitterRequest (connected to UIButton Refresh)
    @IBAction func refresh(_ sender: AnyObject?) {
        // if request does not exist, create new one
        let request = twitterRequest?.requestForNewer ?? TweetsTVC.ucdRequest
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            request.fetchTweets { (newTweets) -> Void in
                if newTweets.count > 0 {
                    self.twitterRequest = request
                    DispatchQueue.main.async { () -> Void in
                        self.tweets.insert(contentsOf: newTweets, at: 0)
                    }
                }
            }
        }
    }

}
