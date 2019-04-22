//
//  ProductShippingInformation.swift
//  Homework9
//
//  Created by usc on 4/14/19.
//  Copyright © 2019 usc. All rights reserved.
//

import UIKit
import SwiftSpinner

class custom_header_cell: UITableViewCell{
    @IBOutlet var header_label: UILabel!
    @IBOutlet var header_image: UIImageView!
}


class custom_information_cell: UITableViewCell{
    @IBOutlet var information_type_label: UILabel!
    @IBOutlet var information_data_label: UITextView!
}

class ProductShippingInformation: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var shipping_info_dictionary = [String: Any]()
    
    var tableData = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.shipping_info_dictionary)

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        self.view.addSubview(tableView)
//        ["HandlingTime": "1", "UserID": ryans_games, "ShippingCostPaidBy": Seller, "TopRatedSeller": 1, "ShippingCostSymbol": "USD", "StoreURL": "https://stores.ebay.com/id=52047988", "FeedbackScore": 23360, "StoreName": "Ryan&#39;s Games In Hawaii", "PositiveFeedbackPercent": 100, "GlobalShipping": "Yes", "ShippingCost": "0.0", "ReturnsAccepted": Returns Accepted, "Refund": Money back or replacement (buyer's choice), "FeedbackRatingStar": YellowShooting, "Return_Policy_(US)": Returns Accepted within 30 Days]
        
        if self.shipping_info_dictionary["StoreName"] != nil ||
            self.shipping_info_dictionary["FeedbackScore"] != nil ||
            self.shipping_info_dictionary["FeedbackRatingStar"] != nil ||
            self.shipping_info_dictionary["PositiveFeedbackPercent"] != nil {
            
            var seller_dictionary = [String: String]()
            self.tableData.append("Seller")
            
            if self.shipping_info_dictionary["StoreName"] != nil &&
                self.shipping_info_dictionary["StoreURL"] != nil {
                seller_dictionary["Store Name"] = self.shipping_info_dictionary["StoreName"] as! String
                seller_dictionary["StoreURL"] = self.shipping_info_dictionary["StoreURL"] as! String
            }
            
            if self.shipping_info_dictionary["FeedbackScore"] != nil {
                seller_dictionary["Feedback Score"] = String(format: "%@", self.shipping_info_dictionary["FeedbackScore"] as! CVarArg)
            }
            
            if self.shipping_info_dictionary["PositiveFeedbackPercent"] != nil {
                seller_dictionary["Popularity"] = String(format: "%@", self.shipping_info_dictionary["PositiveFeedbackPercent"] as! CVarArg)
            }
            
            if self.shipping_info_dictionary["FeedbackRatingStar"] != nil {
                seller_dictionary["Feedback Star"] = self.shipping_info_dictionary["FeedbackRatingStar"] as! String
            }
            
            self.tableData.append(seller_dictionary)
        }
        
        if self.shipping_info_dictionary["ShippingCost"] != nil ||
            self.shipping_info_dictionary["GlobalShipping"] != nil ||
            self.shipping_info_dictionary["HandlingTime"] != nil {
            
            var shipping_dictionary = [String: String]()
            self.tableData.append("Shipping Info")
            
            if self.shipping_info_dictionary["ShippingCost"] != nil &&
                self.shipping_info_dictionary["ShippingCostSymbol"] != nil {
                shipping_dictionary["Shipping Cost"] = self.shipping_info_dictionary["ShippingCost"] as! String
                shipping_dictionary["ShippingCostSymbol"] = self.shipping_info_dictionary["ShippingCostSymbol"] as! String
            }
            
            if self.shipping_info_dictionary["GlobalShipping"] != nil {
                shipping_dictionary["Global Shipping"] = self.shipping_info_dictionary["GlobalShipping"] as! String
            }
            
            if self.shipping_info_dictionary["HandlingTime"] != nil {
                shipping_dictionary["Handling Time"] = self.shipping_info_dictionary["HandlingTime"] as! String
            }
            
            self.tableData.append(shipping_dictionary)
        }
        
        if self.shipping_info_dictionary["ReturnsAccepted"] != nil ||
            self.shipping_info_dictionary["Refund"] != nil ||
            self.shipping_info_dictionary["Return_Policy_(US)"] != nil ||
            self.shipping_info_dictionary["ShippingCostPaidBy"] != nil {
            
            var returns_dictionary = [String: String]()
            self.tableData.append("Return Policy")
            
            if self.shipping_info_dictionary["ReturnsAccepted"] != nil {
                returns_dictionary["Policy"] = self.shipping_info_dictionary["ReturnsAccepted"] as! String
            }
        
            if self.shipping_info_dictionary["Refund"] != nil {
                returns_dictionary["Refund Mode"] = self.shipping_info_dictionary["Refund"] as! String
            }
        
            if self.shipping_info_dictionary["Return_Policy_(US)"] != nil {
                returns_dictionary["Return Within"] = self.shipping_info_dictionary["Return_Policy_(US)"] as! String
            }
        
            if self.shipping_info_dictionary["ShippingCostPaidBy"] != nil {
                returns_dictionary["Shipping Cost Paid By"] = self.shipping_info_dictionary["ShippingCostPaidBy"] as! String
            }
            
            self.tableData.append(returns_dictionary)
        }
        
        SwiftSpinner.show(delay: 1.0, title: "Fetching Shipping Data...", animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.tableView.reloadData()
            SwiftSpinner.hide()
        }
        print(tableData)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let string = self.tableData[indexPath.row] as? String {
            let cell:custom_header_cell = self.tableView.dequeueReusableCell(withIdentifier: "custom_header_cell") as! custom_header_cell

            cell.header_label?.text = string
            cell.header_image?.image = UIImage(named: string)
            
            return cell
        }

        else if var dictionary = self.tableData[indexPath.row] as? [String: String] {

            let cell:custom_information_cell = self.tableView.dequeueReusableCell(withIdentifier: "custom_information_cell") as! custom_information_cell
            
            var information_type = NSMutableAttributedString()
            var information_data = NSMutableAttributedString()
            
            for current in dictionary {
                if current.key == "StoreURL" ||
                    current.key == "ShippingCostSymbol" {
                    continue
                } else if current.key == "Shipping Cost" {
                    if current.value == "0.0" {
                        information_data.append(NSMutableAttributedString(string: "FREE"))
                    } else {
                        var locale = NSLocale(localeIdentifier: dictionary["ShippingCostSymbol"]!)
                        var currency_symbol = ""
                        if locale.displayName(forKey: .currencySymbol, value: dictionary["ShippingCostSymbol"]!) == dictionary["ShippingCostSymbol"]! {
                            let newlocale = NSLocale(localeIdentifier: dictionary["ShippingCostSymbol"]!.dropLast() + "_en")
                            currency_symbol = newlocale.displayName(forKey: .currencySymbol, value: dictionary["ShippingCostSymbol"]!)!
                        }
                        else {
                            currency_symbol = locale.displayName(forKey: .currencySymbol, value: dictionary["ShippingCostSymbol"]!)!
                        }
                        var shipping_price_string = currency_symbol
                        shipping_price_string += current.value
                        information_data.append(NSMutableAttributedString(string: shipping_price_string))
                    }
                } else if current.key == "Store Name" {
                    var store_name = current.value
                    if store_name.count > 15 {
                        let upperBound = store_name.index(store_name.startIndex, offsetBy: 15)
                        store_name = String(store_name[...upperBound])
                    }
                    information_data.append(NSMutableAttributedString(string: store_name,
                                                                     attributes:[NSAttributedString.Key.link:
                                                                        URL(string: String(dictionary["StoreURL"]!))!]))
                } else if current.key == "Return Within" {
                    if let range = current.value.range(of: "within ") {
                        let returns_within = current.value[range.upperBound...]
                        information_data.append(NSMutableAttributedString(string: String(returns_within)))
                    }
                } else if current.key == "Popularity" {
                    let sentence = current.value as! String
                    if sentence.count > 4 {
                        let upperBound = sentence.index(sentence.startIndex, offsetBy: 4)
                        let mySubstring = sentence[...upperBound]
                        information_data.append(NSMutableAttributedString(string: String(mySubstring)))
                    }
                    else {
                        information_data.append(NSMutableAttributedString(string: sentence))
                    }
                }  else if current.key == "Feedback Star" {
                    let sentence = current.value as! String
                    if sentence.contains("Shooting") {
                        let newString = sentence.replacingOccurrences(of: "Shooting", with: "")
                        let star_icon = UIImage(named: "star")
                        let attachment = NSTextAttachment()
                        if UIColor(name: String(newString.lowercased())) != nil {
                            attachment.image = star_icon?.maskWithColor(color: UIColor(name: String(newString.lowercased()))!)
                            information_data.append(NSAttributedString(attachment: attachment))
                        } else {
                            attachment.image = star_icon?.maskWithColor(color: UIColor(name: "red")!)
                            information_data.append(NSAttributedString(attachment: attachment))
                        }
                    } else {
                        let star_icon = UIImage(named: "starBorder")
                        let attachment = NSTextAttachment()
                        if UIColor(name: String(sentence.lowercased())) != nil {
                            attachment.image = star_icon?.maskWithColor(color: UIColor(name: String(sentence.lowercased()))!)
                            information_data.append(NSAttributedString(attachment: attachment))
                        } else {
                            attachment.image = star_icon?.maskWithColor(color: UIColor(name: "red")!)
                            information_data.append(NSAttributedString(attachment: attachment))
                        }
                    }
                } else {
                    let sentence = current.value as! String
                    let query = " "
                    var searchRange = sentence.startIndex..<sentence.endIndex
                    var indexes: [String.Index] = []
                    
                    while let range = sentence.range(of: query, options: .caseInsensitive, range: searchRange) {
                        searchRange = range.upperBound..<searchRange.upperBound
                        indexes.append(range.lowerBound)
                    }
                    
                    if indexes.count > 1 {
                        let index = indexes[1]
                        let mySubstring = sentence[...index]
                        information_data.append(NSMutableAttributedString(string: String(mySubstring)))
                    }
                    else {
                        information_data.append(NSMutableAttributedString(string: sentence))
                        if current.key == "Handling Time" {
                            information_data.append(NSMutableAttributedString(string: " day"))
                        }
                    }
                }
                
                information_type.append(NSMutableAttributedString(string: current.key))
                information_type.append(NSMutableAttributedString(string: "\n"))
                information_data.append(NSMutableAttributedString(string: "\n"))
            }
            information_type.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)],
                                           range: NSRange(location: 0, length: information_type.length))
            cell.information_type_label?.attributedText = information_type
            cell.information_type_label?.textColor = UIColor.darkGray
            cell.information_type_label?.textAlignment = .center
            information_data.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)],
                                           range: NSRange(location: 0, length: information_data.length))
            cell.information_data_label?.attributedText = information_data
            cell.information_data_label?.isEditable = false
            cell.information_data_label?.textColor = UIColor.darkGray
            cell.information_data_label?.textAlignment = .center
            cell.information_data_label?.dataDetectorTypes = UIDataDetectorTypes.all
            return cell
        }

        return UITableViewCell()

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    public convenience init?(name: String) {
        let allColors = [
            "aqua": "#00FFFFFF",
            "black": "#000000FF",
            "blue": "#0000FFFF",
            "brown": "#A52A2AFF",
            "coral": "#FF7F50FF",
            "crimson": "#DC143CFF",
            "cyan": "#00FFFFFF",
            "gold": "#FFD700FF",
            "gray": "#808080FF",
            "grey": "#808080FF",
            "green": "#008000FF",
            "indigo": "#4B0082FF",
            "lavender": "#E6E6FAFF",
            "lime": "#00FF00FF",
            "linen": "#FAF0E6FF",
            "magenta": "#FF00FFFF",
            "maroon": "#800000FF",
            "mintcream": "#F5FFFAFF",
            "mistyrose": "#FFE4E1FF",
            "moccasin": "#FFE4B5FF",
            "navy": "#000080FF",
            "oldlace": "#FDF5E6FF",
            "olive": "#808000FF",
            "orange": "#FFA500FF",
            "orchid": "#DA70D6FF",
            "pink": "#FFC0CBFF",
            "purple": "#800080FF",
            "red": "#FF0000FF",
            "salmon": "#FA8072FF",
            "sienna": "#A0522DFF",
            "silver": "#C0C0C0FF",
            "snow": "#FFFAFAFF",
            "tan": "#D2B48CFF",
            "teal": "#008080FF",
            "thistle": "#D8BFD8FF",
            "tomato": "#FF6347FF",
            "turquoise": "#40E0D0FF",
            "violet": "#EE82EEFF",
            "wheat": "#F5DEB3FF",
            "white": "#FFFFFFFF",
            "yellow": "#FFFF00FF"
        ]
        
        let cleanedName = name.replacingOccurrences(of: " ", with: "").lowercased()
        
        if let hexString = allColors[cleanedName] {
            self.init(hexString: hexString)
        } else {
            return nil
        }
    }
}

