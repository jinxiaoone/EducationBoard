//
//  WritingBoardCanvasView.swift
//  WhiteBoard
//
//  Created by jinxiao on 16/7/1.
//  Copyright © 2016年 jinxiao. All rights reserved.
//

import UIKit
import CoreGraphics

protocol WritingBoardCanvasViewDelegate: class {
    /*
     * @param width height in pixels
     */
    func imageCaptured(_ image: CGImage, width: Int32, height: Int32);
    
    func sendPenEvent(_ event: WritingBoardPenEvent);
}

class WritingBoardCanvasView: UIView {
    
    var canvasColor = QWritingBoardColor.whiteColor
    var penColor = QWritingBoardColor.whiteColor
    var penWidth: CGFloat = 2.0
    let blendMode = CGBlendMode.normal
    var lastCaptureTime = Date()
    var capturing = false
    weak var delegate: WritingBoardCanvasViewDelegate?
    
    fileprivate let captureInterval = -1.0 / 10 //每秒10帧
    fileprivate var activeLine:  PenLine
    fileprivate var peersLine = [String: PenLine]()
    fileprivate var page = WritintBoardCanvasPage()
    
    fileprivate func findLineBySourceId(_ sourceId: String, orCreateBy penEvent: WritingBoardPenEvent) -> PenLine {
        var line = peersLine[sourceId]
        
        if line == nil {
            line = PenLine(color: penEvent.penColor, width: penEvent.penSize, blendMode: .normal)
            line?.cgcontext = frozenContext
            
            peersLine[sourceId] = line
        }
        
        return line!
    }
    
    fileprivate func removeLineBySourceId(_ sourceId: String) {
        peersLine[sourceId] = nil
    }
    
    //一些初始化函数执行之后才能确定的属性，用lazy
    //[[lazy begin]]
    lazy var pixelWidth: Int32 = {
        return Int32(self.bounds.size.width * self.window!.screen.scale)
    }()
    
    lazy var pixelHeight: Int32 = {
        return Int32(self.bounds.size.height * self.window!.screen.scale)
    }()
    
    fileprivate lazy var frozenContext: CGContext = {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

        let context = CGContext(data: nil, width: Int(self.pixelWidth), height: Int(self.pixelHeight), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo)
        
        context?.setLineCap(.round)
        let scale = self.window!.screen.scale
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        context?.concatenate(transform)
        return context!
    }()
    //[[lazy end]]
    
    required init?(coder aDecoder: NSCoder) {
        activeLine  = PenLine(color: penColor, width: penWidth, blendMode: blendMode)
        super.init(coder: aDecoder)
        
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        context.setLineCap(.round)
        
        let frozenImage = frozenContext.makeImage()
        
        if let frozenImage = frozenImage {
            context.draw(frozenImage, in: bounds)
        }
        
    }
    
    func beginTouches(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            let penEvent = WritingBoardPenEvent(
                location: location,
                penSize:  penWidth,
                penColor: penColor,
                pageNum: 0,
                phase: 1,
                timestamp: Int64(Date().timeIntervalSince1970),
                sourceId:  ""
            )
            
            delegate?.sendPenEvent(penEvent)

            //print("begin location \(location.x) \(location.y)")
            activeLine = PenLine(color: penColor, width: penWidth, blendMode: blendMode)
            activeLine.cgcontext = frozenContext
            activeLine.moveToPoint(PenPoint(point:location))
            setNeedsDisplay()
        }
    }

    func drawTouches(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            let penEvent = WritingBoardPenEvent(
                location: location,
                penSize:  penWidth,
                penColor: penColor,
                pageNum: 0,
                phase: 2,
                timestamp: Int64(Date().timeIntervalSince1970),
                sourceId:  ""
            )
            
            delegate?.sendPenEvent(penEvent)
            activeLine.moveToPoint(PenPoint(point:location))
            setNeedsDisplay()
        }
    }
    
    func endTouches(_ touches: Set<UITouch>, cancel: Bool) {
        if let location = touches.first?.location(in: self) {
            
            let penEvent = WritingBoardPenEvent(
                location: location,
                penSize:  penWidth,
                penColor: penColor,
                pageNum: 0,
                phase: 3,
                timestamp: Int64(Date().timeIntervalSince1970),
                sourceId:  ""
            )
            
            delegate?.sendPenEvent(penEvent)
            
            activeLine.moveToPoint(PenPoint(point:location), isLast:true)
            setNeedsDisplay()
        }
    }
    
    func beginNetworkTouches(_ penEvent: WritingBoardPenEvent) {
        //print("beginTuches")
        removeLineBySourceId(penEvent.sourceId)
        let networkLine = findLineBySourceId(penEvent.sourceId, orCreateBy: penEvent)
        networkLine.moveToPoint(PenPoint(point: penEvent.location))
        setNeedsDisplay()
    }
    
    func drawNetworkTouches(_ penEvent: WritingBoardPenEvent) {
        //print("drawtouches")
        let networkLine = findLineBySourceId(penEvent.sourceId, orCreateBy: penEvent)
        networkLine.moveToPoint(PenPoint(point: penEvent.location))
        setNeedsDisplay()
    }
    
    func endNetworkTouches(_ penEvent: WritingBoardPenEvent) {
        //print("endtouches")
        let networkLine = findLineBySourceId(penEvent.sourceId, orCreateBy: penEvent)
        networkLine.moveToPoint(PenPoint(point: penEvent.location), isLast:true)
        removeLineBySourceId(penEvent.sourceId)
        setNeedsDisplay()
    }
    
    func requestCaptureImage() {
        captureFrozenImage()
    }
    
    
    fileprivate func captureFrozenImage() {
        if !capturing || lastCaptureTime.timeIntervalSinceNow > captureInterval {
            return
        }

        lastCaptureTime = Date()
     
        let imageNoLogo = frozenContext.makeImage()
        if imageNoLogo != nil {
            delegate?.imageCaptured(imageNoLogo!,
                                    width: pixelWidth,
                                    height: pixelHeight)
        }
    }
    
    
    // 加载当前画布
    func loadPage(_ pageToLoad: WritintBoardCanvasPage) {
        page.restoreImage = frozenContext.makeImage()
        if let imageToRestore = pageToLoad.restoreImage {
            frozenContext.draw(imageToRestore, in: bounds)
        } else {
            underPaintCanvas()
        }
        setNeedsDisplay()
        
        page = pageToLoad
    }
    
    
    /*
     * @brief 为画布刷底色
     */
    func underPaintCanvas() {
        //CGContextClearRect(frozenContext, bounds)
        frozenContext.setAlpha(1) //不透明
        frozenContext.setFillColor(canvasColor.cgColor)
        frozenContext.fill(bounds)
        frozenContext.setFillColor(penColor.cgColor)
    }
    
}
