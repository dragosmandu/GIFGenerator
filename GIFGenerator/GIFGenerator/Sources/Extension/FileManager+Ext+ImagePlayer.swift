//
//
//  Workspace: GIFGenerator
//  MacOS Version: 11.4
//			
//  File Name: FileManager+Ext+ImagePlayer.swift
//  Creation: 5/31/21 8:18 PM
//
//  Author: Dragos-Costin Mandu
//
//


import Foundation
import UniformTypeIdentifiers
import os
import DownloadTaskManager

public extension FileManager
{
    // MARK: - Constants & Variables
    
    /// The prefix to be used in the file creation/search methods.
    static var s_FileNamePrefix: String = Bundle.main.bundleIdentifier! + "-"
    
    static var s_LoggerCategory: String = "FileManager"
    static let s_Logger: Logger = .init(subsystem: loggerSubsystem, category: FileManager.s_LoggerCategory)
}

public extension FileManager
{
    // MARK: - Methods
    
    /// Creates a file with given file name, in directory. If the file name isn't provided, it will create a file name.
    /// - Parameters:
    ///   - fileName: The name of the file to be created.
    ///   - contentType: The content type of the file.
    ///   - data: The data that the file may contain when it's created.
    ///   - directory: The directory in which the file is located.
    ///   - domainMask: Domain constants specifying base locations to use when you search for significant directories.
    ///   - attributes: A dictionary containing the attributes to associate with the new file. You can use these attributes to set the owner and group numbers, file permissions, and modification date. For a list of keys, see FileAttributeKey. If you specify nil for attributes, the file is created with a set of default attributes.
    /// - Returns: An URL that points to the newly created file.
    static func createFile(fileName: String? = nil, contentType: UTType? = nil, data: Data? = nil, directory: FileManager.SearchPathDirectory = .cachesDirectory, domainMask: FileManager.SearchPathDomainMask = .userDomainMask, attributes: [FileAttributeKey : Any]? = nil) -> URL?
    {
        if let fileUrl = createFileUrl(fileName: fileName, contentType: contentType, directory: directory, domainMask: domainMask)
        {
            if !FileManager.default.fileExists(atPath: fileUrl.path)
            {
                if FileManager.default.createFile(atPath: fileUrl.path, contents: data, attributes: attributes)
                {
                    return fileUrl
                }
                
                s_Logger.error("Failed to create file with \(data ?? Data()).")
            }
            else
            {
                s_Logger.debug("File with name '\(fileName ?? "")' already exists.")
            }
        }
        
        return nil
    }
}
