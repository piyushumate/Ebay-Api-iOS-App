//
//  ProductInformation.swift
//  Homework9
//
//  Created by usc on 4/14/19.
//  Copyright © 2019 usc. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON
import Toast_Swift

class product_info_table_cell: UITableViewCell {
    @IBOutlet weak var product_property: UILabel!
    @IBOutlet weak var product_property_info: UILabel!
}


class ProductInformation: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var required_product_info = [String: Any]()
    var shipping_info_dictionary = [String: Any]()
    var product_photos = [String]()
    var sorted_keys = [String]()
    
    @IBOutlet weak var scroll_view: UIScrollView!
    @IBOutlet weak var page_control: UIPageControl!
    @IBOutlet weak var product_name: UILabel!
    @IBOutlet weak var product_price: UILabel!
    @IBOutlet weak var tableView: UITableView!


    
    var selected_product_id = ""
    var selected_product_name = ""
    var selected_product_image = ""
    var price = ""
    var currency_symbol = ""
    var shipping = ""
    var shipping_symbol = ""
    var zip = ""
    var condition = ""
    var global_shipping = ""
    var handling_time = "1"
    
    var item_url = ""
    var selected_product_price = ""
    
    var product_info_dictionary = Dictionary<String,Any> ()
    
    
    var url = "http://csci571homework8-env.crc386dumd.us-east-2.elasticbeanstalk.com/product/"
//
    
    let http_headers: HTTPHeaders = ["Accept": "application/json"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        scroll_view.delegate = self
        self.view.addSubview(tableView)
    
        let facebook_button = UIButton.init(type: .custom)
        facebook_button.setImage(UIImage.init(named: "facebook")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
        facebook_button.addTarget(self, action:#selector(facebook_share), for:.touchUpInside)
        facebook_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let facebook_bar_button = UIBarButtonItem.init(customView: facebook_button)
        
        if UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") != nil {
            var wishlist = UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") as! [String: wishlist_table_cell_contents]
            if wishlist.count != 0 {
                 if wishlist[self.selected_product_id] != nil {
                    let wish_list_button = UIButton.init(type: .custom)
                    wish_list_button.setImage(UIImage.init(named: "wishListFilled")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
                    wish_list_button.addTarget(self, action:#selector(wish_list), for:.touchUpInside)
                    wish_list_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
                    let wish_list_bar_button = UIBarButtonItem.init(customView: wish_list_button)
                    self.tabBarController?.navigationItem.rightBarButtonItems = [wish_list_bar_button, facebook_bar_button]
                } else {
                    let wish_list_button = UIButton.init(type: .custom)
                    wish_list_button.setImage(UIImage.init(named: "wishListEmpty")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
                    wish_list_button.addTarget(self, action:#selector(wish_list), for:.touchUpInside)
                    wish_list_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
                    let wish_list_bar_button = UIBarButtonItem.init(customView: wish_list_button)
                    self.tabBarController?.navigationItem.rightBarButtonItems = [wish_list_bar_button, facebook_bar_button]
                }
            } else {
                let wish_list_button = UIButton.init(type: .custom)
                wish_list_button.setImage(UIImage.init(named: "wishListEmpty")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
                wish_list_button.addTarget(self, action:#selector(wish_list), for:.touchUpInside)
                wish_list_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
                let wish_list_bar_button = UIBarButtonItem.init(customView: wish_list_button)
                self.tabBarController?.navigationItem.rightBarButtonItems = [wish_list_bar_button, facebook_bar_button]
            }
        }  else {
            let wish_list_button = UIButton.init(type: .custom)
            wish_list_button.setImage(UIImage.init(named: "wishListEmpty")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
            wish_list_button.addTarget(self, action:#selector(wish_list), for:.touchUpInside)
            wish_list_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
            let wish_list_bar_button = UIBarButtonItem.init(customView: wish_list_button)
            self.tabBarController?.navigationItem.rightBarButtonItems = [wish_list_bar_button, facebook_bar_button]
        }

        ebay_request {product_information in
            self.product_info_dictionary = product_information}
        
        SwiftSpinner.show(delay: 0.0, title: "Fetching Product Details...", animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { // Change `4.0` to the desired number of seconds.

            if self.product_info_dictionary["data"] != nil {
                self.required_product_info = self.product_info_dictionary["data"] as! [String: Any]
                
                if self.required_product_info["Seller"] != nil {
                    self.shipping_info_dictionary = self.required_product_info["Seller"] as! [String: Any]
                    self.required_product_info.removeValue(forKey: "Seller")
                }
                
                if self.required_product_info["Storefront"] != nil {
                    let storefront_dictionary = self.required_product_info["Storefront"] as! [String: String]
                    if storefront_dictionary["StoreName"] != nil {
                        self.shipping_info_dictionary["StoreName"] = storefront_dictionary["StoreName"]
                    }
                    
                    if storefront_dictionary["StoreURL"] != nil {
                        self.shipping_info_dictionary["StoreURL"] = storefront_dictionary["StoreURL"]
                    }
                    self.required_product_info.removeValue(forKey: "Storefront")
                }
                
                self.shipping_info_dictionary["ShippingCost"] = self.shipping
                self.shipping_info_dictionary["ShippingCostSymbol"] = self.shipping_symbol
                self.shipping_info_dictionary["HandlingTime"] = self.handling_time
                self.shipping_info_dictionary["GlobalShipping"] = self.global_shipping
                
                if self.required_product_info["Return_Policy_(US)"] != nil {
                    self.shipping_info_dictionary["Return_Policy_(US)"] = self.required_product_info["Return_Policy_(US)"]
                    self.required_product_info.removeValue(forKey: "Return_Policy_(US)")
                }
                
                if self.required_product_info["Returns_Accepted"] != nil {
                    self.shipping_info_dictionary["ReturnsAccepted"] = self.required_product_info["Returns_Accepted"]
                    self.required_product_info.removeValue(forKey: "Returns_Accepted")
                }
                
                if self.required_product_info["Refund"] != nil {
                    self.shipping_info_dictionary["Refund"] = self.required_product_info["Refund"]
                    self.required_product_info.removeValue(forKey: "Refund")
                }
                
                if self.required_product_info["ShippingCostPaidBy"] != nil {
                    self.shipping_info_dictionary["ShippingCostPaidBy"] = self.required_product_info["ShippingCostPaidBy"]
                    self.required_product_info.removeValue(forKey: "ShippingCostPaidBy")
                }
            
                
                // Photos
                print(self.required_product_info)
                if self.required_product_info["Product Images"] != nil {
                    self.product_photos = self.required_product_info["Product Images"] as! [String]
                    self.required_product_info.removeValue(forKey: "Product Images")
                }
                
                self.page_control.numberOfPages = self.product_photos.count
                self.page_control.currentPage = 0
                self.view.bringSubviewToFront(self.page_control)
                
                for index in 0 ..< self.product_photos.count {
                    let imageUrl:URL = URL(string: self.product_photos[index])!
                    // Start background thread so that image loading does not make app unresponsive
                    DispatchQueue.global(qos: .background).async {
                        let imageData:NSData = NSData(contentsOf: imageUrl)!
                        let myImageView = UIImageView(frame: CGRect(x: self.scroll_view.frame.width * CGFloat(index),
                                                                    y: 0,
                                                                    width: self.scroll_view.frame.width,
                                                                    height: self.scroll_view.frame.width))
                        let image = UIImage(data: imageData as Data)
                        myImageView.image = image
                        // When from background thread, UI needs to be updated on main_queue
                        DispatchQueue.main.async {
                            self.scroll_view.addSubview(myImageView)
                            self.scroll_view.contentSize = CGSize(width:self.scroll_view.frame.width *
                                                                    CGFloat(self.product_photos.count),
                                                                  height:self.scroll_view.frame.height)
                            self.scroll_view.isPagingEnabled = true
                        }
                    }
                }
                
                
                // Product Title
                if self.required_product_info["Title"] != nil {
                    self.selected_product_name = self.required_product_info["Title"] as! String
                    self.product_name.text = self.required_product_info["Title"] as! String
                    self.required_product_info.removeValue(forKey: "Title")
                }
                               
                // Product Price
                print(self.required_product_info["Price"])
                if self.required_product_info["Price"] != nil {
                    var currency_symbol = ""
                    let price_dictionary = self.required_product_info["Price"] as! [String: Any]
                    let product_price = String(describing: price_dictionary["__value__"]!)
                    let symbol = String(describing: price_dictionary["@currencyId"]!)
                    var locale = NSLocale(localeIdentifier: symbol)
                    if locale.displayName(forKey: .currencySymbol, value: symbol) == symbol {
                        let newlocale = NSLocale(localeIdentifier: symbol.dropLast() + "_en")
                        currency_symbol = newlocale.displayName(forKey: .currencySymbol, value: symbol)!
                    } else {
                        currency_symbol = locale.displayName(forKey: .currencySymbol, value: symbol)!
                    }
                    self.product_price?.text = (currency_symbol + product_price)
                    self.selected_product_price = (currency_symbol + product_price)
                    self.required_product_info.removeValue(forKey: "Price")
                }
                
                if self.required_product_info["item_url"] != nil {
                    self.item_url = self.required_product_info["item_url"] as! String
                    self.required_product_info.removeValue(forKey: "item_url")
                }
                
//                print(self.product_photos)
//                print(self.required_product_info)
                
                // Sorting required product information dictionary
                let sorted_dictionary = self.required_product_info.sorted { $0.key < $1.key }
                self.sorted_keys = Array(sorted_dictionary.map({ $0.key }))
                
                self.tableView.reloadData()
                
                // Passing data to other tabs
                let product_information_tab = self.tabBarController?.viewControllers![0] as! ProductInformation
                product_information_tab.required_product_info = self.required_product_info
                product_information_tab.selected_product_id = self.selected_product_id
                product_information_tab.selected_product_name = self.selected_product_name
                product_information_tab.selected_product_image = self.selected_product_image
                product_information_tab.price = self.price
                product_information_tab.currency_symbol = self.currency_symbol
                product_information_tab.shipping = self.shipping
                product_information_tab.shipping_symbol = self.shipping_symbol
                product_information_tab.zip = self.zip
                product_information_tab.condition = self.condition
                product_information_tab.global_shipping = self.global_shipping
                product_information_tab.handling_time = self.handling_time
                product_information_tab.item_url = self.item_url
                product_information_tab.selected_product_price = self.selected_product_price
                
                let product_shipping_tab = self.tabBarController?.viewControllers![1] as! ProductShippingInformation
                product_shipping_tab.shipping_info_dictionary = self.shipping_info_dictionary
                product_shipping_tab.selected_product_id = self.selected_product_id
                product_shipping_tab.selected_product_name = self.selected_product_name
                product_shipping_tab.selected_product_image = self.selected_product_image
                product_shipping_tab.price = self.price
                product_shipping_tab.currency_symbol = self.currency_symbol
                product_shipping_tab.shipping = self.shipping
                product_shipping_tab.shipping_symbol = self.shipping_symbol
                product_shipping_tab.zip = self.zip
                product_shipping_tab.condition = self.condition
                product_shipping_tab.global_shipping = self.global_shipping
                product_shipping_tab.handling_time = self.handling_time
                product_shipping_tab.item_url = self.item_url
                product_shipping_tab.selected_product_price = self.selected_product_price
                
                let product_photos_tab = self.tabBarController?.viewControllers![2] as! GoogleProductPhotosController
                product_photos_tab.selected_product_id = self.selected_product_id
                product_photos_tab.selected_product_name = self.selected_product_name
                product_photos_tab.selected_product_image = self.selected_product_image
                product_photos_tab.price = self.price
                product_photos_tab.currency_symbol = self.currency_symbol
                product_photos_tab.shipping = self.shipping
                product_photos_tab.shipping_symbol = self.shipping_symbol
                product_photos_tab.zip = self.zip
                product_photos_tab.condition = self.condition
                product_photos_tab.global_shipping = self.global_shipping
                product_photos_tab.handling_time = self.handling_time
                product_photos_tab.item_url = self.item_url
                product_photos_tab.selected_product_price = self.selected_product_price
                
                let similar_items_tab = self.tabBarController?.viewControllers![3] as! SimilarItems
                similar_items_tab.selected_product_id = self.selected_product_id
                similar_items_tab.selected_product_name = self.selected_product_name
                similar_items_tab.selected_product_image = self.selected_product_image
                similar_items_tab.price = self.price
                similar_items_tab.currency_symbol = self.currency_symbol
                similar_items_tab.shipping = self.shipping
                similar_items_tab.shipping_symbol = self.shipping_symbol
                similar_items_tab.zip = self.zip
                similar_items_tab.condition = self.condition
                similar_items_tab.global_shipping = self.global_shipping
                similar_items_tab.handling_time = self.handling_time
                similar_items_tab.item_url = self.item_url
                similar_items_tab.selected_product_price = self.selected_product_price
                
            } else {
                var alert : UIAlertView = UIAlertView(
                    title: "No Product Details!",
                    message: "Failed to fetch search results",
                    delegate: nil,
                    cancelButtonTitle: "Ok")
                alert.show()
            }
            SwiftSpinner.hide()
        }
    }
    
    func show_toast_message(message : String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom, style: ToastStyle())
    }
    
    func ebay_request(completion: @escaping(_ : Dictionary<String,Any>) -> ())
    {
        url += self.selected_product_id
        Alamofire.request(url, method: .get, encoding:JSONEncoding.default, headers: http_headers).responseJSON { (response:DataResponse<Any>) in
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
        return required_product_info.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! product_info_table_cell
        let key = self.sorted_keys[indexPath.row]
        cell.product_property?.text = key
        cell.product_property_info?.text = String(describing: self.required_product_info[key]!)
        return cell
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
//        print(pageIndex)
        self.page_control.currentPage = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
    }
    
    @objc func facebook_share(sender: UIBarButtonItem!) {
        var search_url = "https://www.facebook.com/dialog/share?app_id=867509633598269&display=popup&href="
        
        search_url = [search_url, self.item_url, "&quote="].joined(separator: "")
        
        var message = [
            "Buy",
            self.selected_product_name,
            "at",
            self.selected_product_price,
            "from Ebay!"].joined(separator: " ")
        
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.remove(charactersIn: "?&=#")
        message = String(message).addingPercentEncoding(withAllowedCharacters: characterSet)!
        search_url.append(String(message))
        let hashtag = "#CSCI571Spring2019Ebay".addingPercentEncoding(withAllowedCharacters: characterSet)!
        search_url.append("&hashtag="+hashtag)
        guard let url = URL(string: String(search_url)) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func wish_list(sender: UIBarButtonItem!) {
        if UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") != nil {
            var wishlist = UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") as! [String: wishlist_table_cell_contents]
            if wishlist.count != 0 {
//                print(wishlist[String(sender.tag)])
                if wishlist[self.selected_product_id] != nil {
                    //Remove from wishlist
                    var message = ""
                    message += wishlist[self.selected_product_id]!.name!
                    message += " was removed from the Wish List"
                    show_toast_message(message: message)
                    
                    wishlist.removeValue(forKey: self.selected_product_id)
                    if wishlist.count == 0 {
                        UserDefaults.standard.removeObject(forKey: "wishlist")
                    } else {
                        UserDefaults.standard.set(object: wishlist, forKey: "wishlist")
                    }
                    let facebook_button = UIButton.init(type: .custom)
                    facebook_button.setImage(UIImage.init(named: "facebook")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
                    facebook_button.addTarget(self, action:#selector(facebook_share), for:.touchUpInside)
                    facebook_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
                    let facebook_bar_button = UIBarButtonItem.init(customView: facebook_button)
                    
                    let wish_list_button = UIButton.init(type: .custom)
                    wish_list_button.setImage(UIImage.init(named: "wishListEmpty")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
                    wish_list_button.addTarget(self, action:#selector(wish_list), for:.touchUpInside)
                    wish_list_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
                    let wish_list_bar_button = UIBarButtonItem.init(customView: wish_list_button)
                    self.tabBarController?.navigationItem.rightBarButtonItems = [wish_list_bar_button, facebook_bar_button]
                } else {
                    // Add item to wishlist
                    var message = ""
                    var wishlist_cell = wishlist_table_cell_contents()
                    wishlist_cell.item_id = self.selected_product_id
                    wishlist_cell.name = self.selected_product_name
                    wishlist_cell.image = self.selected_product_image
                    wishlist_cell.price = self.price
                    wishlist_cell.currency_symbol = self.currency_symbol
                    wishlist_cell.shipping = self.shipping
                    wishlist_cell.shipping_symbol = self.shipping_symbol
                    wishlist_cell.zip = self.zip
                    wishlist_cell.condition = self.condition
                    wishlist_cell.handling_time = self.handling_time
                    wishlist_cell.global_shipping = self.global_shipping
                    //                print(wishlist_cell)
                    wishlist[self.selected_product_id] = wishlist_cell
                    //                print(wishlist)
                    
                    message += self.selected_product_name
                    message += " was added to the Wish List"
                    show_toast_message(message: message)
                    
                    UserDefaults.standard.set(object: wishlist, forKey: "wishlist")
                    let facebook_button = UIButton.init(type: .custom)
                    facebook_button.setImage(UIImage.init(named: "facebook")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
                    facebook_button.addTarget(self, action:#selector(facebook_share), for:.touchUpInside)
                    facebook_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
                    let facebook_bar_button = UIBarButtonItem.init(customView: facebook_button)
                    
                    let wish_list_button = UIButton.init(type: .custom)
                    wish_list_button.setImage(UIImage.init(named: "wishListFilled")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
                    wish_list_button.addTarget(self, action:#selector(wish_list), for:.touchUpInside)
                    wish_list_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
                    let wish_list_bar_button = UIBarButtonItem.init(customView: wish_list_button)
                    self.tabBarController?.navigationItem.rightBarButtonItems = [wish_list_bar_button, facebook_bar_button]
                }
            } else {
                //Create wishlist and add in wishlist
                var message = ""
                var wishlist_cell = wishlist_table_cell_contents()
                wishlist_cell.item_id = self.selected_product_id
                wishlist_cell.name = self.selected_product_name
                wishlist_cell.image = self.selected_product_image
                wishlist_cell.price = self.price
                wishlist_cell.currency_symbol = self.currency_symbol
                wishlist_cell.shipping = self.shipping
                wishlist_cell.shipping_symbol = self.shipping_symbol
                wishlist_cell.zip = self.zip
                wishlist_cell.condition = self.condition
                wishlist_cell.handling_time = self.handling_time
                wishlist_cell.global_shipping = self.global_shipping
        
                wishlist[self.selected_product_id] = wishlist_cell
                
                message += self.selected_product_name
                message += " was added to the Wish List"
                show_toast_message(message: message)
                
                UserDefaults.standard.set(object: wishlist, forKey: "wishlist")
                let facebook_button = UIButton.init(type: .custom)
                facebook_button.setImage(UIImage.init(named: "facebook")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
                facebook_button.addTarget(self, action:#selector(facebook_share), for:.touchUpInside)
                facebook_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
                let facebook_bar_button = UIBarButtonItem.init(customView: facebook_button)
                
                let wish_list_button = UIButton.init(type: .custom)
                wish_list_button.setImage(UIImage.init(named: "wishListFilled")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
                wish_list_button.addTarget(self, action:#selector(wish_list), for:.touchUpInside)
                wish_list_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
                let wish_list_bar_button = UIBarButtonItem.init(customView: wish_list_button)
                self.tabBarController?.navigationItem.rightBarButtonItems = [wish_list_bar_button, facebook_bar_button]
            }
        } else {
            var message = ""
            var wishlist_cell = wishlist_table_cell_contents()
            wishlist_cell.item_id = self.selected_product_id
            wishlist_cell.name = self.selected_product_name
            wishlist_cell.image = self.selected_product_image
            wishlist_cell.price = self.price
            wishlist_cell.currency_symbol = self.currency_symbol
            wishlist_cell.shipping = self.shipping
            wishlist_cell.shipping_symbol = self.shipping_symbol
            wishlist_cell.zip = self.zip
            wishlist_cell.condition = self.condition
            wishlist_cell.handling_time = self.handling_time
            wishlist_cell.global_shipping = self.global_shipping
            
            var wishlist = [String: wishlist_table_cell_contents]()
            wishlist[self.selected_product_id] = wishlist_cell
            
            message += self.selected_product_name
            message += " was added to the Wish List"
            show_toast_message(message: message)
            
            UserDefaults.standard.set(object: wishlist, forKey: "wishlist")
            let facebook_button = UIButton.init(type: .custom)
            facebook_button.setImage(UIImage.init(named: "facebook")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
            facebook_button.addTarget(self, action:#selector(facebook_share), for:.touchUpInside)
            facebook_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
            let facebook_bar_button = UIBarButtonItem.init(customView: facebook_button)
            
            let wish_list_button = UIButton.init(type: .custom)
            wish_list_button.setImage(UIImage.init(named: "wishListFilled")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
            wish_list_button.addTarget(self, action:#selector(wish_list), for:.touchUpInside)
            wish_list_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
            let wish_list_bar_button = UIBarButtonItem.init(customView: wish_list_button)
            self.tabBarController?.navigationItem.rightBarButtonItems = [wish_list_bar_button, facebook_bar_button]
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

