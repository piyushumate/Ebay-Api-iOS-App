import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

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


class ProductListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var product_list_table: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    var name_list = [String]()
    var image_list = [String]()
    var condition_list = [String]()
    var price_list = [String]()
    var shipping_list = [String]()
    var zip_list = [String]()
    var request_url = "http://csci571homework8-env.crc386dumd.us-east-2.elasticbeanstalk.com/products"
    
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
    
    let http_headers: HTTPHeaders = ["Accept": "application/json"]
    
    func is_continue(field: String?) -> Bool {
        if field == "N/A" {
            return true
        }
        return false
    }
    
    func update_product_condition(product_condition: inout [String], flag: String, condition: String) {
        if (flag == "true") {
            product_condition.append(condition)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        
        
        if 0 == products.count {
            
            var product_condition = [String] ()
            
            update_product_condition(product_condition: &product_condition,
                                     flag: new_condition,
                                     condition: "New")
            update_product_condition(product_condition: &product_condition,
                                     flag: used_condition,
                                     condition: "Used")
            update_product_condition(product_condition: &product_condition,
                                     flag: unspecified_condition,
                                     condition: "Unspecified")
            
            
            var shipping_options = [String: Any]  ()
            shipping_options["FreeShippingOnly"] = free_shipping == "true" ? "true" : "false"
            shipping_options["LocalPickupOnly"]  = local_pickup == "true" ? "true": "false"
            
            
            input_query_parameters = [
                "keyword" : product_keyword,
                "category" : product_category,
                "condition" : product_condition,
                "shipping_options" : shipping_options,
                "zip_code" : zip_code,
                "distance" : distance
            ]
            
            ebay_request{input_list in self.product_list_dictionary = input_list}
            
            SwiftSpinner.show(delay: 0.0, title: "Searching...", animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                if self.product_list_dictionary["data"] != nil {
                    self.product_list = self.product_list_dictionary["data"] as! [Any]
                    for item in self.product_list {
                        let product = item as! [String: Any]
                        //                        var temp = products_list_table_cell_contents()
                        let item_id = product["Item ID"] as! String
                        if self.is_continue(field: item_id) {
                            continue
                        }
                        
                        
                        
                        let name = product["Name"] as! String
                        if self.is_continue(field: name) {
                            continue
                        }
                        
                        let image = product["Photo"]  as! String
                        if self.is_continue(field: image) {
                            continue
                        }
                        
                        let zip = product["zip_code"] as! String
                        if self.is_continue(field: zip) {
                            continue
                        }
                        
                        var price_obj: [String: String]
                        
                        if product["Price"] is Dictionary<String, String> {
                            price_obj = product["Price"] as! [String: String]
                            if self.is_continue(field: price_obj["__value__"]) {
                                continue
                            }
                            
                            if self.is_continue(field: price_obj["@currencyId"]) {
                                continue
                            }
                        } else {
                            continue
                        }
                        
                        var shipping_price: String?
                        var shipping_currency: String?
                        
                        let shipping_option = product["Shipping"] as! [String: Any]
                        if shipping_option["shippingServiceCost"] != nil {
                            let shipping_cost = shipping_option["shippingServiceCost"] as! [[String: String]]
                            shipping_price    = shipping_cost[0]["__value__"]
                            shipping_currency = shipping_cost[0]["@currencyId"]
                        }
                        
                        var handling_time = "1"
                        if shipping_option["handlingTime"] != nil {
                            let shipping_handling_time = shipping_option["handlingTime"] as! [String]
                            handling_time = shipping_handling_time[0] as! String
                        }
                        
                        var global_shipping = "No"
                        if shipping_option["shipToLocations"] != nil {
                            let shipping_global = shipping_option["shipToLocations"] as! [String]
                            if shipping_global[0] as! String == "Worldwide" {
                                global_shipping = "Yes"
                            }
                        }
                        
                        
                        var condition = "NA"
                        if product["Condition"] is Dictionary<String, Any> {
                            let condition_obj = product["Condition"] as! [String: Any]
                            let condition_option = condition_obj["conditionId"] as! [String]
                            let condition_id = condition_option[0] as! String
                            if condition_id == "1000" {
                                condition = "NEW"
                            } else if condition_id == "2000" || condition_id == "2500" {
                                condition = "REFURBISHED"
                            } else if condition_id == "3000" || condition_id == "4000" || condition_id == "5000" || condition_id == "6000" {
                                condition = "USED"
                            }
                        }
                        
                        
                        self.products.append(products_list_table_cell_contents(
                            item_id: item_id,
                            name   : name,
                            image  : image,
                            price  : price_obj["__value__"],
                            currency_symbol: price_obj["@currencyId"],
                            shipping: shipping_price,
                            shipping_symbol: shipping_currency,
                            zip    : zip,
                            condition: condition,
                            global_shipping: global_shipping,
                            handling_time: handling_time
                        ))
                        
                    }
                    self.tableView.reloadData()
                } else {
                    var alert : UIAlertView = UIAlertView(
                        title: "No Results!",
                        message: "Failed to fetch search results",
                        delegate: nil,
                        cancelButtonTitle: "Ok")
                    alert.show()
                }
                SwiftSpinner.hide()
            }
        } else {
            tableView.reloadData()
            self.tableView.selectRow(at:selected_row, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
        }
    }
    
    func ebay_request(completion: @escaping(_ : Dictionary<String,Any>) -> ())
    {
        Alamofire.request(request_url, method: .post, parameters: input_query_parameters, encoding:JSONEncoding.default, headers: http_headers).responseJSON { (response:DataResponse<Any>) in
            var result = Dictionary<String,Any>()
            switch(response.result) {
            case .failure(_):
                if response.result.error != nil {
                    print(response.result.error!)
                }
                break
                
            case .success(_):
                
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
        switch segue.identifier {
        case "product_details_segue":
            let product = products[tableView.indexPathForSelectedRow!.row]
            let dashboardController = segue.destination as! ProductDetailsViewController
            let prod_details = dashboardController.viewControllers![0] as! ProductInformation
            prod_details.selected_product_id = String(product.item_id!)
            prod_details.selected_product_name = String(product.name!)
            prod_details.selected_product_image = String(product.image!)
            prod_details.price = String(product.price!)
            prod_details.currency_symbol = String(product.currency_symbol!)
            prod_details.shipping = String(product.shipping!)
            prod_details.shipping_symbol = String(product.shipping_symbol!)
            prod_details.zip = String(product.zip!)
            prod_details.condition = String(product.condition!)
            prod_details.global_shipping = String(product.global_shipping!)
            prod_details.handling_time = String(product.handling_time!)
            break
            
        default:
            break
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
        if UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") != nil {
            var wishlist = UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") as! [String: wishlist_table_cell_contents]
            if wishlist.count != 0 {
                if wishlist[String(sender.tag)] != nil {
                    //Remove from wishlist
                    var message = ""
                    message += wishlist[String(sender.tag)]!.name!
                    wishlist.removeValue(forKey: String(sender.tag))
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
}


