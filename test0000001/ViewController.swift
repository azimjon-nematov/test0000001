//
//  ViewController.swift
//  test0000001
//
//  Created by MacBook Pro on 13.03.2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let curr = view.viewWithTag(123) as? CurrencyView {
            
            curr.jarr = JSONArray("""
[{"Registry_Rate":"0.1415","Rate":1,"Sell_Rate":"0.1460","Date":"12:00:00 AM","Curr":"810","Icon":"https:\\/\\/wallet.ssb.tj\\/img\\/rub.png","Mnemonic":"RUB","Buy_Rate":"0.1415","Name":"Рубль РФ"},{"Mnemonic":"USD","Curr":"840","Registry_Rate":"10.9136","Buy_Rate":"10.9000","Rate":1,"Name":"Доллары США","Icon":"https:\\/\\/wallet.ssb.tj\\/img\\/usd.png","Sell_Rate":"10.9500","Date":"12:00:00 AM"},{"Curr":"978","Icon":"https:\\/\\/wallet.ssb.tj\\/img\\/eur.png","Sell_Rate":"11.7600","Buy_Rate":"11.5000","Name":"ЕВРО","Date":"12:00:00 AM","Registry_Rate":"11.8445","Rate":1,"Mnemonic":"EUR"}]
""")!
            curr.reload()
            
        }
    }


}

