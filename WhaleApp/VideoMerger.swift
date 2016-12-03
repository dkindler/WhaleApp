//
//  VideoMerger.swift
//  WhaleApp
//
//  Created by Dan Kindler on 12/3/16.
//  Copyright © 2016 Dan Kindler. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import AssetsLibrary

class VideoMerger: NSObject {

    static func mergeVideos(urls: [URL], completion: ((URL) -> ())?) {
        let composition = AVMutableComposition()
        let track = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID:Int32(kCMPersistentTrackID_Invalid))
        let audioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID:Int32(kCMPersistentTrackID_Invalid))

        
        for (index, currentUrl) in urls.enumerated() {
            let videoAsset = AVAsset(url: currentUrl) as AVAsset
            let atTime = index == 0 ? kCMTimeZero : composition.duration
            do {
                try track.insertTimeRange(CMTimeRangeMake(kCMTimeZero,  videoAsset.duration), of: videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: atTime)
                try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,  videoAsset.duration), of: videoAsset.tracks(withMediaType: AVMediaTypeAudio)[0], at: atTime)
                
            } catch _ {
                break
            }
        }
        
        for compTrack in composition.tracks(withMediaType: AVMediaTypeVideo) {
            compTrack.preferredTransform = CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0)
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("\(String.randomString(length: 7)).mp4")

        if let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) {
            exporter.outputURL = filePath
            exporter.outputFileType = AVFileTypeMPEG4
            exporter.shouldOptimizeForNetworkUse = true
            
            exporter.exportAsynchronously(completionHandler: {
                completion?(filePath)
            })
        }
    }
}






