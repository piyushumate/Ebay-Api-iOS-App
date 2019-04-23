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
 
    var product_keyword = ""
    var product_category = ""
    var new_condition = ""
    var used_condition = ""
    var unspecified_condition = ""
    var local_pickup = ""
    var free_shipping = ""
    var distance = ""
    var zip_code = ""
    
    
    var request_url    = "http://csci571homework8-env.crc386dumd.us-east-2.elasticbeanstalk.com/products"
    
    
    var product_list_dictionary = Dictionary<String,Any> ()
    var products = [products_list_table_cell_contents]()
    var product_list = [Any]()
    
    var selected_index = Int()
    
    let http_headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        

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
        shipping_options["FreeShippingOnly"] = free_shipping == "true" ? "true" : "false"
        shipping_options["LocalPickupOnly"]  = local_pickup == "true" ? "true": "false"
        
        
       
        input_query_parameters = [
            "keyword" : product_keyword,
            "category" : product_category,
            "condition" : product_condition,
            "shipping_options" : shipping_options,
            "search_location" : "current_location"
        ]
        
        ebay_request{ input_list in self.product_list_dictionary = input_list}
        
        SwiftSpinner.show(delay: 1.0, title: "Searching...", animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if self.product_list_dictionary["data"] != nil {
                self.product_list = self.product_list_dictionary["data"] as! [Any]
//                print(self.product_list)
//               print(self.product_list.count)
                for item in self.product_list {
                        let product = item as! [String: Any]
                        var temp = products_list_table_cell_contents()
                        temp.item_id = product["Item ID"] as! String
//                        print(temp.item_id)
                    
                        temp.name = product["Name"] as! String
                    
                        let photo = product["Photo"]  as! [String]
                        temp.image = photo[0] as! String
                    
                        let price = product["Price"] as! [String: String]
                        temp.price = price["__value__"]
                        temp.currency_symbol = price["@currencyId"]
                    
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
    
    func ebay_request(completion: @escaping(_ : Dictionary<String,Any>) -> ())
    {
        print(input_query_parameters)
        Alamofire.request(request_url, method: .post, parameters: input_query_parameters,
                          encoding:JSONEncoding.default, headers: http_headers).responseJSON {
                            (response:DataResponse<Any>) in
            var result = Dictionary<String,Any>()
            
            switch(response.result) {
                case .failure(_):
                    if response.result.error != nil {
                        //log error
                        print(response.result.error!)
                    }
                break
                case .success(_):
                    print(response.result.value)
                    if response.result.value != nil {
                        result = response.result.value! as! Dictionary<String,Any>
                    }
                break
                
            }
            completion(result)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! products_list_table_cell
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
        return cell
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
            product_details.handling_time = String(product.handling_time!)
            product_details.global_shipping = String(product.global_shipping!)
            product_details.shipping = String(product.shipping!)
            product_details.shipping_symbol = String(product.shipping_symbol!)
        }
    }
    
    func show_toast_message(message : String) {
        let toastLabel = UILabel()
        toastLabel.frame = CGRect(
            x: self.view.frame.size.width/2 - 100,
            y: self.view.frame.size.height - 100,
            width: 200,
            height: 35)
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
}

