//
//
//  Workspace: GIFGenerator
//  MacOS Version: 11.4
//			
//  File Name: GIFGenerator.swift
//  Creation: 5/31/21 9:32 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit
import os
import MobileCoreServices
import DownloadTaskManager

let loggerSubsystem: String = Bundle.main.bundleIdentifier!

public class GIFGenerator: NSObject
{
    static var s_LoggerCategory: String = "UIImage"
    static var s_Logger: Logger = .init(subsystem: loggerSubsystem, category: s_LoggerCategory)
    
    static public var s_AnimatedImageDefaultInterFrameDelay: Double = 0.1
    static public var s_AnimatedImageDefaultLoopCount: Int = 0
    
    private let m_DownloadTaskManager: DownloadTaskManager = .init()
    
    private var m_GeneratorCompletionHandler: (_ animatedImage: UIImage?) -> Void
    private var m_FrameMaxPixelSize: CGFloat? = nil
    private var m_FrameCompresionQuality: CGFloat = 1
    private var m_InterFrameDelay: Double = GIFGenerator.s_AnimatedImageDefaultInterFrameDelay
    
    /// - Parameter generatorCompletionHandler: Called when the GIF has been generated.
    public required init(generatorCompletionHandler: @escaping (_ animatedImage: UIImage?) -> Void)
    {
        m_GeneratorCompletionHandler = generatorCompletionHandler
        
        super.init()
        
        m_DownloadTaskManager.delegate = self
    }
    
    /// Generates a GIF with given URL.
    /// - Parameters:
    ///   - url: A local/external URL to get GIF from.
    ///   - frameMaxPixelSize: The maximum width and height in pixels of a thumbnail.
    ///   - frameCompresionQuality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).
    ///   - interFrameDelay: The delay between 2 frames. Set only when the animated image Data doesn't have a delay already.
    public func generateWith(url: URL, frameMaxPixelSize: CGFloat? = nil, frameCompresionQuality: CGFloat = 1, interFrameDelay: Double = GIFGenerator.s_AnimatedImageDefaultInterFrameDelay)
    {
        
        // Checks if it's local URL.
        if url.isFileURL, let data = try? Data(contentsOf: url), let animatedImage = animatedImageWith(data: data, frameMaxPixelSize: frameMaxPixelSize, frameCompresionQuality: frameCompresionQuality, interFrameDelay: interFrameDelay)
        {
            m_GeneratorCompletionHandler(animatedImage)
        }
        else
        {
            
            m_FrameMaxPixelSize = frameMaxPixelSize
            m_FrameCompresionQuality = frameCompresionQuality
            m_InterFrameDelay = interFrameDelay
            
            // Checks cache and if still not found, will start download.
            m_DownloadTaskManager.downloadFor(externalUrl: url)
        }
    }
    
    /// Generates a GIF with given Data.
    /// - Parameters:
    ///   - frameMaxPixelSize: The maximum width and height in pixels of a thumbnail.
    ///   - frameCompresionQuality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).
    ///   - interFrameDelay: The delay between 2 frames. Set only when the animated image Data doesn't have a delay already.
    public func generateWith(data: Data, frameMaxPixelSize: CGFloat? = nil, frameCompresionQuality: CGFloat = 1, interFrameDelay: Double = GIFGenerator.s_AnimatedImageDefaultInterFrameDelay)
    {
        if let animatedImage = animatedImageWith(data: data, frameMaxPixelSize: frameMaxPixelSize, frameCompresionQuality: frameCompresionQuality, interFrameDelay: interFrameDelay)
        {
            m_GeneratorCompletionHandler(animatedImage)
        }
    }
    
    /// Generates a GIF with given CGImageSource.
    /// - Parameters:
    ///   - frameMaxPixelSize: The maximum width and height in pixels of a thumbnail.
    ///   - frameCompresionQuality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).
    ///   - interFrameDelay: The delay between 2 frames. Set only when the animated image Data doesn't have a delay already.
    public func generateWith(imageSource: CGImageSource, frameMaxPixelSize: CGFloat? = nil, frameCompresionQuality: CGFloat = 1, interFrameDelay: Double = GIFGenerator.s_AnimatedImageDefaultInterFrameDelay)
    {
        if let animatedImage = animatedImageWith(imageSource: imageSource, frameMaxPixelSize: frameMaxPixelSize, frameCompresionQuality: frameCompresionQuality, interFrameDelay: interFrameDelay)
        {
            m_GeneratorCompletionHandler(animatedImage)
        }
    }
    
    /// Generates a GIF with given CGImageSources frames.
    /// - Parameters:
    ///   - frameMaxPixelSize: The maximum width and height in pixels of a thumbnail.
    ///   - frameCompresionQuality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).
    ///   - interFrameDelay: The delay between 2 frames. Set only when the animated image Data doesn't have a delay already.
    public func generateWith(frames: [CGImageSource], frameMaxPixelSize: CGFloat? = nil, frameCompresionQuality: CGFloat = 1, interFrameDelay: Double = GIFGenerator.s_AnimatedImageDefaultInterFrameDelay, loopCount: Int = GIFGenerator.s_AnimatedImageDefaultLoopCount)
    {
        if let animatedImageUrl = animatedImageWith(frames: frames, frameMaxPixelSize: frameMaxPixelSize, interFrameDelay: interFrameDelay, loopCount: loopCount), let animatedImageData = try? Data(contentsOf: animatedImageUrl), let animatedImage = UIImage(data: animatedImageData)
        {
            m_GeneratorCompletionHandler(animatedImage)
        }
    }
    
    /// Generates a GIF with given UIImage frames.
    /// - Parameters:
    ///   - frameMaxPixelSize: The maximum width and height in pixels of a thumbnail.
    ///   - frameCompresionQuality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).
    ///   - interFrameDelay: The delay between 2 frames. Set only when the animated image Data doesn't have a delay already.
    public func generateWith(frames: [UIImage], frameMaxPixelSize: CGFloat? = nil, frameCompresionQuality: CGFloat = 1, interFrameDelay: Double = GIFGenerator.s_AnimatedImageDefaultInterFrameDelay, loopCount: Int = GIFGenerator.s_AnimatedImageDefaultLoopCount)
    {
        if let animatedImageUrl = animatedImageWith(frames: frames, frameMaxPixelSize: frameMaxPixelSize, interFrameDelay: interFrameDelay, loopCount: loopCount), let animatedImageData = try? Data(contentsOf: animatedImageUrl), let animatedImage = UIImage(data: animatedImageData)
        {
            m_GeneratorCompletionHandler(animatedImage)
        }
    }
}

extension GIFGenerator: DownloadTaskDelegate
{
    // MARK: - DownloadTaskDelegate
    
    public func didChangeDownloadProgress(_ downloadTaskManager: DownloadTaskManager, newDownloadProgress: Double)
    {
        print("Download progress: ", newDownloadProgress)
    }
    
    public func didFinishDownload(_ downloadTaskManager: DownloadTaskManager, success: Bool)
    {
        if success
        {
            print("GIF downloaded successfully")
            
            if let fileUrl = downloadTaskManager.currentFileUrl
            {
                generateWith(url: fileUrl, frameMaxPixelSize: m_FrameMaxPixelSize, frameCompresionQuality: m_FrameCompresionQuality, interFrameDelay: m_InterFrameDelay)
            }
            else
            {
                print("Failed to generate GIF")
            }
        }
        else
        {
            print("Failed to download GIF")
        }
    }
}

private extension GIFGenerator
{
    
    /// Creates an animated image from given CGImageSource.
    /// - Parameters:
    ///   - frameMaxPixelSize: The maximum width and height in pixels of a thumbnail.
    ///   - frameCompresionQuality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).
    ///   - interFrameDelay: The delay between 2 frames. Set only when the animated image Data doesn't have a delay already.
    func animatedImageWith(imageSource: CGImageSource, frameMaxPixelSize: CGFloat? = nil, frameCompresionQuality: CGFloat = 1, interFrameDelay: Double = GIFGenerator.s_AnimatedImageDefaultInterFrameDelay) -> UIImage?
    {
        let count = CGImageSourceGetCount(imageSource)
        var delay = interFrameDelay
        
        if let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary?
        {
            if let delayTime = properties[kCGImagePropertyGIFDictionary as NSString]?[kCGImagePropertyGIFDelayTime as NSString]
            {
                if let delayTime = delayTime as? NSNumber
                {
                    delay = Double(truncating: delayTime)
                }
            }
        }
        
        var frames = [UIImage]()
        let duration = Double(count) * delay
        
        for index in 0..<count
        {
            if let cgImage = imageSource.downsample(thumbnailMaxPixelSize: frameMaxPixelSize, imageIndex: index)
            {
                var uiImage = UIImage(cgImage: cgImage)
                
                if frameCompresionQuality < 1, let compressedUIImageData = uiImage.jpegData(compressionQuality: frameCompresionQuality), let compressedUIImage = UIImage(data: compressedUIImageData)
                {
                    uiImage = compressedUIImage
                }
                
                frames.append(uiImage)
            }
        }
        
        let animatedImage = UIImage.animatedImage(with: frames, duration: duration)
        
        return animatedImage
    }
    
    /// Creates an animated image from given Data.
    /// - Parameters:
    ///   - frameMaxPixelSize: The maximum width and height in pixels of a thumbnail.
    ///   - frameCompresionQuality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).
    ///   - interFrameDelay: The delay between 2 frames. Set only when the animated image Data doesn't have a delay already.
    func animatedImageWith(data: Data, frameMaxPixelSize: CGFloat? = nil, frameCompresionQuality: CGFloat = 1, interFrameDelay: Double = GIFGenerator.s_AnimatedImageDefaultInterFrameDelay) -> UIImage?
    {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil)
        else
        {
            GIFGenerator.s_Logger.error("Failed to create image source with data '\(data.count).'")
            
            return nil
        }
        
        return animatedImageWith(imageSource: imageSource, frameMaxPixelSize: frameMaxPixelSize, frameCompresionQuality: frameCompresionQuality, interFrameDelay: interFrameDelay)
    }
    
    /// Creates the animated image by arranging the frames (CGImageSource) in order with a given delay between them.
    /// - Parameters:
    ///   - frames: The image sources for each frame of the animated image.
    ///   - frameMaxPixelSize: The maximum width and height in pixels of each thumbnail.
    ///   - interFrameDelay: The delay between 2 frames. Set only when the animated image Data doesn't have a delay already.
    ///   - loopCount: The number of times the animated image loops. Zero means infinite.
    func animatedImageWith(frames: [CGImageSource], frameMaxPixelSize: CGFloat? = nil, interFrameDelay: Double = GIFGenerator.s_AnimatedImageDefaultInterFrameDelay, loopCount: Int = GIFGenerator.s_AnimatedImageDefaultLoopCount) -> URL?
    {
        let fileProperties: CFDictionary =
            [
                kCGImagePropertyGIFDictionary as String:
                    [
                        kCGImagePropertyGIFLoopCount as String: loopCount
                    ]
            ]  as CFDictionary
        let frameProperties: CFDictionary =
            [
                kCGImagePropertyGIFDictionary as String:
                    [
                        kCGImagePropertyGIFDelayTime as String: interFrameDelay
                    ]
            ] as CFDictionary
        
        let fileURL = FileManager.createFile(contentType: .gif, directory: .cachesDirectory, domainMask: .userDomainMask)
        
        if let url = fileURL as CFURL?
        {
            if let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, frames.count, nil)
            {
                CGImageDestinationSetProperties(destination, fileProperties)
                
                for frame in frames
                {
                    CGImageDestinationAddImageFromSource(destination, frame, 0, frameProperties)
                }
                
                if !CGImageDestinationFinalize(destination)
                {
                    GIFGenerator.s_Logger.error("Failed to finalize image destination URL '\(fileURL?.absoluteString ?? "").'")
                    
                    return nil
                }
                
                return fileURL
            }
            else
            {
                GIFGenerator.s_Logger.error("Failed to create image destination with URL '\(fileURL?.absoluteString ?? "").'")
            }
        }
        
        return nil
    }
    
    /// Creates the animated image by arranging the frames (UIImage) in order with a default delay between them, looping by loopCount.
    /// - Parameters:
    ///   - frames: The frames as UIImage to construct the animated image.
    ///   - frameMaxPixelSize: The maximum width and height in pixels of each thumbnail.
    ///   - interFrameDelay: The delay between 2 frames. Set only when the animated image Data doesn't have a delay already.
    ///   - loopCount: The number of times the animated image loops. Zero means infinite.
    func animatedImageWith(frames: [UIImage], frameMaxPixelSize: CGFloat? = nil, interFrameDelay: Double = GIFGenerator.s_AnimatedImageDefaultInterFrameDelay, loopCount: Int = GIFGenerator.s_AnimatedImageDefaultLoopCount) -> URL?
    {
        var imageSources: [CGImageSource] = []
        
        for frame in frames
        {
            if let frameData = frame.jpegData(compressionQuality: 1)
            {
                if let imageSource = CGImageSourceCreateWithData(frameData as CFData, nil)
                {
                    imageSources.append(imageSource)
                }
            }
        }
        
        return animatedImageWith(frames: imageSources, frameMaxPixelSize: frameMaxPixelSize, interFrameDelay: interFrameDelay, loopCount: loopCount)
    }
}
