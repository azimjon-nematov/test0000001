//
//  SGDigitTextField.swift
//
//  Created by Soner Guler on 14.09.2019.
//

import UIKit

@IBDesignable
open class SGDigitTextField: UITextField {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBInspectable
    public var digitCount: Int = 0 {
        didSet {
            configure(with: digitCount)
        }
    }
    
    @IBInspectable
    public var digitColor: UIColor = .black {
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
    public var rBorderWidth: CGFloat = 1.0 {
        didSet {
            reload()
        }
    }

    @IBInspectable
    public var rCornerRadius: CGFloat = 10.0 {
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


    /// When isSecureTextEntry is selected, this character will be shown
    @IBInspectable
    public var secureCharacter: String = "●"

    
    private var labels = [UILabel]()
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
        if #available(iOS 12.0, *) {
            textContentType = .oneTimeCode
        }
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
    }

    /// Reloads the content
    public func reload() {
        configure(with: digitCount)
    }
    
    /// Clean the digits
    public func reset() {
        text = ""
        labels.forEach { $0.text = "" }
    }

    /// Responsible for creating and adding stackview on the textfield
    private func createStackView(for count: Int) {

        let stack = UIStackView(frame: bounds)
        stack.spacing = CGFloat(digitMargin)
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.isUserInteractionEnabled = false

        labels.removeAll()
        for _ in 1...count {
            let lbl = createLabel()
            labels.append(lbl)
            stack.addArrangedSubview(lbl)
        }
        stackView?.removeFromSuperview()
        stackView = stack
        addSubview(stackView!)
    }

    /// Returns label with format
    private func createLabel() -> UILabel {
        let lbl = UILabel()
        lbl.layer.cornerRadius = rCornerRadius
        lbl.layer.borderColor = rBorderColor.cgColor
        lbl.layer.borderWidth = rBorderWidth
        lbl.layer.shadowColor = shadowColor?.cgColor
        lbl.layer.shadowOffset = shadowOffset
        lbl.layer.shadowRadius = shadowRadius
        lbl.layer.shadowOpacity = shadowOpacity
        lbl.layer.backgroundColor = digitBackgroundColor?.cgColor
        lbl.font = font
        lbl.textColor = digitColor
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = false
        return lbl
    }

    /// Update current label focus.
    private func updateLabelFocus(focus: Bool = true) {
        labels.forEach {
            $0.layer.borderColor = rBorderColor.cgColor
            $0.layer.backgroundColor = digitBackgroundColor?.cgColor
        }

        if !focus { return }

        guard let text = text, labels.indices.contains(text.count) else { return  }

        let focusedLabel = labels[text.count]
        focusedLabel.layer.borderColor = highlightedBorderColor.cgColor
        focusedLabel.layer.backgroundColor = highlightedDigitBackgroundColor?.cgColor
    }

    /// Triggered when text changed
    @IBAction private func textChanged() {
        guard let text = text, text.count <= labels.count else { return }

        for i in 0 ..< labels.count {
            let lbl = labels[i]

            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                let char = isSecureTextEntry ? secureCharacter : String(text[index])
                lbl.text = char
            }
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
    
    //myFunctions Alisher
    func clearClick(){
        guard let text = text else { return }
        
        
        if self.labels.indices.contains(text.count - 1) {
            let lastLabel = self.labels[text.count - 1]
            lastLabel.text = nil
            self.text?.removeLast()
            updateLabelFocus()
        }
    }
    //myFunctions Alisher
    func numClick(num:String){
        guard let text = text else { return }
        guard text.count < labels.count else { return }
     
        
        self.text = (self.text ?? "") + num
        sendActions(for: .editingChanged)
        
        if (text.count + num.count) == labels.count && autoDismissKeyboard {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.typingFinishedHandler?(text+num)
            }
        }
        
    }
    //myFunctions Alisher
    func clearAll(){
        self.reset()
        updateLabelFocus()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //myAnimatinig funcs Alisher
    var t: Timer?
    var fill = 0
    func startAnimate(){
        dismissKeyboard()
        labels.forEach {
            $0.layer.borderColor = rBorderColor.cgColor
            $0.layer.backgroundColor = digitBackgroundColor?.cgColor
        }
        if(t==nil){
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
            if i == self.fill {
                labels[i].text = secureCharacter
            } else {
                labels[i].text = nil
            }
        }
        self.fill = self.fill + 1
    }
    func stopAnimate(){
        t?.invalidate()
        t = nil
        clearAll()
    }
    
    
    
    
    
    
}

extension SGDigitTextField: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {

        guard let text = text else { return false }

        if string == "", labels.indices.contains(text.count - 1) {
            let lastLabel = labels[text.count - 1]
            lastLabel.text = nil
            self.text?.removeLast()
            updateLabelFocus()
            return false
        }
        
        // If typing at the end and auto dismiss enabled, dismiss keyboard
        if (text.count + string.count) == labels.count && autoDismissKeyboard {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                // To complete the texting process add 100 mil delay
                self.dismissKeyboard()
                self.typingFinishedHandler?(text+string)
            }
        }

        guard text.count < labels.count else { return false }

        return true
    }
}

extension SGDigitTextField {
    
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
