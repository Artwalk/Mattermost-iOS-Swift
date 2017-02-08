//
//  FileUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 31/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import SOCKit
import RestKit

private protocol Interface {
    static func fileIsImage(_ file: File) -> Bool
    static func downloadLinkForFile(_ file: File) -> URL?
    static func thumbLinkForFile(_ file: File) -> URL?
    static func previewLinkForFile(_ file: File) -> URL?
   // static func thumbPostfixForInternalFile(_ file: File) -> String?
    static func removeLocalCopyOf(file: File)
    static func scaledImageHeightWith(file: File) -> CGFloat
    static func scaledImageSizeWith(file: File) -> CGSize
}

final class FileUtils {
    static func downloadLinkForFile(_ file: File) -> URL?{
        let path = SOCStringFromStringWithObject(FilePathPatternsContainer.downloadPathPattern(), file)
        let result = Api.sharedInstance.baseURL().appendingPathComponent(path!.removingPercentEncoding!)
        
        return result
    }
    static func thumbLinkForFile(_ file: File) -> URL? {
        guard file.isImage else { return downloadLinkForFile(file) }
        
        let path = SOCStringFromStringWithObject(FilePathPatternsContainer.thumbPathPattern(), file)
        let result = Api.sharedInstance.baseURL().appendingPathComponent(path!.removingPercentEncoding!)
        
        return result
    }
    static func previewLinkForFile(_ file: File) -> URL? {
        guard file.hasPreview else { return downloadLinkForFile(file) }
        
        let path = SOCStringFromStringWithObject(FilePathPatternsContainer.previewPathPattern(), file)
        let result = Api.sharedInstance.baseURL().appendingPathComponent(path!.removingPercentEncoding!)
        
        return result
    }
    
    /*  static func thumbPostfixForInternalFile(_ file: File) -> String? {
        return (self.linkWithoutExtension(file.rawLink))! + "_thumb"
    }*/

    static func localLinkFor(file: File) -> String {
        /*  let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let fileName = "/" + (file.downloadURL()?.lastPathComponent)!
        return paths[0].appending(fileName)*/
        
       // let fileId = notification.userInfo?["fileId"]
       // let file = RealmUtils.realmForCurrentThread().object(ofType: File.self, forPrimaryKey: fileId)
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + (file.name)!
        
        return filePath
    }
    
    fileprivate static func linkWithoutExtension(_ link: String?) -> String? {
        return URL(string: link ?? StringUtils.emptyString())?.deletingPathExtension().absoluteString
    }
    
    static func fileIsImage(_ file: File) -> Bool {
        return self.stringContainsImagePrefix(file.mimeType)
    }
    
    static func stringContainsImagePrefix(_ string: String?) -> Bool {
        return string?.hasPrefix("image") ?? false
        
    }

    
    static func fileNameFromUrl(url:URL) -> String {
        let rawLink = url.absoluteString
        let components = rawLink.components(separatedBy: "/")
        return (components.count >= 2) ? components.last!.removingPercentEncoding! : rawLink
    }
    
    static func removeLocalCopyOf(file: File) {
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + (file.name)!
        
        if FileManager.default.fileExists(atPath: filePath) {
           try! FileManager.default.removeItem(atPath: filePath)
        }
    }
    
 
    
    static func scaledImageSizeWith(file: File) -> CGSize {
        let maxWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
        let maxHeight = UIScreen.screenHeight() * 0.6
        let xScaleFactor = maxWidth / CGFloat(file.width)
        let yScaleFactor = maxHeight / CGFloat(file.height)
        let scaleFactor = min(xScaleFactor, yScaleFactor)
        
        return CGSize(width: CGFloat(file.width) * scaleFactor, height: min(CGFloat(file.height) * scaleFactor, UIScreen.screenHeight() * 0.6))
    }
    
    static func scaledImageHeightWith(file: File) -> CGFloat {
        return scaledImageSizeWith(file: file).height
    }
}
