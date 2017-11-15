//
//  MyViewModel.swift
//  WhiteBoard
//
//  Created by jinxiao on 16/7/7.
//  Copyright © 2016年 jinxiao. All rights reserved.
//

import UIKit

class MyViewModel: NSObject {
    
    var penColor: UIColor?
    var penWidth: CGFloat?
    var path: UIBezierPath!
    
    func viewModelWithColor(_ penColor: UIColor, penWidth: CGFloat, path: UIBezierPath) {
        self.penColor = penColor
        self.penWidth = penWidth
        self.path = path
    }
    
}
