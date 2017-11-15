//
//  WritingBoardViewController.swift
//  WhiteBoard
//
//  Created by jinxiao on 16/6/30.
//  Copyright © 2016年 jinxiao. All rights reserved.
//

import UIKit
import AVFoundation

class WritingBoardColor {
    /*
     通过此方式创建的blackColor != UIColor.blackColor
     */
    static let blackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let redColor = UIColor.red
    static let blueColor = UIColor.blue
    static let whiteColor = UIColor.white
}



class WritingBoardViewController: UIViewController {
    
    var canvasDrawable = true
    
    @IBOutlet weak var canvasView: WritingBoardCanvasView!
    
    var pages = [WritintBoardCanvasPage]()
    
    var pageIndex = -1 { //current page index
        didSet {
        }
    }
    var currentPage: WritintBoardCanvasPage {
        return pages[pageIndex]
    }
    
    
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        NSLog("白板界面didload")
        
        
    }
    
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("白板界面即将出现")
        UIApplication.shared.setStatusBarHidden(true, with: .none)
        
    }
    
    var firstTimeAppear = true
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("白板界面已经出现")
//        if firstTimeAppear {
//            firstTimeAppear = false
//            insertPage(afterIndex: pageIndex)
//        }
        
    }
    
    var toolsetVC: WritingBoardToolSetViewController?
    
    //left toolbar
    @IBOutlet weak var toolsetButton: UIButton!
    @IBAction func presentToolSet(_ sender: UIButton) {
        
        toolsetVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RAYToolSetVCID") as? WritingBoardToolSetViewController
        toolsetVC!.delegate = self
        addChildViewController(toolsetVC!)
        
        var childFrame = view.bounds
        childFrame.size.width = view.bounds.width / 2 - 100.0
        toolsetVC?.view.frame = childFrame
        view.addSubview(toolsetVC!.view)
        toolsetVC!.didMove(toParentViewController: self)
    }
    
    func usePen(_ width: CGFloat, color: UIColor) {
        assert(width > 0)
        canvasView.penWidth  = width
        canvasView.penColor  = color
    }
    
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var recorderConsole: UIView!
    @IBOutlet weak var finishLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    fileprivate let recordFPS = 6
    fileprivate var recordFrames = 0
    fileprivate var recordTimer: Timer?
    
    var isStart: Bool = false
    
    //begin action
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        isStart = true
        changeRecordButtonToTimer()
        uploadButton.setImage(UIImage(named: "WBRecordFinish"), for: UIControlState())
        recordTimer = fireTimer()
    }
    
    fileprivate func changeRecordButtonToTimer() {
        recordButton.isEnabled = false
        recordButton.setImage(UIImage(named: "WBClock"), for: UIControlState())
        timerLabel.text = ""
        timerLabel.textColor = UIColor.red
    }
    
    func fireTimer() -> Timer {
        
        timerLabel.text = "00:00"
        recordFrames  = 0
        let timer = Timer.scheduledTimer(timeInterval: 1.0 / Double(recordFPS),
                                                           target: self, selector: #selector(WritingBoardViewController.timerCallback(_:)), userInfo: nil, repeats: true)
        NSLog("schedule timer %@", timer)
        return timer
        
    }
    
    func timerCallback(_ timer: Timer) {
        
        recordFrames += 1
        if recordFrames % recordFPS == 0 {
            updateTimerLabel(recordFrames / recordFPS)
        }
    }
    
    fileprivate func updateTimerLabel(_ duration: Int) {
        var second = "\(duration % 60)"
        if second.characters.count == 1 {
            second = "0" + second
        }
        
        var minute = "\(duration / 60)"
        if minute.characters.count == 1 {
            minute = "0" + minute
        }
        
        let timerString = "\(minute):\(second)"
        timerLabel.text = timerString
        
    }
    
    //end action
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: isStart ? "提醒" : "未开始就要退出吗？", message: nil, preferredStyle: .alert)
        
        let notInClassroom = isStart
        if notInClassroom {
            alertController.addAction(
                UIAlertAction(title: "回看", style: .default)
                { (_: UIAlertAction) -> Void in
            })
            
            alertController.addAction(
                UIAlertAction(title: "重新录制", style: .default)
                { (_: UIAlertAction) -> Void in
            })
            
            alertController.addAction(
                UIAlertAction(title: "退出", style: .destructive)
                { (_: UIAlertAction) -> Void in
                    self.dismiss(animated: false, completion: nil)
            })
            
            alertController.addAction(
                UIAlertAction(title: "取消", style: .cancel)
                { (_: UIAlertAction) -> Void in
            })
        } else {
            
            alertController.addAction(
                UIAlertAction(title: "退出", style: .destructive)
                { (_: UIAlertAction) -> Void in
                    self.dismiss(animated: false, completion: nil)
            })
            
            alertController.addAction(
                UIAlertAction(title: "取消", style: .cancel) { (_: UIAlertAction) -> Void in
                    
            })
        }
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    fileprivate var isAllowHand = true
    fileprivate var blockDrawTouch: Bool {
        return canvasDrawable && isAllowHand
    }
    
    
    // MAKE: Touch Handing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard blockDrawTouch else {
            return
        }
        NSLog("wbvc touches begin")
        canvasView.beginTouches(touches, withEvent: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard blockDrawTouch else {
            return
        }
        
        canvasView.drawTouches(touches, withEvent: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard blockDrawTouch else {
            return
        }
        canvasView.drawTouches(touches, withEvent: event)
        canvasView.endTouches(touches, cancel: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard blockDrawTouch else {
            return
        }
        
        canvasView.endTouches(touches, cancel: true)
    }
    
    
    
    /**
     * @return 是否增加了Page
     */
    func gotoNextPage(sendToPeer: Bool) -> Bool {
        
        var addedNewPage = false
        if pageIndex == pages.count - 1 {
            addedNewPage = true
            pages.append(WritintBoardCanvasPage())
        } else if (pageIndex >= pages.count) {
            return false
        }
        
        let pageTogo = pageIndex + 1
        gotoPage(pageTogo)
        return addedNewPage
    }
    
    func gotoPage(_ index: Int) {
        
        assert(index >= 0 && index < pages.count)
        pageIndex = index
        
        let page = pages[index]
        canvasView.loadPage(page)
        
        if let _ = page.pptImageURL , !page.pptImageWasDrawn {
            
            if page.pptImage != nil {
                page.paintPPTImage(self.canvasView)
            } else {
                
                }
            }
        }
    
    
    fileprivate func insertPage(afterIndex index: Int) {
        let newPage = WritintBoardCanvasPage()
        pages.insert(newPage, at: index + 1)
        NSLog("after add a page, have %d pages", pages.count)
        let _ = gotoNextPage(sendToPeer: false)
        
        
        
    }
    
    
    
}


extension WritingBoardViewController: WritingBoardToolSetViewControllerProtocol {
    
    
    func penChanged(_ width: CGFloat, color: UIColor) {
        usePen(width, color: color)
    }
    
    func eraserChanged(_ width: CGFloat) {
        
    }
    
    
    //Delegate as Hidden ToolView
    func toolsetViewControllerRetired(_ controller: WritingBoardToolSetViewController) {
        
        toolsetVC?.willMove(toParentViewController: nil)
        toolsetVC?.view.removeFromSuperview()
        toolsetVC?.removeFromParentViewController()
        toolsetVC = nil
        
    }
    
    func newMethod() {
        
    }
}


