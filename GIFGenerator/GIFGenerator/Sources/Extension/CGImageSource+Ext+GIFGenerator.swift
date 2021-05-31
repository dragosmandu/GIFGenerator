//
//
//  Workspace: GIFGenerator
//  MacOS Version: 11.4
//			
//  File Name: CGImageSource+Ext+GIFGenerator.swift
//  Creation: 5/31/21 9:42 PM
//
//  Author: Dragos-Costin Mandu
//
//
	

import ImageIO

public extension CGImageSource
{
    // MARK: - Methods
    
    /// Resizing the image at given index in current CGImageSource.
    /// - Parameters:
    ///   - thumbnailMaxPixelSize: The maximum width and height in pixels of a thumbnail.
    ///   - index: The index that specifies the location of the image. The index is zero-based.
    /// - Returns: The downsampled CGImage.
    ///
    /// If the maximum size isn't provided, the maximum size may be as the original.
    ///
    func downsample(thumbnailMaxPixelSize: CGFloat? = nil, imageIndex: Int = 0) -> CGImage?
    {
        var downsampleOptions =
            [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true
            ] as CFDictionary
        
        if let thumbnailMaxPixelSize = thumbnailMaxPixelSize
        {
            downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: thumbnailMaxPixelSize
            ] as CFDictionary
        }
        
        return CGImageSourceCreateThumbnailAtIndex(self, imageIndex, downsampleOptions)
    }
}
