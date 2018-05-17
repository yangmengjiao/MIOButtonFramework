//
//  MIOButton.swift
//  MIOButtonFramework
//
//  Created by mengjiao on 5/16/18.
//  Copyright © 2018 mengjiao. All rights reserved.
//


import UIKit



/// create a clouse
public typealias ResultClosure = (_ number: String)->()

public protocol MIOButtonDelegate: NSObjectProtocol {
    func numberButtonResult(_ numberButton: MIOButton, number: String)
}

@IBDesignable open class MIOButton: UIView {
    weak var delegate: MIOButtonDelegate?  // delegate
    var NumberResultClosure: ResultClosure?     // clouse
    var decreaseBtn: UIButton!
    var increaseBtn: UIButton!
    var textField: UITextField!    // number of quatity
    var timer: Timer!              //timer
    public var _minValue = 1
    public var _maxValue = Int.max
    public var shakeAnimation: Bool = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        //default size
        if frame.isEmpty {self.frame = CGRect(x: 0, y: 0, width: 110, height: 30)}
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override open func awakeFromNib() {
        setupUI()
    }
    
    //set up ui
    fileprivate func setupUI() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 3.0
        clipsToBounds = true
        
        decreaseBtn = setupButton(title: "－")
        increaseBtn = setupButton(title: "＋")
        
        textField = UITextField.init()
        textField.text = "1"
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        textField.isUserInteractionEnabled = false
        textField.textAlignment = NSTextAlignment.center
        self.addSubview(textField)
    }
    
    // MARK: - lay out sub views UI
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let height = frame.size.height
        let width = frame.size.width
        decreaseBtn.frame = CGRect(x: 0, y: 0, width: height, height: height)
        increaseBtn.frame = CGRect(x: width - height, y: 0, width: height, height: height)
        textField.frame = CGRect(x: height, y: 0, width: width - 2.0*height, height: height)
    }
    
    //set up buttons
    fileprivate func setupButton(title:String) -> UIButton {
        let button = UIButton.init()
        button.setTitle(title, for: UIControlState())
        button.setTitleColor(UIColor.gray, for: UIControlState())
        button.addTarget(self, action:#selector(self.touchDown(_:)) , for: UIControlEvents.touchDown)
        button.addTarget(self, action:#selector(self.touchUp) , for:UIControlEvents.touchUpOutside)
        button.addTarget(self, action:#selector(self.touchUp) , for:UIControlEvents.touchUpInside)
        button.addTarget(self, action:#selector(self.touchUp) , for:UIControlEvents.touchCancel)
        self.addSubview(button)
        return button
    }
    
    // MARK: - touch buttons operation
    @objc fileprivate func touchDown(_ button: UIButton) {
        textField.endEditing(false)
        if button == decreaseBtn {
            timer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.decrease), userInfo: nil, repeats: true)
        } else {
            timer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.increase), userInfo: nil, repeats: true)
        }
        timer.fire()
    }
    
    //clear timer when release button
    @objc fileprivate func touchUp()  {
        cleanTimer()
    }
    
    // MARK: - minuse operation
    @objc fileprivate func decrease() {
        if (textField.text?.count)! == 0 || Int(textField.text!)! <= _minValue {
            textField.text = "\(_minValue)"
        }
        
        let number = Int(textField.text!)! - 1
        if number >= _minValue {
            textField.text = "\(number)"
            NumberResultClosure?("\(number)")// call clouse
            delegate?.numberButtonResult(self, number: "\(number)")// call delegate
        } else {
            //add shake animation
            if shakeAnimation {shakeAnimationFunc()}
            print("order number can not smaller than\(_minValue)")
        }
    }
    
    // MARK: - increase operation
    @objc fileprivate func increase() {
        if (textField.text?.count)! == 0 || Int(textField.text!)! <= _minValue {
            textField.text = "\(_minValue)"
        }
        
        let number = Int(textField.text!)! + 1
        
        if number <= _maxValue {
            textField.text = "\(number)"
            NumberResultClosure?("\(number)")// call clouse
            delegate?.numberButtonResult(self, number: "\(number)")// call delegate
        } else {
            //add shake animation
            if shakeAnimation {shakeAnimationFunc()}
            print("order number is over \(_maxValue)")
        }
        
        
    }
    
    // MARK: - shake animation
    fileprivate func shakeAnimationFunc() {
        let animation = CAKeyframeAnimation.init(keyPath: "position.x")
        // get current view position
        let positionX = layer.position.x
        //shake range
        animation.values = [(positionX-10),(positionX),(positionX+10)]
        //repeat 3 times
        animation.repeatCount = 3
        //animation time
        animation.duration = 0.07
        layer.add(animation, forKey: nil)
    }
    
    fileprivate func cleanTimer() {
        if ((timer?.isValid) != nil) {
            timer.invalidate()
            timer = nil
        }
    }
    
    deinit {
        cleanTimer()
    }
}

// MARK: - custom ui
public extension MIOButton {
    
    /**
     set quatity number text field
     */
    var currentNumber: String? {
        get {
            return (textField.text!)
        }
        set {
            textField.text = newValue
        }
    }
    /**
     set min value
     */
    var minValue: Int {
        get {
            return _minValue
        }
        set {
            _minValue = newValue
            textField.text = "\(newValue)"
        }
    }
    /**
     set max value
     */
    var maxValue: Int {
        get {
            return _maxValue
        }
        set {
            _maxValue = newValue
        }
    }
    
    /**
     call back method
     */
    func numberResult(_ finished: @escaping ResultClosure) {
        NumberResultClosure = finished
    }
    
    /**
     set border color
     */
    func borderColor(_ borderColor: UIColor) {
        layer.borderColor = borderColor.cgColor
        decreaseBtn.layer.borderColor = borderColor.cgColor
        increaseBtn.layer.borderColor = borderColor.cgColor
        
        layer.borderWidth = 0.5
        decreaseBtn.layer.borderWidth = 0.5
        increaseBtn.layer.borderWidth = 0.5
    }
}
