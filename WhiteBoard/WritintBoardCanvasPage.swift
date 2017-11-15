//
//  WritintBoardCanvasPage.swift
//  WhiteBoard
//
//  Created by jinxiao on 16/10/20.
//  Copyright © 2016年 jinxiao. All rights reserved.
//
import UIKit
import Foundation

class WritintBoardCanvasPage {
    
    var studentsImages = [[String:AnyObject]]()
    var teachersImages = [[String:AnyObject]]()
    
    static var s_pageCacheDirectory: URL?
    static func pageCacheDirectory() -> URL {
        if s_pageCacheDirectory == nil {
            s_pageCacheDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("WBPageCache")
        }
        
        return s_pageCacheDirectory!
    }
    
    static func preparePageDiskCache() {
        cleanPageDiskCache()
        
        let dirExists = FileManager.default.fileExists(atPath: pageCacheDirectory().path)
        if !dirExists {
            do {
                try FileManager.default.createDirectory(
                    at: pageCacheDirectory(),
                    withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("create directory error \(error)")
            }
        }
        
    }
    
    static func cleanPageDiskCache() {
        let cacheDirectory = pageCacheDirectory()
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            return
        }
        
        do {
            let pngs = try FileManager.default.contentsOfDirectory(atPath: cacheDirectory.path)
            for cachedPng in pngs {
                let fullpath = cacheDirectory.appendingPathComponent(cachedPng)
                try FileManager.default.removeItem(atPath: fullpath.path)
            }
        } catch let error {
            print("remove file error \(error)")
        }
    }
    
    
    var commitedLines = [PenLine]()
    var restoreImage: CGImage? {
        get {
            NSLog("begin restore image")
            
            let png = UIImage(contentsOfFile: cacheUrl().path)
            print("end restore image \(String(describing: png))")
            return png?.cgImage
            
        }
        
        set {
            if let cgimage = newValue {
                NSLog("begin cache image")
                let image = UIImage(cgImage: cgimage)
                let pngData = UIImagePNGRepresentation(image)
                try? pngData?.write(to: cacheUrl(), options: [])
                print("png data size \(String(describing: pngData?.count))")
            }
        }
        
    }
    
    
    var pptImageAddress: String?
    var pptImage: UIImage?
    
    var pptImageURL: URL? {
        if let urlstr = pptImageAddress {
            return URL(string: urlstr)
        }
        
        return nil
    }
    
    var pptImageWasDrawn = false
    
    func paintPPTImage(_ canvasView: WritingBoardCanvasView) {
        pptImageWasDrawn = true
        
        //TODO: 图片的高度有可能不等于canvasView的高度
//        let canvasSize = canvasView.frame.size
//        let imageWidth = canvasSize.width * 3/4
//        let imageHeight = canvasSize.height * 3/4
//        let imagePosX = canvasSize.width / 2 - imageWidth / 2
//        let imagePosY = canvasSize.height / 2 - imageHeight / 2
//        let moveableImage = MovableImage(image: pptImage, frame:
//            CGRect(x: imagePosX, y: imagePosY, width: imageWidth, height: imageHeight))
//        canvasView.paintImage(moveableImage)
        
        pptImage = nil //ppt图片被绘制后就不会被再次用到，所以释放。
    }
    
//    func paintIMGImage(_ canvasView: WritingBoardCanvasView,frame:CGRect,image:UIImage) {
//        let moveableImage = MovableImage(image: image, frame:frame)
//        canvasView.paintImage(moveableImage)
//    }
    
    
    fileprivate lazy var cacheName: String = {
        let address = Unmanaged.passUnretained(self).toOpaque().hashValue
        let date = Int(Date().timeIntervalSince1970)
        return "\(address)_\(date)"
    } ()
    
    fileprivate func cacheUrl() -> URL {
        return WritintBoardCanvasPage.pageCacheDirectory().appendingPathComponent(cacheName)
    }
}
