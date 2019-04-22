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
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("IN PRODUCT")
//        print(self.required_product_info)
//        // Do any additional setup after loading the view.
//    }

    var selected_product_id = ""
    var global_shipping = ""
    var handling_time = "1"
    var shipping = ""
    var shipping_symbol = ""
    var selected_product_name = ""
    
    var product_info_dictionary = Dictionary<String,Any> ()
    
    var url = "http://assignment9-env.jmt4k6j8tq.us-east-2.elasticbeanstalk.com/search_single_product/"
    
    let http_headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        scroll_view.delegate = self
        self.view.addSubview(tableView)
        
//        print(self.global_shipping)
//        print(self.handling_time)
//        print(self.selected_product_id)
//        print(self.shipping)
//        print(self.shipping_symbol)
        
        ebay_request {product_information in
            self.product_info_dictionary = product_information}
        
        SwiftSpinner.show(delay: 1.0, title: "Fetching Product Details...", animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { // Change `4.0` to the desired number of seconds.
//            print(self.product_info_dictionary)
            if self.product_info_dictionary["data"] != nil {
                self.required_product_info = self.product_info_dictionary["data"] as! [String: Any]
                
//                print("IN PRODUCT INFO")

                // Shipping Dictionary
                if self.required_product_info["Seller"] != nil {
//                    print(self.required_product_info["Seller"])
                    self.shipping_info_dictionary = self.required_product_info["Seller"] as! [String: Any]
                    self.required_product_info.removeValue(forKey: "Seller")
                }
                
                if self.required_product_info["Storefront"] != nil {
//                    print(self.required_product_info["Storefront"])
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
                
                if self.required_product_info["ReturnsAccepted"] != nil {
                    self.shipping_info_dictionary["ReturnsAccepted"] = self.required_product_info["ReturnsAccepted"]
                    self.required_product_info.removeValue(forKey: "ReturnsAccepted")
                }
                
                if self.required_product_info["Refund"] != nil {
                    self.shipping_info_dictionary["Refund"] = self.required_product_info["Refund"]
                    self.required_product_info.removeValue(forKey: "Refund")
                }
                
                if self.required_product_info["ShippingCostPaidBy"] != nil {
                    self.shipping_info_dictionary["ShippingCostPaidBy"] = self.required_product_info["ShippingCostPaidBy"]
                    self.required_product_info.removeValue(forKey: "ShippingCostPaidBy")
                }
                
//                print(self.shipping_info_dictionary)
                
                // Photos
                if self.required_product_info["Photo"] != nil {
                    self.product_photos = self.required_product_info["Photo"] as! [String]
                    self.required_product_info.removeValue(forKey: "Photo")
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
                    let price = String(describing: price_dictionary["__value__"]!)
                    let symbol = String(describing: price_dictionary["@currencyId"]!)
                    var locale = NSLocale(localeIdentifier: symbol)
                    if locale.displayName(forKey: .currencySymbol, value: symbol) == symbol {
                        let newlocale = NSLocale(localeIdentifier: symbol.dropLast() + "_en")
                        currency_symbol = newlocale.displayName(forKey: .currencySymbol, value: symbol)!
                    } else {
                        currency_symbol = locale.displayName(forKey: .currencySymbol, value: symbol)!
                    }
                    self.product_price?.text = (currency_symbol + price)
                    self.required_product_info.removeValue(forKey: "Price")
                }
                
                if self.required_product_info["ViewItemURLForNaturalSearch"] != nil {
                    self.required_product_info.removeValue(forKey: "ViewItemURLForNaturalSearch")
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
                
                let product_shipping_tab = self.tabBarController?.viewControllers![1] as! ProductShippingInformation
                product_shipping_tab.shipping_info_dictionary = self.shipping_info_dictionary
                
                let product_photos_tab = self.tabBarController?.viewControllers![2] as! ProductPhotos
                product_photos_tab.selected_product_name = self.selected_product_name
                
                let similar_items_tab = self.tabBarController?.viewControllers![3] as! SimilarItems
                similar_items_tab.selected_product_id = self.selected_product_id
            } else {
                var alert : UIAlertView = UIAlertView(title: "No Product Details!", message: "Failed to fetch search results", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            SwiftSpinner.hide()
        }
    }
    
    func ebay_request(completion: @escaping(_ : Dictionary<String,Any>) -> ())
    {
//                print(self.global_shipping)
//                print(self.handling_time)
//                print(self.shipping)
//                print(self.shipping_symbol)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


