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
    let progressBar = UIProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        mergeVideos()
        setProgressBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.removeObserver(self, forKeyPath: "status")
    }
    
    private func setProgressBar() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let yAxis: CGFloat = (navigationController?.navigationBar.bounds.height ?? 0) + statusBarHeight
        progressBar.frame = CGRect(x: 0, y: yAxis, width: view.bounds.width, height: 15)
        progressBar.progressTintColor = whaleColor
        view.addSubview(progressBar)
    }

    private func mergeVideos() {
        DispatchQueue.global().async {
            VideoMerger.mergeVideos(urls: self.outputUrls) { (filePath) in
                DispatchQueue.main.async {
                    let playerItem = AVPlayerItem(url: filePath)
                    self.player.replaceCurrentItem(with: playerItem)
                    
                    self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(Int64(1.0), Int32(60.0)), queue: nil, using: { (time) in
                        self.updateProgressBar()
                    })
                    
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
    
    func updateProgressBar() {
        if let currentItem = player.currentItem {
            let duration = CMTimeGetSeconds(currentItem.duration)
            let time = CMTimeGetSeconds(player.currentTime())
            progressBar.progress = Float(time/duration)
        }
    }
    
    
    //MARK: - Helpers
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            guard (object as? AVPlayer)?.status == .readyToPlay else { return }
            player.play()
        }
    }

}










