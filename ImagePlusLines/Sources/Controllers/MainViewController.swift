//
//  ViewController.swift
//  ImagePlusLines
//
//  Created by zippo on 9/16/18.
//  Copyright © 2018 zippo. All rights reserved.
//

import UIKit
import MobileCoreServices

class MainViewController: UIViewController {
    @IBOutlet weak var ToptextField : UITextField!
    @IBOutlet weak var BtmtextField : UITextField!
    @IBOutlet weak var imageView : UIImageView!
    @IBAction func apply_text_on_image(sender : UIButton) {
        render_this()
    }
    
    private let font_name = "TimesNewRomanPS-BoldMT"
    private let defaultTextSize = 40
    private let maxTextSize = 58
    private let minTextSize = 22
    private let resizeMemeMaxSize:CGFloat = 700
    
    var current_top_size : Int!
    var current_btm_size : Int!
    
    private func render_this() {
        guard let image = imageView.image else {
            return
        }
        let top_text = ToptextField.text ?? ""
        let btm_text = BtmtextField.text ?? ""
        
        imageView.image = applyTextOnMeme(inMeme: image, withTopText: top_text, withBottomText: btm_text, withTopTextSize: current_top_size, withBottomTextSize: current_btm_size)
        
    }
    
    private func resizeMemeWith(newSize: CGSize, meme: UIImage) -> UIImage {
        
        let horizontalRatio = newSize.width / meme.size.width
        let verticalRatio = newSize.height / meme.size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: meme.size.width * ratio, height: meme.size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        meme.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newMeme = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newMeme!
    }
    
    private func applyTextOnMeme(inMeme unscaledMeme: UIImage, withTopText topTextOrigianl: String, withBottomText bottomTextOriginal: String, withTopTextSize topTextSize : Int, withBottomTextSize bottomTextSize : Int) -> UIImage {
        let textColor = UIColor.white
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        var meme = unscaledMeme
        
        if(unscaledMeme.size.height > resizeMemeMaxSize || unscaledMeme.size.width > resizeMemeMaxSize){
            // resize the meme if it's large
            meme = resizeMemeWith(newSize: CGSize(width: 700, height: 700), meme: unscaledMeme)
        }

        let topText = topTextOrigianl.uppercased()
        let bottomText = bottomTextOriginal.uppercased()
        
        let scale = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(meme.size, false, scale)
        
        let topTextFont = UIFont(name: font_name, size: CGFloat(topTextSize))!
        let bottomTextFont = UIFont(name: font_name, size: CGFloat(bottomTextSize))!
        
        let topTextFontAttributes = [
            NSAttributedString.Key.font: topTextFont,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.strokeWidth: -6
            ] as [NSAttributedString.Key : Any]
        
        
        let bottomTextFontAttributes = [
            NSAttributedString.Key.font: bottomTextFont,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.strokeWidth: -6
            ] as [NSAttributedString.Key : Any]
        
        let topTextPoint = CGPoint(x: 0, y: 10)
        let bottomTextPoint = CGPoint(x: 0, y: meme.size.height - (bottomTextFont.lineHeight) - 20)
        
        meme.draw(in: CGRect(origin: CGPoint.zero, size: meme.size))
        
        let topRect = CGRect(origin: topTextPoint, size: meme.size)
        let bottomRect = CGRect(origin: bottomTextPoint, size: meme.size)
        
        topText.draw(in: topRect, withAttributes: topTextFontAttributes)
        bottomText.draw(in: bottomRect, withAttributes: bottomTextFontAttributes)
        
        let newMeme = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newMeme!
    }
}

// MARK: Handling font size change signals
extension MainViewController {
    @objc func topplus() {
        guard imageView.image != nil, current_top_size != maxTextSize else {
            return
        }
        current_top_size += 1
        render_this()
    }
    @objc func topminus() {
        guard imageView.image != nil, current_top_size != minTextSize else {
            return
        }
        current_top_size -= 1
        render_this()
    }
    
    @objc func btmplus() {
        guard imageView.image != nil, current_top_size != maxTextSize else {
            return
        }
        current_btm_size += 1
        render_this()
    }
    @objc func btmminus() {
        guard imageView.image != nil, current_top_size != minTextSize else {
            return
        }
        current_btm_size -= 1
        render_this()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        current_top_size = defaultTextSize
        current_btm_size = defaultTextSize
        
        let toolbar = UIToolbar()
        let placeholder = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btn1 = UIBarButtonItem(title: "Bigger", style: .plain, target: self, action: #selector(topplus))
        let btn2 = UIBarButtonItem(title: "Lower", style: .plain, target: self, action: #selector(topminus))
        toolbar.items = [placeholder, btn1, btn2]
        toolbar.sizeToFit()
        ToptextField.inputAccessoryView = toolbar
        
        let toolbar2 = UIToolbar()
        let btn21 = UIBarButtonItem(title: "Bigger", style: .plain, target: self, action: #selector(btmplus))
        let btn22 = UIBarButtonItem(title: "Lower", style: .plain, target: self, action: #selector(btmminus))
        toolbar2.items = [placeholder, btn21, btn22]
        toolbar2.sizeToFit()
        BtmtextField.inputAccessoryView = toolbar2
    }
    
    
}

extension MainViewController : UINavigationControllerDelegate {
    
}


extension MainViewController : UIImagePickerControllerDelegate {
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        // First check for an edited image, then the original image
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            imageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: ImagePicker
    private func imagePickerControllerSourceTypeActionHandler(for sourceType: UIImagePickerController.SourceType) -> (_ action: UIAlertAction) -> Void {
        return { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            
            imagePickerController.mediaTypes = [kUTTypeImage as String]
            // Import the MobileCoreServices framework to use kUTTypeImage (see top of file)
            
            imagePickerController.allowsEditing = true
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func select_image(sender: UIButton){
        let alertController = UIAlertController(title: "Image Source", message: "Pick Image Source", preferredStyle: .actionSheet)
        let checkSourceType = { (sourceType: UIImagePickerController.SourceType, buttonText: String) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                alertController.addAction(UIAlertAction(title: buttonText, style: .default, handler: self.imagePickerControllerSourceTypeActionHandler(for: sourceType)))
            }
        }
        
        checkSourceType(.photoLibrary, "Photo Library")
        
        if !alertController.actions.isEmpty {
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
