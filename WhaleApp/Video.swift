//
//  Video.swift
//  WhaleApp
//
//  Created by Dan Kindler on 12/3/16.
//  Copyright © 2016 Dan Kindler. All rights reserved.
//

import UIKit

class Video: NSObject {
    var assetUrl: URL?
    var lengthInSeconds: CGFloat
    
    init(url: URL, length: CGFloat) {
        assetUrl = url
        lengthInSeconds = length
    }
}
