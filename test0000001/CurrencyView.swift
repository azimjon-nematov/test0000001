//
//  CurrencyView.swift
//  MB
//
//  Created by MacBook Pro on 23.03.2023.
//  Copyright © 2023 Admin. All rights reserved.
//

import UIKit

@IBDesignable
class CurrencyView: UIView {
    
    @IBOutlet weak var mainStack: UIStackView!
//    @IBInspectable var flag = false {
//        didSet {
//            self.layoutIfNeeded()
//        }
//    }
    var view: UIView!
    var jarr = JSONArray("""
[{"Registry_Rate":"0.1415","Rate":1,"Sell_Rate":"0.1460","Date":"12:00:00 AM","Curr":"810","Icon":"https:\\/\\/wallet.ssb.tj\\/img\\/rub.png","Mnemonic":"RUB","Buy_Rate":"0.1415","Name":"Рубль РФ"},{"Mnemonic":"USD","Curr":"840","Registry_Rate":"10.9136","Buy_Rate":"10.9000","Rate":1,"Name":"Доллары США","Icon":"https:\\/\\/wallet.ssb.tj\\/img\\/usd.png","Sell_Rate":"10.9500","Date":"12:00:00 AM"},{"Curr":"978","Icon":"https:\\/\\/wallet.ssb.tj\\/img\\/eur.png","Sell_Rate":"11.7600","Buy_Rate":"11.5000","Name":"ЕВРО","Date":"12:00:00 AM","Registry_Rate":"11.8445","Rate":1,"Mnemonic":"EUR"}]
""")!
    
    var buyTitle = "Покупка"
    var sellTitle = "Продажа"
    var nbtTitle = "НБТ"
    
    var currencyTap: ((Int)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        commonInit()
    }
    
    private func commonInit() {
        let firstRow = mainStack.arrangedSubviews[0]
        
        let button = firstRow.viewWithTag(69169) as! UIButton
        button.setBackgroundImage(.add, for: .selected)
        
        
        let flag = firstRow.viewWithTag(691) as? UIImageView
        let mnem = firstRow.viewWithTag(692) as? UILabel
        let buy = firstRow.viewWithTag(693) as? UILabel
        let sell = firstRow.viewWithTag(694) as? UILabel
        let nbt = firstRow.viewWithTag(695) as? UILabel
        
        flag?.image = nil
        mnem?.text = ""
        buy?.text = buyTitle
        sell?.text = sellTitle
        nbt?.text = nbtTitle
        
        for i in 0 ..< jarr.count() {
            let currencyRow = firstRow.copyView()
            let flag = currencyRow.viewWithTag(691) as? UIImageView
            let mnem = currencyRow.viewWithTag(692) as? UILabel
            let buy = currencyRow.viewWithTag(693) as? UILabel
            let sell = currencyRow.viewWithTag(694) as? UILabel
            let nbt = currencyRow.viewWithTag(695) as? UILabel
            
            flag?.image = UIImage(named: "placeholder") ?? UIImage()
            mnem?.text = jarr.getJSONObject(i)?.getString("Mnemonic")
            buy?.text = jarr.getJSONObject(i)?.getString("Buy_Rate")
            sell?.text = jarr.getJSONObject(i)?.getString("Sell_Rate")
            nbt?.text = jarr.getJSONObject(i)?.getString("Registry_Rate")
            
            mainStack.addArrangedSubview(currencyRow)
            
            currencyRow.addTapGesture { [weak self] in
                
                DispatchQueue.main.async {
                    currencyRow.alpha = 1.0
//                    UIView.animate(withDuration: 0.1, delay: 0.0, options: .autoreverse, animations: {
//                        currencyRow.alpha = 0.3
//                    }, completion: nil)
                    UIView.animate(withDuration: 0.1) {
                        currencyRow.alpha = 0.3
                    } completion: { _ in
                        UIView.animate(withDuration: 0.3) {
                            currencyRow.alpha = 1.0
                        }
                    }

                }
                
                self?.currencyTap?(i)
            }
        }
    }
    
    func reload() {
        
        mainStack.arrangedSubviews.forEach { (subView) in
            if mainStack.arrangedSubviews.firstIndex(of: subView) == 0 {
                return
            }
            mainStack.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
        
        commonInit()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CurrencyView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
}












extension UIView
{
    func copyView<T: UIView>() -> T {
        return try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(try! NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding:false)) as! T

    }
}



extension UIView {
    func addTapGesture(action : @escaping ()->Void ){
        let tap = MyTapGestureRecognizer(target: self , action: #selector(self.handleTap(_:)))
        tap.action = action
        tap.numberOfTapsRequired = 1
        
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
    }
    @objc func handleTap(_ sender: MyTapGestureRecognizer) {
        sender.action!()
    }
}
class MyTapGestureRecognizer: UITapGestureRecognizer {
    var action : (()->Void)? = nil
}

class HighlightView: UIView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 0.3
            }, completion: nil)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.3
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: nil)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.3
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: nil)
        }
    }
}
