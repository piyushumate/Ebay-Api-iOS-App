//
//  ProductDetailsViewController.swift
//  Homework9
//
//  Created by usc on 4/9/19.
//  Copyright © 2019 usc. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON

struct products_list_table_cell_contents {
    var item_id : String?
    var name : String?
    var image : String?
    var price : String?
    var currency_symbol : String?
    var shipping : String?
    var shipping_symbol : String?
    var zip : String?
    var condition : String?
    var global_shipping : String?
    var handling_time : String?
}


class products_list_table_cell: UITableViewCell {
    @IBOutlet weak var table_cell_product_image: UIImageView!
    @IBOutlet weak var table_cell_product_name: UILabel!
    @IBOutlet weak var table_cell_shipping_price: UILabel!
    @IBOutlet weak var table_cell_zip_code: UILabel!
    @IBOutlet weak var table_cell_condition: UILabel!
    @IBOutlet weak var table_cell_product_price: UILabel!
    @IBOutlet weak var table_cell_wishlist_button: UIButton!
}


class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var product_list_table: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    var name_list = [String]()
    var image_list = [String]()
    var condition_list = [String]()
    var price_list = [String]()
    var shipping_list = [String]()
    var zip_list = [String]()
    
    var input_query_parameters = [String: Any] ()
    let categories_map: [String: String] = ["All Categories" : "all_categories",
                                            "Art" : "art",
                                            "Baby" : "baby",
                                            "Books" : "books",
                                            "Clothing, Shoes & Accessories" : "clothing",
                                            "Computers/Tablets & Networking" : "computers",
                                            "Health & Beauty" : "health",
                                            "Music" : "music",
                                            "Video Games & Consoles" : "games"]
    
    var product_list_dictionary = Dictionary<String,Any> ()
    var products = [products_list_table_cell_contents]()
    var product_list = [Any]()
    var selected_row = IndexPath()
    var selected_index = Int()
    
    var product_keyword = ""
    var product_category = ""
    var new_condition = ""
    var used_condition = ""
    var unspecified_condition = ""
    var local_pickup = ""
    var free_shipping = ""
    var distance = ""
    var zip_code = ""
    var url = "http://assignment9-env.jmt4k6j8tq.us-east-2.elasticbeanstalk.com/search_multiple_products/"
    
    let http_headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
//    override func viewWillAppear(_ animated: Bool) {
//        print("BACK PRESSED")
//        print(UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist"))
//        tableView.reloadData()
//    }
    
//    override func viewDidLoad() {
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        
//        print("IN PRODUCT DETAILS")
//        print("KEYWORD " + self.product_keyword)
//        print("CATEGORY" + self.product_category)
//        print("NEW" + self.new_condition)
//        print("USED" + self.used_condition)
//        print("UNSPECIFIED" + self.unspecified_condition)
//        print("FREE SHIPPING " + self.free_shipping)
//        print("PICKUP " + self.local_pickup)
//        print("ZIPCODE" + self.zip_code)
//        print("DISTANCE " + self.distance)
        
        if products.count != 0 {
            tableView.reloadData()
            self.tableView.selectRow(at:selected_row, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
        } else {
            var product_condition = [String] ()
            if new_condition == "true" {
                product_condition.append("New")
            }
            
            if used_condition == "true" {
                product_condition.append("Used")
            }
            
            if unspecified_condition == "true" {
                product_condition.append("Unspecified")
            }
            
            var shipping_options = [String: Any]  ()
            if free_shipping == "true" {
                shipping_options["free_shipping"] = "true"
            } else {
                shipping_options["free_shipping"] = "false"
            }
            
            if local_pickup == "true" {
                shipping_options["local_pickup"] = "true"
            } else {
                shipping_options["local_pickup"] = "false"
            }

            let category = categories_map[product_category]!
            input_query_parameters = [
                "product_keyword" : product_keyword,
                "product_category" : category,
                "product_condition" : product_condition,
                "shipping_options" : shipping_options,
                "search_location" : "current_location",
                "zip_code" : zip_code,
                "distance" : distance
            ]
        
            ebay_request{input_list in
                self.product_list_dictionary = input_list}
            
            SwiftSpinner.show(delay: 0.0, title: "Searching...", animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { // Change `4.0` to the desired number of seconds.
    //              print(self.product_list_dictionary)
                if self.product_list_dictionary["data"] != nil {
                    self.product_list = self.product_list_dictionary["data"] as! [Any]
    //                print(self.product_list)
    //               print(self.product_list.count)
                    for item in self.product_list {
                            let product = item as! [String: Any]
                            var temp = products_list_table_cell_contents()
                            temp.item_id = product["Item ID"] as! String
    //                        print(temp.item_id)
                            if temp.item_id == "N/A" {
                                continue
                            }
                        
                            temp.name = product["Name"] as! String
                            if temp.name == "N/A" {
                                continue
                            }
                        
                            if product["Photo"] is Array<String> {
                                let photo = product["Photo"]  as! [String]
                                temp.image = photo[0] as! String
                                if temp.image == "N/A" {
                                    continue
                                }
                            } else {
                                continue
                            }
                        
                            if product["Price"] is Dictionary<String, String> {
                                let price = product["Price"] as! [String: String]
                                temp.price = price["__value__"]
                                temp.currency_symbol = price["@currencyId"]
                                if temp.price == "N/A" || temp.currency_symbol == "N/A"{
                                    continue
                                }
                            } else {
                                continue
                            }
                        
                            let shipping_option = product["Shipping Option"] as! [String: Any]
                            if shipping_option["shippingServiceCost"] != nil {
                                let shipping_cost = shipping_option["shippingServiceCost"] as! [[String: String]]
                                temp.shipping = shipping_cost[0]["__value__"]
                                temp.shipping_symbol = shipping_cost[0]["@currencyId"]
                            } else {
                                temp.shipping = "0.0"
                            }
                        
    //                        print(shipping_option["handlingTime"])
                            if shipping_option["handlingTime"] != nil {
                                let shipping_handling_time = shipping_option["handlingTime"] as! [String]
                                temp.handling_time = shipping_handling_time[0] as! String
                            } else {
                                temp.handling_time = "1"
                            }

                            if shipping_option["shipToLocations"] != nil {
                                let shipping_global = shipping_option["shipToLocations"] as! [String]
                                if shipping_global[0] as! String == "Worldwide" {
                                    temp.global_shipping = "Yes"
                                } else {
                                    temp.global_shipping = "No"
                                }
                            } else {
                                temp.global_shipping = "No"
                            }
                        
                            temp.zip = product["Zip code"] as! String
                            if temp.zip == "N/A" {
                                continue
                            }
                        
                            if product["Condition"] is Dictionary<String, Any> {
                                let condition = product["Condition"] as! [String: Any]
                                let condition_option = condition["conditionId"] as! [String]
                                let condition_id = condition_option[0] as! String
                                if condition_id == "1000" {
                                    temp.condition = "NEW"
                                } else if condition_id == "2000" || condition_id == "2500" {
                                    temp.condition = "REFURBISHED"
                                } else if condition_id == "3000" || condition_id == "4000" || condition_id == "5000" || condition_id == "6000" {
                                    temp.condition = "USED"
                                } else {
                                    temp.condition = "NA"
                                }
                            } else {
                                temp.condition = "NA"
                            }
                            self.products.append(temp)
                        }
    //                    print(self.products)
                        self.tableView.reloadData()
                    } else {
                        var alert : UIAlertView = UIAlertView(title: "No Results!", message: "Failed to fetch search results", delegate: nil, cancelButtonTitle: "Ok")
                        alert.show()
                    }
    //                print(self.products)
                    SwiftSpinner.hide()
                }
        }
    }
    
    func ebay_request(completion: @escaping(_ : Dictionary<String,Any>) -> ())
    {
        Alamofire.request(url, method: .post, parameters: input_query_parameters, encoding:JSONEncoding.default, headers: http_headers).responseJSON { (response:DataResponse<Any>) in
            var result_dictionary = Dictionary<String,Any>()
            switch(response.result) {
                case .success(_):
                    
                    if response.result.value != nil {
                        result_dictionary = response.result.value! as! Dictionary<String,Any>
    //                    print(result_dictionary)
                    }
                    break
                
                case .failure(_):
                    if response.result.error != nil {
                        print(response.result.error!)
                    }
                    break
            }
            completion(result_dictionary)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("IN TABLE VIEW")
//        print(products)
        var currency_symbol = ""
        let cell = tableView.dequeueReusableCell(withIdentifier: "Productlist_Cell", for: indexPath) as! products_list_table_cell
        let product = products[indexPath.row]
        
        cell.table_cell_product_name?.text = product.name
        
        var locale = NSLocale(localeIdentifier: product.currency_symbol!)
        if locale.displayName(forKey: .currencySymbol, value: product.currency_symbol!) == product.currency_symbol! {
            let newlocale = NSLocale(localeIdentifier: product.currency_symbol!.dropLast() + "_en")
            currency_symbol = newlocale.displayName(forKey: .currencySymbol, value: product.currency_symbol!)!
        } else {
            currency_symbol = locale.displayName(forKey: .currencySymbol, value: product.currency_symbol!)!
        }
        cell.table_cell_product_price?.text = (currency_symbol + product.price!)
        
        cell.table_cell_condition?.text = product.condition
        
        if product.shipping != "0.0" {
            locale = NSLocale(localeIdentifier: product.shipping_symbol!)
            if locale.displayName(forKey: .currencySymbol, value: product.shipping_symbol!) == product.shipping_symbol! {
                let newlocale = NSLocale(localeIdentifier: product.shipping_symbol!.dropLast() + "_en")
                currency_symbol = newlocale.displayName(forKey: .currencySymbol, value: product.shipping_symbol!)!
            } else {
                currency_symbol = locale.displayName(forKey: .currencySymbol, value: product.shipping_symbol!)!
            }
            cell.table_cell_shipping_price?.text = (currency_symbol + product.shipping!)
        } else {
            cell.table_cell_shipping_price?.text = "FREE SHIPPING"
        }
        
        cell.table_cell_zip_code?.text = product.zip
        
        let data = try? Data(contentsOf: URL(string: String(product.image!))!)
        if let imageData = data {
            cell.table_cell_product_image?.image = UIImage(data: imageData)
        }
        
        if UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") != nil {
            let wishlist = UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") as! [String: wishlist_table_cell_contents]
            if wishlist[product.item_id!] != nil {
                cell.table_cell_wishlist_button?.setImage(UIImage(named: "wishListFilled"), for: .normal)
            } else {
                cell.table_cell_wishlist_button?.setImage(UIImage(named: "wishListEmpty"), for: .normal)
            }
        } else {
            cell.table_cell_wishlist_button?.setImage(UIImage(named: "wishListEmpty"), for: .normal)
        }
        
        cell.table_cell_wishlist_button?.tag = Int(product.item_id!)!
        cell.table_cell_wishlist_button?.addTarget(self, action:#selector(wish_list_pressed(_:)), for:.touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected_row = indexPath
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "product_details_segue" {
//            print("IN SEGUE")
            self.selected_index = tableView.indexPathForSelectedRow!.row
//            print(self.selected_index)
            let product = products[self.selected_index]
            let dashboardController = segue.destination as! ProductDetailsViewController
            let product_details = dashboardController.viewControllers![0] as! ProductInformation
            product_details.selected_product_id = String(product.item_id!)
            product_details.selected_product_name = String(product.name!)
            product_details.selected_product_image = String(product.image!)
            product_details.price = String(product.price!)
            product_details.currency_symbol = String(product.currency_symbol!)
            product_details.shipping = String(product.shipping!)
            product_details.shipping_symbol = String(product.shipping_symbol!)
            product_details.zip = String(product.zip!)
            product_details.condition = String(product.condition!)
            product_details.global_shipping = String(product.global_shipping!)
            product_details.handling_time = String(product.handling_time!)
        }
    }
    
    func show_toast_message(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/11, y: self.view.frame.size.height - self.view.frame.size.height/8, width: self.view.frame.size.width/1.2, height: 300))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(1)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 1.0)
        toastLabel.text = message
        toastLabel.adjustsFontSizeToFitWidth = true
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 7
        toastLabel.clipsToBounds  =  true
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.numberOfLines = 4
        toastLabel.sizeToFit()
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 8.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    @objc func wish_list_pressed(_ sender: UIButton!) {
        print("IN WISHLIST PRESSED")
        if UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") != nil {
            var wishlist = UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") as! [String: wishlist_table_cell_contents]
            if wishlist.count != 0 {
                print(wishlist[String(sender.tag)])
                if wishlist[String(sender.tag)] != nil {
                    //Remove from wishlist
                    print("IN REMOVE")
                    var message = ""
                    message += wishlist[String(sender.tag)]!.name!
                    wishlist.removeValue(forKey: String(sender.tag))
                    print(wishlist)
                    if wishlist.count == 0 {
                        UserDefaults.standard.removeObject(forKey: "wishlist")
                    } else {
                        UserDefaults.standard.set(object: wishlist, forKey: "wishlist")
                    }
                    message += " was removed from the Wish List"
                    show_toast_message(message: message)
                    sender.setImage(UIImage(named: "wishListEmpty"), for: .normal)
                } else {
                    // Add item to wishlist
                    print("IN ADD")
                    var message = ""
                    var wishlist_cell = wishlist_table_cell_contents()
                    for product in products {
                        if String(sender.tag) == product.item_id {
                            wishlist_cell.item_id = product.item_id
                            wishlist_cell.name = product.name
                            wishlist_cell.image = product.image
                            wishlist_cell.price = product.price
                            wishlist_cell.currency_symbol = product.currency_symbol
                            wishlist_cell.shipping = product.shipping
                            wishlist_cell.shipping_symbol = product.shipping_symbol
                            wishlist_cell.zip = product.zip
                            wishlist_cell.condition = product.condition
                            wishlist_cell.handling_time = product.handling_time
                            wishlist_cell.global_shipping = product.global_shipping
                            
                            message += product.name!
                        }
                    }
    //                print(wishlist_cell)
                    wishlist[String(sender.tag)] = wishlist_cell
                    message += " was added to the Wish List"
                    show_toast_message(message: message)
    //                print(wishlist)
                    UserDefaults.standard.set(object: wishlist, forKey: "wishlist")
                    sender.setImage(UIImage(named: "wishListFilled"), for: .normal)
                }
            } else {
                print("IN ELSE CONDITION")
                //Create wishlist and add in wishlist
                var message = ""
                var wishlist_cell = wishlist_table_cell_contents()
                for product in products {
                    if String(sender.tag) == product.item_id {
                        wishlist_cell.item_id = product.item_id
                        wishlist_cell.name = product.name
                        wishlist_cell.image = product.image
                        wishlist_cell.price = product.price
                        wishlist_cell.currency_symbol = product.currency_symbol
                        wishlist_cell.shipping = product.shipping
                        wishlist_cell.shipping_symbol = product.shipping_symbol
                        wishlist_cell.zip = product.zip
                        wishlist_cell.condition = product.condition
                        wishlist_cell.handling_time = product.handling_time
                        wishlist_cell.global_shipping = product.global_shipping
                        
                        message += product.name!
                    }
                }
                wishlist[String(sender.tag)] = wishlist_cell
                message += " was added to the Wish List"
                show_toast_message(message: message)
                UserDefaults.standard.set(object: wishlist, forKey: "wishlist")
                sender.setImage(UIImage(named: "wishListFilled"), for: .normal)
            }
        } else {
            var message = ""
            var wishlist_cell = wishlist_table_cell_contents()
            for product in products {
                if String(sender.tag) == product.item_id {
                    wishlist_cell.item_id = product.item_id
                    wishlist_cell.name = product.name
                    wishlist_cell.image = product.image
                    wishlist_cell.price = product.price
                    wishlist_cell.currency_symbol = product.currency_symbol
                    wishlist_cell.shipping = product.shipping
                    wishlist_cell.shipping_symbol = product.shipping_symbol
                    wishlist_cell.zip = product.zip
                    wishlist_cell.condition = product.condition
                    wishlist_cell.handling_time = product.handling_time
                    wishlist_cell.global_shipping = product.global_shipping
                    
                    message += product.name!
                }
            }
            var wishlist = [String: wishlist_table_cell_contents]()
            wishlist[String(sender.tag)] = wishlist_cell
            message += " was added to the Wish List"
            show_toast_message(message: message)
            UserDefaults.standard.set(object: wishlist, forKey: "wishlist")
            sender.setImage(UIImage(named: "wishListFilled"), for: .normal)
        }
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


