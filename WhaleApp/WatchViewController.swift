//
//  WatchViewController.swift
//  WhaleApp
//
//  Created by Dan Kindler on 12/3/16.
//  Copyright © 2016 Dan Kindler. All rights reserved.
//

import UIKit
import AVFoundation


class WatchViewController: UIViewController {
    
    // Properties
    var outputUrls = [URL]()
    var playerLayer = AVPlayerLayer()
    var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        mergeVideos()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.removeObserver(self, forKeyPath: "status")
    }

    private func mergeVideos() {
        DispatchQueue.global().async {
            VideoMerger.mergeVideos(urls: self.outputUrls) { (filePath) in
                DispatchQueue.main.async {
                    let playerItem = AVPlayerItem(url: filePath)
                    self.player.replaceCurrentItem(with: playerItem)
                    self.setupVideoLayer()
                }
            }
        }
    }
    
    private func setupVideoLayer() {
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = view.layer.bounds
        view.layer.insertSublayer(playerLayer, at: 0)

        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        player.addObserver(self, forKeyPath: "status", options: [], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    //MARK: - Action
    func playerItemDidReachEnd(notification: Notification) {
        player.seek(to: kCMTimeZero)
        player.play()
    }
    
    
    //MARK: - Helpers
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            guard (object as? AVPlayer)?.status == .readyToPlay else { return }
            player.play()
        }
    }

}










