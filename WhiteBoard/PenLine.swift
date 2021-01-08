//
//  PenLine.swift
//  WhiteBoard
//
//  Created by jinxiao on 16/7/5.
//  Copyright © 2016年 jinxiao. All rights reserved.
//

import UIKit

class PenPoint: NSObject {
    let x: CGFloat
    let y: CGFloat
    
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    convenience init(point: CGPoint) {
        self.init(x: point.x, y: point.y)
    }
}

class PenLine: NSObject {
    
    var cgcontext: CGContext?
    
    fileprivate let color: UIColor
    fileprivate let width: CGFloat
    fileprivate let blendMode: CGBlendMode
    fileprivate var pendingPoints  = [PenPoint]()
    fileprivate var commitedPoints = [PenPoint]()
    
    init(color: UIColor, width: CGFloat, blendMode: CGBlendMode) {
        self.color = color
        self.width = width
        self.blendMode = blendMode
        
        super.init()
    }
    
    func moveToPoint(_ point: PenPoint, isLast: Bool = false) {
        pendingPoints.append(point)
        
        if let ctx = cgcontext {
            drawToCanvas(ctx, isLast)
        }
    }
    
    fileprivate func drawToCanvas(_ ctx: CGContext, _ isLast: Bool) {
        drawToCanvasQuadCurve(ctx, isLast)
    }
    
    
    fileprivate func drawToCanvasStraightLine(_ ctx: CGContext, _ isLast: Bool) {
        
        ctx.setBlendMode(blendMode)
        ctx.setLineWidth(width)
        ctx.setStrokeColor(color.cgColor)
        
        var prevPoint: PenPoint!
        
        for point in pendingPoints {
            if prevPoint == nil {
                prevPoint = point
                continue
            }
            
            ctx.beginPath()
            ctx.move(to: CGPoint(x: prevPoint.x, y: prevPoint.y))
            ctx.addLine(to: CGPoint(x: point.x, y: point.y))
            
            ctx.strokePath()
            
            commitedPoints.append(prevPoint)
            prevPoint = point
        }
        
        //TODO: apple says removeAll Complexity: O(self.count).
        pendingPoints.removeAll()
        if prevPoint != nil {
            pendingPoints.append(prevPoint)
        }
    }
    
    fileprivate func drawToCanvasQuadCurve(_ ctx: CGContext, _ isLast: Bool) {
        
        if pendingPoints.count != 3 {
            return
        }
        
        ctx.setBlendMode(blendMode)
        ctx.setLineWidth(width)
        ctx.setStrokeColor(color.cgColor)
        
        let p0 = pendingPoints[0]
        let p1 = pendingPoints[1]
        let p2 = pendingPoints[2]
        
        let m1 = CGPoint(x: (p0.x + p1.x) / 2, y: (p0.y + p1.y) / 2)
        let m2 = CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
        
        ctx.beginPath()
        ctx.move(to: CGPoint(x: m1.x, y: m1.y))
        
        ctx.addQuadCurve(to:m2, control:CGPoint(x:p1.x,y:p1.y))
        ctx.strokePath()
        
        let removedPoint = pendingPoints.removeFirst()
        commitedPoints.append(removedPoint) //TODO: 最后两个点没有提交
    }
    
    fileprivate func drawToCanvasCubicCurve(_ ctx: CGContext, _ isLast: Bool) {
        let pointsCount = 5
        if pendingPoints.count != pointsCount {
            return
        }
        
        ctx.setBlendMode(blendMode)
        ctx.setLineWidth(width)
        ctx.setStrokeColor(color.cgColor)
        
        //        let p0 = pendingPoints[0]
        //        let p1 = pendingPoints[1]
//        _ = RAYBezierSpline(points: pendingPoints)
        
        
        ctx.beginPath()
        //CGContextMoveToPoint(ctx, p2.x, p2.y)
        
        ctx.strokePath()
        
        pendingPoints.removeFirst()
    }
}



