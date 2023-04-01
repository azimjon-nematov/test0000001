//
//  PinFieldView.swift
//  MB
//
//  Created by MacBook Pro on 09.03.2023.
//  Copyright © 2023 Admin. All rights reserved.
//

import UIKit

@IBDesignable
open class PinFieldView: UITextField {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBInspectable
    public var itemWidth: CGFloat = 25.0 {
        didSet {
            configure(with: digitCount)
        }
    }
    
    @IBInspectable
    public var itemHeight: CGFloat = 25.0 {
        didSet {
            configure(with: digitCount)
        }
    }

    @IBInspectable
    public var digitCount: Int = 0 {
        didSet {
            configure(with: digitCount)
        }
    }
    
    @IBInspectable
    public var digitMargin: Int = 4 {
        didSet {
            configure(with: digitCount)
        }
    }

    /// Digit label normal border color
    @IBInspectable
    public var rBorderColor: UIColor = .gray {
        didSet {
            reload()
        }
    }

    /// Digit label highlighted border color
    @IBInspectable
    public var highlightedBorderColor: UIColor = .red {
        didSet {
            reload()
        }
    }

    @IBInspectable
    public var rBorderWidth: CGFloat = 0 {
        didSet {
            reload()
        }
    }

    @IBInspectable
    public var rCornerRadius: CGFloat = 0 {
        didSet {
            reload()
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat = 0.0 {
        didSet {
            reload()
        }
    }

    @IBInspectable
    var shadowOpacity: Float = 0.0 {
        didSet {
            reload()
        }
    }

    @IBInspectable
    public var shadowOffset: CGSize = .zero {
        didSet {
            reload()
        }
    }

    @IBInspectable
    public var shadowColor: UIColor? {
        didSet {
            reload()
        }
    }

    @IBInspectable
    public var digitBackgroundColor: UIColor? {
        didSet {
            reload()
        }
    }

    @IBInspectable
    public var highlightedDigitBackgroundColor: UIColor? {
        didSet {
            reload()
        }
    }
    
    @IBInspectable
    public var autoDismissKeyboard: Bool = true
    
    /// Triggered when typing completed with all digits
    public var typingFinishedHandler: ((_ value: String) -> Void)?

    
    /// When isSecureTextEntry is selected, this character will be shown1 TODO
    @IBInspectable
    public var selectedImage: UIImage? {
        didSet {
            reload()
        }
    }
    
    /// When isSecureTextEntry is selected, this character will be shown2 TODO
    @IBInspectable
    public var unselectedImage: UIImage? {
        didSet {
            reload()
        }
    }
    
    private var imageViews = [UIImageView]()
    private var stackView: UIStackView?


    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    open override func setNeedsLayout() {
        super.setNeedsLayout()
        
        stackView?.frame = bounds
    }

    private func commonInit() {
        delegate = self
        keyboardType = .numberPad
        textColor = .clear
        tintColor = .clear
        textContentType = .oneTimeCode
        addTarget(self, action: #selector(textChanged), for: .editingChanged)
        addTarget(self, action: #selector(editingBegin), for: .editingDidBegin)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        if digitCount > 0 {
            configure(with: digitCount)
        }
    }


    /// Configures the textfield according to digit count
    ///
    /// - Parameter count: Digit count
    func configure(with count: Int) {
        createStackView(for: count)
        
        guard let text = text, text.count < imageViews.count else { return }
        
        for i in 0 ..< text.count {
            imageViews[i].image = selectedImage
        }
        for i in text.count ..< imageViews.count {
            imageViews[i].image = unselectedImage
        }
    }

    /// Reloads the content
    public func reload() {
        configure(with: digitCount)
    }
    
    /// Clean the digits
    public func reset() {
        text = ""
        imageViews.forEach { $0.image = unselectedImage }
    }

    /// Responsible for creating and adding stackview on the textfield
    private func createStackView(for count: Int) {
        
        let stack = UIStackView()
        stack.spacing = CGFloat(digitMargin)
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.isUserInteractionEnabled = false

        imageViews.removeAll()
        for _ in 0 ..< count {
            let img = createImageView()
            imageViews.append(img)
            stack.addArrangedSubview(img)
            img.translatesAutoresizingMaskIntoConstraints = false
            img.widthAnchor.constraint(equalToConstant: itemWidth).isActive = true
            img.heightAnchor.constraint(equalToConstant: itemHeight).isActive = true
        }
        
        let mainStack = UIStackView(frame: bounds)
        mainStack.alignment = .center
        mainStack.distribution = .fill
        mainStack.axis = .vertical
        mainStack.isUserInteractionEnabled = false
        
        mainStack.addArrangedSubview(stack)
        
        stackView?.removeFromSuperview()
        stackView = mainStack
        addSubview(stackView!)
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        mainStack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    /// Returns imageView with format
    private func createImageView() -> UIImageView {
        let img = UIImageView()
        img.layer.cornerRadius = rCornerRadius
        img.layer.borderColor = rBorderColor.cgColor
        img.layer.borderWidth = rBorderWidth
        img.layer.shadowColor = shadowColor?.cgColor
        img.layer.shadowOffset = shadowOffset
        img.layer.shadowRadius = shadowRadius
        img.layer.shadowOpacity = shadowOpacity
        img.layer.backgroundColor = digitBackgroundColor?.cgColor
        img.isUserInteractionEnabled = false
        img.contentMode = .scaleAspectFit
        img.tintColor = self.tintColor
        return img
    }

    /// Update current label focus.
    private func updateLabelFocus(focus: Bool = true) {
        imageViews.forEach {
            $0.layer.borderColor = rBorderColor.cgColor
            $0.layer.backgroundColor = digitBackgroundColor?.cgColor
        }

        if !focus { return }

        guard let text = text, imageViews.indices.contains(text.count) else { return  }
        
        let focusedImageView = imageViews[text.count]
        focusedImageView.layer.borderColor = highlightedBorderColor.cgColor
        focusedImageView.layer.backgroundColor = highlightedDigitBackgroundColor?.cgColor
    }

    /// Triggered when text changed
    @IBAction private func textChanged() {
        guard let text = text, text.count <= imageViews.count else { return }

        for i in 0 ..< text.count {
            imageViews[i].image = selectedImage
        }
        for i in text.count ..< imageViews.count {
            imageViews[i].image = unselectedImage
        }
        
        updateLabelFocus()
    }

    /// Triggered when editing begin
    @IBAction private func editingBegin() {
        updateLabelFocus()
    }

    /// Triggered when keyboard is about to hide
    @objc func keyboardWillHide(notification: Notification) {
        updateLabelFocus(focus: false)
    }
    
    private func dismissKeyboard() {
        endEditing(true)
    }
    
    /// Removes last
    func clearClick() {
        guard let text = text else { return }
        if self.imageViews.indices.contains(text.count - 1) {
            let lastImageView = self.imageViews[text.count - 1]
            lastImageView.image = unselectedImage
            self.text?.removeLast()
            updateLabelFocus()
        }
        
    }
    
    //myFunctions Alisher
    func numClick(num:String) {
        guard let text = text else { return }
        guard text.count < imageViews.count else { return }
     
        
        self.text = (self.text ?? "") + num
        sendActions(for: .editingChanged)
        
        if (text.count + num.count) == imageViews.count && autoDismissKeyboard {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.typingFinishedHandler?(text+num)
            }
        }
        
    }
    
    //myFunctions Alisher
    func clearAll() {
        self.reset()
        updateLabelFocus()
    }
    
    
    //myAnimatinig funcs Alisher
    var t: Timer?
    var fill = 0
    func startAnimate() {
        dismissKeyboard()
        imageViews.forEach {
            $0.layer.borderColor = rBorderColor.cgColor
            $0.layer.backgroundColor = digitBackgroundColor?.cgColor
        }
        if(t==nil) {
            t = Timer.scheduledTimer(
            timeInterval: TimeInterval(0.1),
            target: self,
            selector: #selector(timerAction),
            userInfo: nil,
            repeats: true)
        }
    }
    
    @objc private func timerAction() {
        if self.fill == digitCount { self.fill = 0 }
        
        for i in 0...digitCount-1 {
            imageViews[i].image = (i == self.fill) ? selectedImage : unselectedImage
        }
        
        self.fill = self.fill + 1
    }
    
    func stopAnimate() {
        t?.invalidate()
        t = nil
        clearAll()
    }
}

extension PinFieldView: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {

        guard let text = text else { return false }

        if string == "", imageViews.indices.contains(text.count - 1) {
            let lastImageView = imageViews[text.count - 1]
            lastImageView.image = unselectedImage
            self.text?.removeLast()
            updateLabelFocus()
            return false
        }
        
        // If typing at the end and auto dismiss enabled, dismiss keyboard
        if (text.count + string.count) == imageViews.count && autoDismissKeyboard {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                // To complete the texting process add 100 mil delay
                self.dismissKeyboard()
                self.typingFinishedHandler?(text+string)
            }
        }

        guard text.count < imageViews.count else { return false }

        return true
    }
}

extension PinFieldView {
    
    open override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    
    open override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}


// TODO: remove

//img.translatesAutoresizingMaskIntoConstraints = false
//        img.addConstraint(NSLayoutConstraint(item: img,
//                                             attribute: NSLayoutConstraint.Attribute.height,
//                                             relatedBy: NSLayoutConstraint.Relation.equal,
//                                             toItem: img,
//                                             attribute: NSLayoutConstraint.Attribute.width,
//                                             multiplier: 1,
//                                             constant: 0))
//img.widthAnchor.constraint(equalTo: img.heightAnchor, multiplier: 1.0).isActive = true
