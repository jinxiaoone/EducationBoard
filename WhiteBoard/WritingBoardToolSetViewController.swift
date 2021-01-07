//
//  RAYWritingBoardToolSetViewController.swift
//  WhiteBoard
//
//  Created by jinxiao on 16/7/1.
//  Copyright © 2016年 jinxiao. All rights reserved.
//

import UIKit
import MobileCoreServices

class QWritingBoardColor {
    //通过此方式创建的blackColor != UIColor.blackColor
    static let blackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let redColor   = UIColor.red
    static let blueColor  = UIColor.blue
    static let whiteColor = UIColor.white
}

protocol WritingBoardToolSetViewControllerProtocol {
    
    func penChanged(_ width: CGFloat, color: UIColor)
    func eraserChanged(_ width: CGFloat)
    
    func addImage(image: UIImage)
    
    func insertPage()
    
    func toolsetViewControllerRetired(_ controller: WritingBoardToolSetViewController)
}

enum State {
    case Active
    case Idle
    case Retiring
}

//Paint Attribute
class ToolSetAttribute {
    var penWidth: CGFloat = WritingBoardToolSetViewController.PenWidthMin
    var penColor = QWritingBoardColor.blackColor
    var eraserWidth: CGFloat = WritingBoardToolSetViewController.EraserWidthMin
    var isAllowHandTouch = true
}

class WritingBoardToolSetViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var penPopView: UIView!
    @IBOutlet weak var mediaPopView: UIView!
    @IBOutlet weak var eraserPopView: UIView!
    
    @IBOutlet weak var penButton: UIButton!

    //画笔属性
    @IBOutlet weak var penWidthSlider: UISlider!
    @IBOutlet weak var penColorBlueButton: UIButton!
    @IBOutlet weak var penColorBlackButton: UIButton!
    @IBOutlet weak var penColorRedButton: UIButton!
    
    //橡皮擦属性
    @IBOutlet weak var eraserWidthSlider: UISlider!
    
    @IBOutlet weak var closeButton: UIButton!
    
    //Media: Picture/Photo/Office
    @IBOutlet weak var mediaPhoto: UIButton!
    @IBOutlet weak var mediaPicture: UIButton!
    @IBOutlet weak var mediaOffice: UIButton!
    
    @IBOutlet weak var addMediaButton: UIButton!
    
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var handTouchButton: UIButton!
    
    //Add page
    @IBOutlet weak var insertPageButton: UIButton!
    
    
    //取值为与其它平台的约定
    //画笔大小值min=2,max=16
    fileprivate static let PenWidthMin: CGFloat = 1.0
    fileprivate static let PenWidthMax: CGFloat = 8.0
    fileprivate static let EraserWidthMin: CGFloat = 5.0
    fileprivate static let EraserWidthMax: CGFloat = 40.0
    
    var delegate: WritingBoardToolSetViewControllerProtocol?
    
    var toolsetAttribute = ToolSetAttribute()
    
    private var state = State.Active
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize toolView
        toolbarView.backgroundColor = UIColor.clear
        penPopView.backgroundColor  = UIColor.clear
        eraserPopView.backgroundColor = UIColor.clear
        mediaPopView.backgroundColor  = UIColor.clear
        
        hideAllPopPanel()
        
        //Button action for paint color
        penColorBlackButton.addTarget(self, action: #selector(WritingBoardToolSetViewController.penColorButtonTapped(_:)), for: .touchUpInside)
        penColorBlueButton.addTarget(self, action: #selector(WritingBoardToolSetViewController.penColorButtonTapped(_:)), for: .touchUpInside)
        penColorRedButton.addTarget(self, action: #selector(WritingBoardToolSetViewController.penColorButtonTapped(_:)), for: .touchUpInside)
        
        penWidthSlider.isContinuous = false
        penWidthSlider.minimumValue = Float(WritingBoardToolSetViewController.PenWidthMin)
        penWidthSlider.maximumValue  = Float(WritingBoardToolSetViewController.PenWidthMax)
        penWidthSlider.addTarget(self, action: #selector(WritingBoardToolSetViewController.penWidthChanged(_:)), for: .valueChanged)
        
        //eraser clean action with width
        eraserWidthSlider.isContinuous = false
        eraserWidthSlider.minimumValue = Float(WritingBoardToolSetViewController.EraserWidthMin)
        eraserWidthSlider.maximumValue = Float(WritingBoardToolSetViewController.EraserWidthMax)
        
    }
    
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        guard state != .Retiring else {
            return;
        }
        state = .Retiring
        slideOutPaintTools()
    }
    
    
    @objc func penColorButtonTapped(_ sender: UIButton) {
        if sender == penColorBlackButton {
            toolsetAttribute.penColor = QWritingBoardColor.blackColor
        } else if sender == penColorBlueButton {
            toolsetAttribute.penColor = QWritingBoardColor.blueColor
        } else if sender == penColorRedButton {
            toolsetAttribute.penColor = QWritingBoardColor.redColor
        }
        
        activePenColor(toolsetAttribute.penColor)
        delegate?.penChanged(toolsetAttribute.penWidth,
                             color: toolsetAttribute.penColor)
        
    }
    
    fileprivate func activePenColor(_ penColor: UIColor) {
        
        penColorBlackButton.setImage(UIImage(named: "WBPenColorBlack"), for: .normal)
        penColorBlueButton.setImage(UIImage(named: "WBPenColorBlue"),  for: .normal)
        penColorRedButton.setImage(UIImage(named: "WBPenColorRed"),   for: .normal)
        
        if penColor == QWritingBoardColor.blackColor {
            penColorBlackButton.setImage(UIImage(named: "WBPenColorBlackActive"), for: .normal)
            penButton.setImage(UIImage(named: "WBPenBlack"), for: UIControl.State())
            penWidthSlider.minimumTrackTintColor = QWritingBoardColor.blackColor
        } else if penColor == QWritingBoardColor.blueColor {
            penColorBlueButton .setImage(UIImage(named: "WBPenColorBlueActive"),  for: .normal)
            penButton.setImage(UIImage(named: "WBPenBlue"), for: UIControl.State())
            penWidthSlider.minimumTrackTintColor = QWritingBoardColor.blueColor
            
        } else if penColor == QWritingBoardColor.redColor {
            penColorRedButton.setImage(UIImage(named: "WBPenColorRedActive"), for: .normal)
            penButton.setImage(UIImage(named: "WBPenRed"), for: .normal)
            penWidthSlider.minimumTrackTintColor = QWritingBoardColor.redColor
        }
    }
    
    //hidden all tool Button
    fileprivate func hidePaintTools(_ hidden: Bool) {
        
        penButton.isHidden = hidden
        eraserButton.isHidden = hidden
        handTouchButton.isHidden = hidden
        addMediaButton.isHidden = hidden
        insertPageButton.isHidden = hidden
        
        closeButton.isHidden = hidden
    }
    
    //Hidden all ToolView
    fileprivate func hideAllPopPanel() {
        hidePenPopPanel(true)
        hideMediaPopPanel(true)
        hideEraserPopPanel(true)
    }
    
    //Hidden PaintTool
    fileprivate func hidePenPopPanel(_ hidden: Bool) {
        penPopView.isHidden = hidden
    }
    
    //Hidden MediaTool
    fileprivate func hideMediaPopPanel(_ hidden: Bool) {
        mediaPopView.isHidden = hidden
    }
    
    //Hidden EraseTool
    fileprivate func hideEraserPopPanel(_ hidden: Bool) {
        eraserPopView.isHidden = hidden
    }
    
    
    func slideOutPaintTools() {
        
        hideAllPopPanel()
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            
        }, completion: { (finish: Bool) -> Void in
            
            self.hidePaintTools(true)
            self.delegate?.toolsetViewControllerRetired(self)
        })
    }

    //画笔宽度
    @objc func penWidthChanged(_ sender: AnyObject) {
        print("pen Width is ", penWidthSlider.value)
        toolsetAttribute.penWidth = CGFloat(penWidthSlider.value)
        if let delegate = delegate {
            delegate.penChanged(toolsetAttribute.penWidth, color: toolsetAttribute.penColor)
        }
    }
    
    //打开多媒体画板
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        let popMediaPanel = !mediaPopView.isHidden
        hideAllPopPanel()
        hideMediaPopPanel(popMediaPanel)
    }
    
    
    
    //Paint Action
    @IBAction func penButtonTapped(_ sender: UIButton) {
        let popPenPanel = !penPopView.isHidden
        hideAllPopPanel()
        hidePenPopPanel(popPenPanel)
        state = .Active
        
        delegate?.penChanged(toolsetAttribute.penWidth, color: toolsetAttribute.penColor)
    }
    
    // 橡皮擦
    @IBAction func eraserButtonTapped(_ sender: UIButton) {
        let popEraserPanel = !eraserPopView.isHidden
        hideAllPopPanel()
        hideEraserPopPanel(popEraserPanel)
        state = .Active
        
        delegate?.eraserChanged(toolsetAttribute.eraserWidth)
    }
    
    // Mute 禁言
    @IBAction func handButtonTapped(_ sender: AnyObject) {
        hideAllPopPanel()
        
        toolsetAttribute.isAllowHandTouch = !toolsetAttribute.isAllowHandTouch
        updateHandeButton(toolsetAttribute.isAllowHandTouch)
    }
    
    fileprivate func updateHandeButton(_ allow: Bool) {
        let imageName = allow ? "WBHandTouchAllow" : "WBHandTouchForbbid"
        let handIcon = UIImage(named: imageName)
        handTouchButton.setImage(handIcon, for: .normal)
    }
    
    
    // 加载本地图片
    @IBAction func localPictureButtonTapped(_ sender: UIButton) {
        state = .Idle
        hideAllPopPanel()
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = .photoLibrary;
        let imageType = kUTTypeImage as String
        imagePicker.mediaTypes = [imageType]
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.sourceView = sender
        present(imagePicker, animated:true, completion:nil)
    }
    
    
    // 相机
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        
        
    }
    
    // Office
    @IBAction func officeButtonTapped(_ sender: UIButton) {
        hideAllPopPanel()
        
        
    }
    
    
    @IBAction func addPageButtonTapped(_ sender: UIButton) {
        hideAllPopPanel()
        delegate?.insertPage()
    }
    
    
}


extension WritingBoardToolSetViewController: UIImagePickerControllerDelegate {
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        state = .Active

        dismiss(animated: true, completion: nil)
        closeButtonTapped(self)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        state = .Active
        dismiss(animated: true, completion:nil)
        
        let pickedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage
      
        if let image = pickedImage {
            delegate?.addImage(image: image)
        }
        closeButtonTapped(self)
    }
    
}
