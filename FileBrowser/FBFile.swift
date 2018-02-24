//
//  FBFile.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 14/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

/// FBFile is a class representing a file in FileBrowser
@objc open class FBFile: NSObject, NSCoding {
    struct PropertyKey {
        //static let displayName = "displayName"
        //static let isDirectory = "isDirectory"
        //static let fileExtension = "fileExtension"
        //static let fileAttributes = "fileAttributes"
        static let filePath = "filePath"
        //static let type = "type"
    }
    
    /// Display name. String.
    @objc open let displayName: String
    // is Directory. Bool.
    open let isDirectory: Bool
    /// File extension.
    open let fileExtension: String?
    /// File attributes (including size, creation date etc).
    open let fileAttributes: NSDictionary?
    /// NSURL file path.
    open let filePath: URL
    // FBFileType
    open let type: FBFileType
    
    //Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("FBFile_data")
    
    open func delete()
    {
        do
        {
            try FileManager.default.removeItem(at: self.filePath)
        }
        catch
        {
            print("An error occured when trying to delete file:\(self.filePath) Error:\(error)")
        }
    }
    
    /**
     Initialize an FBFile object with a filePath
     
     - parameter filePath: NSURL filePath
     
     - returns: FBFile object.
     */
    init(filePath: URL) {
        self.filePath = filePath
        let isDirectory = checkDirectory(filePath)
        self.isDirectory = isDirectory
        if self.isDirectory {
            self.fileAttributes = nil
            self.fileExtension = nil
            self.type = .Directory
        }
        else {
            self.fileAttributes = getFileAttributes(self.filePath)
            self.fileExtension = filePath.pathExtension
            if let fileExtension = fileExtension {
                self.type = FBFileType(rawValue: fileExtension) ?? .Default
            }
            else {
                self.type = .Default
            }
        }
        self.displayName = filePath.lastPathComponent 
    }
    
    public func encode(with aCoder: NSCoder) {
        //aCoder.encode(displayName, forKey: PropertyKey.displayName)
        //aCoder.encode(isDirectory, forKey: PropertyKey.isDirectory)
        //aCoder.encode(fileExtension, forKey: PropertyKey.fileExtension)
        //aCoder.encode(fileAttributes, forKey: PropertyKey.fileAttributes)
        aCoder.encode(filePath, forKey: PropertyKey.filePath)
        //aCoder.encode(type, forKey: PropertyKey.type)
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        guard let filePath = aDecoder.decodeObject(forKey: PropertyKey.filePath) as? URL else {
            return nil
        }
        
        self.init(filePath: filePath)
    }
}

/**
 FBFile type
 */
public enum FBFileType: String {
    /// Directory
    case Directory = "directory"
    /// GIF file
    case GIF = "gif"
    /// JPG file
    case JPG = "jpg"
    /// PLIST file
    case JSON = "json"
    /// PDF file
    case PDF = "pdf"
    /// PLIST file
    case PLIST = "plist"
    /// PNG file
    case PNG = "png"
    /// ZIP file
    case ZIP = "zip"
    /// Any file
    case Default = "file"
    
    /**
     Get representative image for file type
     
     - returns: UIImage for file type
     */
    public func image() -> UIImage? {
        let bundle =  Bundle(for: FileParser.self)
        var fileName = String()
        switch self {
        case .Directory: fileName = "folder@2x.png"
        case .JPG, .PNG, .GIF: fileName = "image@2x.png"
        case .PDF: fileName = "pdf@2x.png"
        case .ZIP: fileName = "zip@2x.png"
        default: fileName = "file@2x.png"
        }
        let file = UIImage(named: fileName, in: bundle, compatibleWith: nil)
        return file
    }
}

/**
 Check if file path NSURL is directory or file.
 
 - parameter filePath: NSURL file path.
 
 - returns: isDirectory Bool.
 */
func checkDirectory(_ filePath: URL) -> Bool {
    var isDirectory = false
    do {
        var resourceValue: AnyObject?
        try (filePath as NSURL).getResourceValue(&resourceValue, forKey: URLResourceKey.isDirectoryKey)
        if let number = resourceValue as? NSNumber , number == true {
            isDirectory = true
        }
    }
    catch { }
    return isDirectory
}

func getFileAttributes(_ filePath: URL) -> NSDictionary? {
    let path = filePath.path
    let fileManager = FileParser.sharedInstance.fileManager
    do {
        let attributes = try fileManager.attributesOfItem(atPath: path) as NSDictionary
        return attributes
    } catch {}
    return nil
}
