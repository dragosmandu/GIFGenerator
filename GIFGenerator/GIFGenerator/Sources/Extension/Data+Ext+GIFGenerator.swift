//
//
//  Workspace: GIFGenerator
//  MacOS Version: 11.4
//			
//  File Name: Data+Ext+GIFGenerator.swift
//  Creation: 5/31/21 9:41 PM
//
//  Author: Dragos-Costin Mandu
//
//
	

import Foundation
import ImageIO

public extension Data
{
    // MARK: - Methods
    
    /// Resizing the image at given index from a image source with current data.
    /// - Parameters:
    ///   - thumbnailMaxPixelSize: The maximum width and height in pixels of a thumbnail.
    ///   - index: The index that specifies the location of the image. The index is zero-based.
    /// - Returns: The downsampled CGImage.
    ///
    /// If the maximum size isn't provided, the maximum size may be as the original.
    ///
    func downsampleImage(thumbnailMaxPixelSize: CGFloat? = nil, imageIndex: Int = 0) -> CGImage?
    {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, imageSourceOptions)
        else
        {
            return nil
        }
        
        return imageSource.downsample(thumbnailMaxPixelSize: thumbnailMaxPixelSize, imageIndex: imageIndex)
    }
}

