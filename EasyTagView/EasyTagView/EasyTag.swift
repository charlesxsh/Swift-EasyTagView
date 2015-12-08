//
//  EasyTagUIView.swift
//  EasyTagView
//
//  Created by Charles Xia on 12/7/15.
//  Copyright © 2015 Charles. All rights reserved.
//

import UIKit

//recommand user using storyboard create a UIView and set custom class to EasyTagUIView
//Tag's height will dynamtically adjust depending on the actual UIView's height

//just for convenient, I wrote three class in single file. It should divide by 3 files.

class EasyTagUIView: UIView, UITextFieldDelegate, EasyTagTextFieldDelegate, EasyTagDelegate
{
    var textField:EasyTagTextField?
    var lineHeight:CGFloat?
    let spaceBetweenTextViewAndLine:CGFloat = 2
    let spaceBetweenTagAndTag:CGFloat = 2
    var nextTagPositionX:CGFloat? = 0
    var tagList:[EasyTag] = [EasyTag]() //store all the tag that shown on the view
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup()
    {
        self.lineHeight = self.frame.height
        let textViewFrame = CGRect(x:spaceBetweenTextViewAndLine, y: spaceBetweenTextViewAndLine, width: self.frame.width-2*spaceBetweenTextViewAndLine, height: self.frame.height-2*spaceBetweenTextViewAndLine)
        self.textField = EasyTagTextField(frame: textViewFrame)
        self.textField?.borderStyle = .None
        self.textField?.delegate = self
        self.textField?.easyTagTextFieldDelegate = self
        self.addSubview(textField!)
    }
    
    //textField delegate
    func textFieldDidEndEditing(textField: UITextField) {
        if !textField.text!.isEmpty {
            let newTag:EasyTag = EasyTag(startPositionX:self.nextTagPositionX!, TagViewHeight: self.lineHeight!, tagName: textField.text!, textSize:self.textField!.font!.pointSize)
            newTag.easyTagDelegate = self
            let newTagWidth:CGFloat? = newTag.getTagLength()+spaceBetweenTagAndTag
            textField.frame.origin.x += newTagWidth!
            textField.frame.size.width -= newTagWidth!
            self.addSubview(newTag)
            textField.text = ""
            self.nextTagPositionX! += newTagWidth!
            tagList.append(newTag)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    //EasyTagTextFieldDelegate
    func deletePreviousTag()
    {
        if self.tagList.count > 0{
            let newTagWidth:CGFloat? = tagList.last!.getTagLength()+self.spaceBetweenTagAndTag
            // deleting previous tag will let textfield move forward to where that tag are
            self.textField!.frame.origin.x -= newTagWidth!
            self.textField!.frame.size.width += newTagWidth!
            self.nextTagPositionX! -= newTagWidth!
            tagList.removeLast().removeFromSuperview()
        }
    }
    
    func deleteTagWithId(id: Int)
    {
        for i in 0...self.tagList.count-1
        {
            if self.tagList[i].hashValue == id
            {
                let newTagWidth:CGFloat? = self.tagList[i].getTagLength()+self.spaceBetweenTagAndTag
                //all tags after the tag that will be deleted should each move forward
                for j in i...self.tagList.count-1
                {
                    self.tagList[j].frame.origin.x -= newTagWidth!
                }
                self.textField!.frame.origin.x -= newTagWidth!
                self.textField!.frame.size.width += newTagWidth!
                self.nextTagPositionX! -= newTagWidth!
                tagList.removeAtIndex(i).removeFromSuperview()
                break
            }
        }
    }
}

protocol EasyTagDelegate
{
    func deleteTagWithId(id:Int)
}

class EasyTag: UIView
{
    var tagName:String?
    var tagLabel:UILabel?
    var deleteButtonLength:CGFloat = 20.0
    var deleteButton:UIButton?
    let spaceBetweenTagAndTagView:CGFloat = 2.0
    var easyTagDelegate:EasyTagDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(startPositionX:CGFloat, TagViewHeight:CGFloat, tagName:String, textSize:CGFloat)
    {
        self.tagName = tagName
        self.tagLabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.max, height: TagViewHeight))
        self.tagLabel?.numberOfLines = 0
        self.tagLabel?.text = tagName
        self.tagLabel?.font = UIFont(name: "Helvetica", size: textSize-3)
        self.tagLabel?.sizeToFit()
        
        let tagHeight:CGFloat = TagViewHeight - self.spaceBetweenTagAndTagView*2
        self.tagLabel?.frame.origin.y = (tagHeight-self.tagLabel!.frame.height)/2
        self.tagLabel?.frame.origin.x = 1.3
        self.tagLabel?.frame.size.width += 1
        super.init(frame: CGRect(x: startPositionX, y: spaceBetweenTagAndTagView, width:self.tagLabel!.frame.width+self.deleteButtonLength+1.5, height: tagHeight))
        self.addSubview(self.tagLabel!)
        
        deleteButton = UIButton(frame: CGRect(x: self.tagLabel!.frame.width+0.7, y: self.tagLabel!.frame.origin.y, width: deleteButtonLength, height: self.tagLabel!.frame.height))
        deleteButton?.setTitle("x", forState: .Normal)
        deleteButton?.addTarget(self, action: "deleteSelf:", forControlEvents:.TouchUpInside)
        self.addSubview(self.deleteButton!)
        print("\(self.tagName) is being initialized")
        
        self.layer.cornerRadius = 14
        self.backgroundColor = UIColor(red:0.20, green:0.67, blue:0.86, alpha:0.6)
    }
    
    func getTagLength()->CGFloat
    {
        return self.frame.width
    }
    
    //tell EasyTagUIView delete myself
    //identify by hashvalue
    func deleteSelf(sender:UIButton)
    {
        easyTagDelegate?.deleteTagWithId(self.hashValue)
    }
    
}

//delegate for EasyTagTextField: tell EasyTagUIView to delete previous tag when user click
//delete key in iOS keyboard
protocol EasyTagTextFieldDelegate
{
    func deletePreviousTag()
}

//override a UITextField for deleteBackward
//we need to use deleteBackward to detect delete key in iOS keyboard
class EasyTagTextField:UITextField
{
    var easyTagTextFieldDelegate:EasyTagTextFieldDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        if self.text == ""
        {
            self.easyTagTextFieldDelegate?.deletePreviousTag()
        }else{
            super.deleteBackward()
        }
        
    }
}