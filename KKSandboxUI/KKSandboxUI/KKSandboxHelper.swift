//
//  KKSandboxHelper.swift
//  KKSandboxUI
//
//  Created by 王铁山 on 2017/8/23.
//  Copyright © 2017年 king. All rights reserved.
//

import Foundation

import UIKit

public enum KKSandboxFileType {
    
    case text
    
    case image
    
    case array
    
    case dictionary
    
    case json
    
    case directory
    
    case unknown
    
}

open class KKSandboxHelper {
    
    /// 生成指定路径下所有的文件夹/文件模型
    ///
    /// - Parameter directory: 文件夹路径
    /// - Returns: 文件模型 KKSandboxFileModel
    open class func fileModelAtPath(directory: String) -> [KKSandboxFileModel] {
        
        let manager = FileManager.default
        
        var isDirectory: ObjCBool = false
        
        if !manager.fileExists(atPath: directory, isDirectory: &isDirectory) && !isDirectory.boolValue {
            return [KKSandboxFileModel]()
        }
        
        guard let subPaths = try? manager.contentsOfDirectory(atPath: directory) else {
            return [KKSandboxFileModel]()
        }
        
        var result = [KKSandboxFileModel]()
        
        for subPath in subPaths {
            
            let fullPath = "\(directory)/\(subPath)"
            
            result.append(self.getFileModel(name: subPath, path: fullPath))
        }
        
        return result
    }
    
    /// 转换文件为模型
    open class func getFileModel(name subPath: String, path fullPath: String) -> KKSandboxFileModel {
        
        let manager = FileManager.default
        
        let model = KKSandboxFileModel.init(name: subPath, path: fullPath)
        
        model.isDeleteable = manager.isDeletableFile(atPath: fullPath)
        
        model.fileType = self.getFileType(path: fullPath)
        
        do {
            let att = try manager.attributesOfItem(atPath: subPath)
            model.fileSize = (att[FileAttributeKey.size] as? String) ?? ""
        } catch _ {
            
        }
        
        return model
    }
    
    /// 获取文件类型
    open class func getFileType(path: String) -> KKSandboxFileType {
        
        let manager = FileManager.default
        
        var isDirectory: ObjCBool = false
        
        _ = manager.fileExists(atPath: path, isDirectory: &isDirectory)
        
        // 判断是否是文件夹
        if isDirectory.boolValue {
            return .directory
        }
        
        // image
        if let _ = UIImage.init(contentsOfFile: path) {
            return .image
        }
        
        // object
        if let _ = NSDictionary.init(contentsOfFile: path) {
            return .dictionary
        }
        
        // array
        if let _ = NSArray.init(contentsOfFile: path) {
            return .array
        }
        
        // 字符串
        if let text = try? String.init(contentsOfFile: path), let textData: Data = text.data(using: String.Encoding.utf8) {
            
            let jsonObj: Any? = try? JSONSerialization.jsonObject(with: textData, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            if let _: [String: Any] = jsonObj as? [String: Any] {
                return .json
            } else {
                return .text
            }
        }
        
        return .unknown
    }
    
    /// 获取国际化字符串
    open class func getLocalizedString(name: String) -> String {
        let mainFind = NSLocalizedString(name, tableName: "KKSandboxUI", comment: name)
        if mainFind.isEmpty {
            return NSLocalizedString(name, tableName: "KKSandboxUI", bundle: Bundle.init(for: KKSandboxUIViewController.self), value: "", comment: name)
        }
        return mainFind
    }
}

/// 文件模型
open class KKSandboxFileModel {
    
    static var directoryIcon: UIImage?
    
    static var textIcon: UIImage?
    
    static var unknownIcon: UIImage?
    
    open var name: String
    
    open var path: String
    
    open var fileType: KKSandboxFileType = .unknown
    
    open var fileSize: String?
    
    open var isDeleteable: Bool = true
    
    var iconImage: UIImage?
    
    public init(name: String, path: String) {
        self.name = name
        self.path = path
    }
    
    open func getIconImage() -> UIImage? {
        if let icon = self.iconImage {
            return icon
        }
        switch self.fileType {
        case .directory:
            if KKSandboxFileModel.directoryIcon == nil {
                KKSandboxFileModel.directoryIcon = getThumbImage(originImage: image(named: "DirectoryIcon.png"))
            }
            self.iconImage = KKSandboxFileModel.directoryIcon
            return self.iconImage
        case .array, .dictionary, .json, .text:
            if KKSandboxFileModel.textIcon == nil {
                KKSandboxFileModel.textIcon = getThumbImage(originImage: image(named: "TextIcon.png"))
            }
            self.iconImage = KKSandboxFileModel.textIcon
            return self.iconImage
        case .image:
            self.iconImage =  self.getThumbImage(originImage: UIImage.init(contentsOfFile: self.path))
            return self.iconImage
        default:
            if KKSandboxFileModel.unknownIcon == nil {
                KKSandboxFileModel.unknownIcon = getThumbImage(originImage: image(named: "UnknowIcon.png"))
            }
            self.iconImage = KKSandboxFileModel.unknownIcon
            return self.iconImage
        }
    }
    
    private func getThumbImage(originImage: UIImage?)->UIImage? {
        guard let image: UIImage = originImage else {
            return originImage
        }
        let size = CGSize(width: 29, height: 29)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        image.draw(in: CGRect.init(origin: CGPoint(), size: size))
        let thumbImage: UIImage? =  UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbImage
    }
}

fileprivate func sourcePath(name: String) -> String? {
    let named = "KKSandboxUI.bundle/\(name)"
    if let path = Bundle.main.path(forResource: named, ofType: nil) {
        return path
    }
    if let path = Bundle.init(for: KKSandboxFileModel.self).path(forResource: named, ofType: nil) {
        return path
    }
    let fullNamed = "Frameworks/KKSandboxUI.framework/\(named)"
    if let path = Bundle.main.path(forResource: fullNamed, ofType: nil) {
        return path
    }
    return nil
}

fileprivate func image(named: String) -> UIImage? {
    if let path = sourcePath(name: named) {
        return UIImage(contentsOfFile: path)
    }
    return nil
}
