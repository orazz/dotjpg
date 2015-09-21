//
//  MKTextField.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/3/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import UIKit
import QuartzCore

class MKTextView: UITextView {
    
    private lazy var mkLayer: MKLayer = MKLayer(superLayer: self.layer)
    private var bottomBorderLayer: CALayer?
    
    @IBInspectable var bottomBorderEnabled: Bool = true {
        didSet {
            bottomBorderLayer?.removeFromSuperlayer()
            bottomBorderLayer = nil
            if bottomBorderEnabled {
                bottomBorderLayer = CALayer()
                bottomBorderLayer?.frame = CGRect(x: 0, y: self.layer.bounds.height - 1, width: self.bounds.width, height: 1)
                bottomBorderLayer?.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2).CGColor
                self.layer.addSublayer(bottomBorderLayer!)
            }
        }
    }
    
    @IBInspectable var kPlaceholderTextViewInsetSpan: CGFloat = 0.0 {
        didSet { setNeedsDisplay() }
    }
    /** The string that will be put in the placeholder */
    @IBInspectable var placeholder: NSString? { didSet { setNeedsDisplay() } }
    /** color for the placeholder text. Default is UIColor.lightGrayColor() */
    @IBInspectable var placeholderColor: UIColor = UIColor.lightGrayColor()
    
    /** Border color for the text view */
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    /** Border color for the text view */
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    /** Border color for the text view */
    @IBInspectable var cornerRadius: CGFloat = 6.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = cornerRadius > 0.0
        }
    }
    
    // MARK: - Text insertion methods need to "remove" the placeholder when needed
    
    /** Override normal text string */
    override var text: String! { didSet { setNeedsDisplay() } }
    
    /** Override attributed text string */
    override var attributedText: NSAttributedString! { didSet { setNeedsDisplay() } }
    
    /** Setting content inset needs a call to setNeedsDisplay() */
    override var contentInset: UIEdgeInsets { didSet { setNeedsDisplay() } }
    
    /** Setting font needs a call to setNeedsDisplay() */
    override var font: UIFont? { didSet { setNeedsDisplay() } }
    
    /** Setting text alignment needs a call to setNeedsDisplay() */
    override var textAlignment: NSTextAlignment { didSet { setNeedsDisplay() } }
    
    // MARK: - Lifecycle
    
    
    
    //MARK: attributes
    
    var  maxHeight:CGFloat?
    var  heightConstraint:NSLayoutConstraint?
    
    //MARK: initialize
    /** Override coder init, for IB/XIB compatibility */
    #if !TARGET_INTERFACE_BUILDER
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpInit()
        listenForTextChangedNotifications()
    }
    
    #endif
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpConstraint()
    }
    
    //MARK: private
    
    private func setUpInit() {
        for constraint in self.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.Height {
                self.heightConstraint = constraint
                break;
            }
        }
        
    }
    
    private func setUpConstraint() {
        var finalContentSize:CGSize = self.contentSize
        finalContentSize.width  += (self.textContainerInset.left + self.textContainerInset.right ) / 2.0
        finalContentSize.height += (self.textContainerInset.top  + self.textContainerInset.bottom) / 2.0
        
        fixTextViewHeigth(finalContentSize)
    }
    
    private func fixTextViewHeigth(finalContentSize:CGSize) {
        if let maxHeight = self.maxHeight {
            var  customContentSize = finalContentSize;
            
            customContentSize.height = min(customContentSize.height, CGFloat(maxHeight))
            
            self.heightConstraint?.constant = customContentSize.height;
            
            if finalContentSize.height <= CGRectGetHeight(self.frame) {
                let textViewHeight = (CGRectGetHeight(self.frame) - self.contentSize.height * self.zoomScale)/2.0
                
                self.contentOffset = CGPointMake(0, -(textViewHeight < 0.0 ? 0.0 : textViewHeight))
                
            }
        }
    }
    
    /** Initializes the placeholder text view, waiting for a notification of text changed */
    func listenForTextChangedNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChangedForPlaceholderTextView:", name:UITextViewTextDidChangeNotification , object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChangedForPlaceholderTextView:", name:UITextViewTextDidBeginEditingNotification , object: self)
    }
    
    /** willMoveToWindow will get called with a nil argument when the window is about to dissapear */
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        if newWindow == nil { NSNotificationCenter.defaultCenter().removeObserver(self) }
        else { listenForTextChangedNotifications() }
    }
    
    
    // MARK: - Adjusting placeholder.
    func textChangedForPlaceholderTextView(notification: NSNotification) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // in case we don't have a text, put the placeholder (if any)
        if self.text.characters.count == 0 && self.placeholder != nil {
            let baseRect = placeholderBoundsContainedIn(self.bounds)
            let font = self.font ?? self.typingAttributes[NSFontAttributeName] as? UIFont ?? UIFont.systemFontOfSize(UIFont.systemFontSize())
            
            self.placeholderColor.set()
            
            // build the custom paragraph style for our placeholder text
            var customParagraphStyle: NSMutableParagraphStyle!
            if let defaultParagraphStyle =  typingAttributes[NSParagraphStyleAttributeName] as? NSParagraphStyle {
                customParagraphStyle = defaultParagraphStyle.mutableCopy() as! NSMutableParagraphStyle
            } else { customParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle }
            // set attributes
            customParagraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            customParagraphStyle.alignment = self.textAlignment
            let attributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: customParagraphStyle.copy() as! NSParagraphStyle, NSForegroundColorAttributeName: self.placeholderColor]
            // draw in rect.
            self.placeholder?.drawInRect(baseRect, withAttributes: attributes)
        }
    }
    
    func placeholderBoundsContainedIn(containerBounds: CGRect) -> CGRect {
        // get the base rect with content insets.
        let baseRect = UIEdgeInsetsInsetRect(containerBounds, UIEdgeInsetsMake(kPlaceholderTextViewInsetSpan, kPlaceholderTextViewInsetSpan, 0, 0))
        
        // adjust typing and selection attributes
        if typingAttributes.count > 0 {
            if let paragraphStyle = typingAttributes[NSParagraphStyleAttributeName] as? NSParagraphStyle {
                baseRect.offsetBy(dx: paragraphStyle.headIndent, dy: paragraphStyle.firstLineHeadIndent)
            }
        }
        
        return baseRect
    }
}
