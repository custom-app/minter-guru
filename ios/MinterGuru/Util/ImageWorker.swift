//
//  ImageWorker.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 02.06.2022.
//

import Foundation
import UIKit

class ImageWorker {
    
    private static let pictureMaxSide: Float = 1400
    
    static func compressImage(image: UIImage, maxHeight: Float = pictureMaxSide,
                       maxWidth: Float = pictureMaxSide) -> UIImage {
        return compress(
            image: image,
            maxHeight: maxHeight,
            maxWidth: maxWidth)
    }
    
    private static func compress(image: UIImage, maxHeight: Float = pictureMaxSide,
                       maxWidth: Float = pictureMaxSide) -> UIImage {
        var actualHeight: Float = Float(image.size.height)
        var actualWidth: Float = Float(image.size.width)
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }

        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
