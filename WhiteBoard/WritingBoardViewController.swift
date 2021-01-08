//
//  WritingBoardViewController.swift
//  WhiteBoard
//
//  Created by jinxiao on 16/6/30.
//  Copyright © 2016年 jinxiao. All rights reserved.
//

import UIKit
import AVFoundation


class WritingBoardViewController: UIViewController {
    
    var canvasDrawable = true
    
    @IBOutlet weak var canvasView: WritingBoardCanvasView!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var recorderConsole: UIView!
    @IBOutlet weak var finishLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    fileprivate let recordFPS = 6
    fileprivate var recordFrames = 0
    fileprivate var recordTimer: Timer?
    
    var isStart: Bool = false
    
    
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var pageIndicator: UILabel!
    
    var pages = [WritintBoardCanvasPage]()
    
    var pageIndex = -1 { //current page index
        didSet {
            pageIndicator.text = "\(pageIndex + 1)/\(pages.count)"
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
        
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    var firstTimeAppear = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("白板界面已经出现")
        
    }
    
    var toolsetVC: WritingBoardToolSetViewController?
    
    //left toolbar
    @IBOutlet weak var toolsetButton: UIButton!
    @IBAction func presentToolSet(_ sender: UIButton) {
        
        toolsetVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RAYToolSetVCID") as? WritingBoardToolSetViewController
        toolsetVC!.delegate = self
        addChild(toolsetVC!)
        
        var childFrame = view.bounds
        childFrame.size.width = view.bounds.width / 2 - 100.0
        toolsetVC?.view.frame = childFrame
        view.addSubview(toolsetVC!.view)
        toolsetVC!.didMove(toParent: self)
    }
    
    func usePen(_ width: CGFloat, color: UIColor) {
        assert(width > 0)
        canvasView.penWidth = width
        canvasView.penColor = color
    }
    
    func useEraser(width: CGFloat) {
        assert(width > 0)
        canvasView.penWidth = width
        canvasView.penColor = canvasView.canvasColor
    }
    
    
    //上一页
    @IBAction func prevPageButtonTapped(_ sender: UIButton) {
        gotoPreviousPage(sendToPeer: true)
    }
    
    private func gotoPreviousPage(sendToPeer: Bool) {
        guard pageIndex > 0 else {
            print("already at first page. page index is %d", pageIndex)
            return
        }
        
        let pageTogo = pageIndex - 1
//        if sendToPeer {
//            messageTransport?.sendGotoPageEvent(pageTogo)
//        }
        gotoPage(pageTogo)

        print("go to page %d(0..%d) ", pageIndex, pages.count - 1)
    }
    
    
    //下一页
    @IBAction func nextPageTapped(_ sender: UIButton) {
        let _ = gotoNextPage(sendToPeer: true)
        
//        if let movableImage = questionPicture where addNewPage {
//            canvasView.paintImage(movableImage)
//        }
    }
    
    
    /**
     * @return 是否增加了Page
     */
    @discardableResult
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
        print("after add a page, have %d pages", pages.count)
        gotoNextPage(sendToPeer: false)
        
    }
    
    //开始录制
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        isStart = true
        changeRecordButtonToTimer()
        uploadButton.setImage(UIImage(named: "WBRecordFinish"), for: .normal)
        recordTimer = fireTimer()
    }
    
    fileprivate func changeRecordButtonToTimer() {
        recordButton.isEnabled = false
        recordButton.setImage(UIImage(named: "WBClock"), for: .normal)
        timerLabel.text = ""
        timerLabel.textColor = UIColor.red
    }
    
    func fireTimer() -> Timer {
        
        timerLabel.text = "00:00"
        recordFrames  = 0
        let timer = Timer.scheduledTimer(timeInterval: 1.0 / Double(recordFPS),
                                                           target: self, selector: #selector(WritingBoardViewController.timerCallback(_:)), userInfo: nil, repeats: true)
        print("schedule timer %@", timer)
        return timer
        
    }
    
    @objc func timerCallback(_ timer: Timer) {
        
        recordFrames += 1
        if recordFrames % recordFPS == 0 {
            updateTimerLabel(recordFrames / recordFPS)
        }
    }
    
    fileprivate func updateTimerLabel(_ duration: Int) {
        var second = "\(duration % 60)"
        if second.count == 1 {
            second = "0" + second
        }
        
        var minute = "\(duration / 60)"
        if minute.count == 1 {
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
        print("touches begin")
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
    
    
    
    
    
    
}


extension WritingBoardViewController: WritingBoardToolSetViewControllerProtocol {
    
    func penChanged(_ width: CGFloat, color: UIColor) {
        usePen(width, color: color)
    }
    
    func eraserChanged(_ width: CGFloat) {
        useEraser(width: width)
    }
    
    func addImage(image: UIImage) {
        var normaledImage = normalImageOrientation(image)
        normaledImage = normalImageScale(normaledImage)
        
    }
    
    func insertPage() {
        insertPage(afterIndex: pageIndex)
//        messageTransport?.sendInsertPageEvent(pageIndex)
    }
    
    //Delegate as Hidden ToolView
    func toolsetViewControllerRetired(_ controller: WritingBoardToolSetViewController) {
        
        toolsetVC?.willMove(toParent: nil)
        toolsetVC?.view.removeFromSuperview()
        toolsetVC?.removeFromParent()
        toolsetVC = nil
        
    }
    
    func newMethod() {
        
    }
}


extension WritingBoardViewController {
    
    func normalImageOrientation(_ image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
        
        guard let normalImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }

        UIGraphicsEndImageContext()
        
        print("normalImageOrientation\n %@ ->\n %@", image, normalImage)
        print("image0 orient ", image.imageOrientation.rawValue, " scale ", image.scale, " size ", image.size)
        print("image1 orient ", normalImage.imageOrientation.rawValue, " scale ", normalImage.scale, " size ", normalImage.size)
        
        return normalImage
    }
    
    func normalImageScale(_ image: UIImage) -> UIImage {
        let screenScale = UIScreen.main.scale
        if image.scale == screenScale || image.cgImage == nil {
            return image
        }
        return UIImage(cgImage: (image.cgImage)!, scale: screenScale, orientation: .up)
    }
    
    
}

