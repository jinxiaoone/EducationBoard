//
//  WritingMessageTransport.swift
//  WhiteBoard
//
//  Created by jinxiao on 16/7/6.
//  Copyright © 2016年 jinxiao. All rights reserved.
//

import UIKit

// 画笔事件
struct WritingBoardPenEvent {
    let location:   CGPoint
    let penSize:    CGFloat
    let penColor:   UIColor
    var pageNum:    Int
    let phase:      Int    //1.touch begin 2. move 3. end
    let timestamp:  Int64
    let sourceId:   String
}

class WritingMessageTransport: NSObject {

}
