//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    let sentimentClassifier = TwitterSentimentClassifier()

    let swifter = Swifter(consumerKey: "", consumerSecret: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func fetchTweets(){
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                var tweets = [TwitterSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        tweets.append( TwitterSentimentClassifierInput(text: tweet))
                    }
                }
                self.makePrediction(tweets: tweets)
                
            }) { (error) in
                print("There was an error with the Twitter API request, \(error)")
            }
        }    }
    
    func makePrediction(tweets: [TwitterSentimentClassifierInput]){
        do {
            let predictionResult = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0.0
            for prediction in predictionResult{
                let setiment = prediction.label
                if setiment == "Pos" {sentimentScore += 1}
                else if setiment == "Neg" {sentimentScore -= 1}
            }
            print("Score:\(sentimentScore)")
            
            updateUI(sentimentScore: sentimentScore)
            
        } catch{
            print("Making predictions Error:\(error)")
        }
    }
    
    func updateUI(sentimentScore: Double){
        if sentimentScore > 20 { self.sentimentLabel.text = "😍"}
        else if sentimentScore < -20 {self.sentimentLabel.text = "😇"}
        else  {self.sentimentLabel.text = "🤠"}
    }

    @IBAction func predictPressed(_ sender: Any) {
        
       fetchTweets()
    }
}

