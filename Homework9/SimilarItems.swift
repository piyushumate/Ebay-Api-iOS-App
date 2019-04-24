//
//  SimilarItems.swift
//  Homework9
//
//  Created by usc on 4/14/19.
//  Copyright © 2019 usc. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON

struct similar_products_cell_contents {
    var name : String?
    var image : String?
    var day_left : String?
    var item_url : String?
    var price : String?
    var currency_symbol : String?
    var shipping : String?
    var shipping_symbol : String?
}

class similar_products_collection_cell: UICollectionViewCell {
    @IBOutlet weak var collection_cell_product_image: UIImageView!
    @IBOutlet weak var collection_view_product_name: UILabel!
    @IBOutlet weak var collection_view_product_shipping: UILabel!
    @IBOutlet weak var collection_view_days_left: UILabel!
    @IBOutlet weak var collection_view_product_price: UILabel!
}


class SimilarItems: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var sort_by_segmented_control: UISegmentedControl!
    @IBOutlet weak var order_by_segmented_control: UISegmentedControl!
    @IBOutlet weak var similar_products_collection_view: UICollectionView!
    
    var similar_products_dictionary = Dictionary<String,Any> ()
    var similar_products_data = [Any]()
    var default_similar_products = [similar_products_cell_contents]()
    var similar_products = [similar_products_cell_contents]()
    
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
    
    var url = "http://assignment9-env.jmt4k6j8tq.us-east-2.elasticbeanstalk.com/search_similar_products/"
    
    let http_headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sort_by_segmented_control.selectedSegmentIndex = 0
        order_by_segmented_control.selectedSegmentIndex = 0
        order_by_segmented_control.isEnabled = false
        
        let facebook_button = UIButton.init(type: .custom)
        facebook_button.setImage(UIImage.init(named: "facebook")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
        facebook_button.addTarget(self, action:#selector(facebook_share), for:.touchUpInside)
        facebook_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let facebook_bar_button = UIBarButtonItem.init(customView: facebook_button)
        
        if UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") != nil {
            var wishlist = UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") as! [String: wishlist_table_cell_contents]
            if wishlist.count != 0 {
                //                print(wishlist[String(sender.tag)])
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
        
        // Do any additional setup after loading the view.
        ebay_request {similar_products in
            self.similar_products_dictionary = similar_products}
        
        SwiftSpinner.show(delay: 0.0, title: "Fetching Similar Items...", animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { // Change `4.0` to the desired number of seconds.
            //            print(self.product_info_dictionary)
            if self.similar_products_dictionary["data"] != nil {
                self.similar_products_data = self.similar_products_dictionary["data"] as! [Any]
                //                print(self.product_list)
                //               print(self.product_list.count)
                for item in self.similar_products_data {
                    let product = item as! [String: Any]
                    var temp = similar_products_cell_contents()
                    temp.name = product["title"] as! String
                    
                    temp.day_left = String(String(format: "%@", product["days_left"] as! CVarArg) + " Days Left")
                    
                    temp.item_url = product["item_url"] as! String
                    
                    let photo = product["image_url"]  as! String
                    temp.image = photo as! String
                    
                    let price = product["price"] as! [String: String]
                    temp.price = price["__value__"]
                    temp.currency_symbol = price["@currencyId"]
                    
                    let shipping_cost = product["shipping_price"] as! [String: String]
                    temp.shipping = shipping_cost["__value__"]
                    temp.shipping_symbol = shipping_cost["@currencyId"]

                    self.similar_products.append(temp)
                }
//                print("Initial loading")
//                print(self.similar_products)
                self.default_similar_products = self.similar_products
                self.similar_products_collection_view.reloadData()
                
            } else {
                var alert : UIAlertView = UIAlertView(title: "No Similar Products Found!", message: "Failed to fetch search results", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
//            print(self.similar_products)
            SwiftSpinner.hide()
        }
    }
    
    func show_toast_message(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/11, y: self.view.frame.size.height - self.view.frame.size.height/4.75, width: self.view.frame.size.width/1.2, height: 300))
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
    
    
    func ebay_request(completion: @escaping(_ : Dictionary<String,Any>) -> ()) {
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
    
    @IBAction func indexChanged(_ sender: Any) {
        order_by_segmented_control.isEnabled = true
        switch sort_by_segmented_control.selectedSegmentIndex
        {
            case 0:
                order_by_segmented_control.selectedSegmentIndex = 0
                order_by_segmented_control.isEnabled = false
                self.similar_products = self.default_similar_products
                self.similar_products_collection_view.reloadData()
            
            case 1:
                switch order_by_segmented_control.selectedSegmentIndex
                {
                    case 0:
                        self.similar_products = self.similar_products.sorted(by: {$0.name! < $1.name!})
                        self.similar_products_collection_view.reloadData()
                    case 1:
                        self.similar_products = self.similar_products.sorted(by: {$0.name! > $1.name!})
                        self.similar_products_collection_view.reloadData()
                    default:
                        break
                }
            case 2:
                switch order_by_segmented_control.selectedSegmentIndex
                {
                    case 0:
                        self.similar_products = self.similar_products.sorted(by: {($0.price! as NSString).integerValue < ($1.price! as NSString).integerValue})
                        self.similar_products_collection_view.reloadData()
                    case 1:
                        self.similar_products = self.similar_products.sorted(by: {($0.price! as NSString).integerValue > ($1.price! as NSString).integerValue})
                        self.similar_products_collection_view.reloadData()
                    default:
                        break
                }
            case 3:
                switch order_by_segmented_control.selectedSegmentIndex
                {
                    case 0:
                        self.similar_products = self.similar_products.sorted(by: {($0.day_left!  as NSString).integerValue < ($1.day_left! as NSString).integerValue})
                        self.similar_products_collection_view.reloadData()
                    case 1:
                        self.similar_products = self.similar_products.sorted(by: {($0.day_left! as NSString).integerValue > ($1.day_left! as NSString).integerValue})
                        self.similar_products_collection_view.reloadData()
                    default:
                        break
                }
            case 4:
                switch order_by_segmented_control.selectedSegmentIndex
                {
                    case 0:
                        self.similar_products = self.similar_products.sorted(by: {($0.shipping! as NSString).integerValue < ($1.shipping! as NSString).integerValue})
                        self.similar_products_collection_view.reloadData()
                    case 1:
                        self.similar_products = self.similar_products.sorted(by: {($0.shipping! as NSString).integerValue > ($1.shipping! as NSString).integerValue})
                        self.similar_products_collection_view.reloadData()
                    default:
                        break
                }
            default:
                break
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.similar_products.count / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var currency_symbol = ""
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! similar_products_collection_cell
        let similar_product = similar_products[indexPath.row]
        
        cell.collection_view_product_name?.text = similar_product.name
        
        var locale = NSLocale(localeIdentifier: similar_product.currency_symbol!)
        if locale.displayName(forKey: .currencySymbol, value: similar_product.currency_symbol!) == similar_product.currency_symbol! {
            let newlocale = NSLocale(localeIdentifier: similar_product.currency_symbol!.dropLast() + "_en")
            currency_symbol = newlocale.displayName(forKey: .currencySymbol, value: similar_product.currency_symbol!)!
        } else {
            currency_symbol = locale.displayName(forKey: .currencySymbol, value: similar_product.currency_symbol!)!
        }
        cell.collection_view_product_price?.text = (currency_symbol + similar_product.price!)
        
        cell.collection_view_days_left?.text = similar_product.day_left
        
        locale = NSLocale(localeIdentifier: similar_product.shipping_symbol!)
        if locale.displayName(forKey: .currencySymbol, value: similar_product.shipping_symbol!) == similar_product.shipping_symbol! {
            let newlocale = NSLocale(localeIdentifier: similar_product.shipping_symbol!.dropLast() + "_en")
            currency_symbol = newlocale.displayName(forKey: .currencySymbol, value: similar_product.shipping_symbol!)!
        } else {
            currency_symbol = locale.displayName(forKey: .currencySymbol, value: similar_product.shipping_symbol!)!
        }
        cell.collection_view_product_shipping?.text = (currency_symbol + similar_product.shipping!)
        
        let data = try? Data(contentsOf: URL(string: String(similar_product.image!))!)
        if let imageData = data {
            cell.collection_cell_product_image?.image = UIImage(data: imageData)
            cell.collection_cell_product_image?.frame.size = CGSize(width: cell.frame.width, height: 150)
        }
        
        // Round Corners for Cell
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected_product = self.similar_products[indexPath.item]
        guard let url = URL(string: String(selected_product.item_url!)) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func facebook_share(sender: UIBarButtonItem!) {
        var search_url = "https://www.facebook.com/dialog/share?app_id=2161096860867733&display=popup&href="
        search_url.append(self.item_url)
        search_url.append("&quote=")
        var message = "Buy "
        message.append(self.selected_product_name)
        message.append(" at ")
        message.append(self.selected_product_price)
        message.append(" from link below")
        message = String(message).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        search_url.append(String(message))
        guard let url = URL(string: String(search_url)) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func wish_list(sender: UIBarButtonItem!) {
        print("IN WISHLIST PRESSED")
        if UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") != nil {
            var wishlist = UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") as! [String: wishlist_table_cell_contents]
            if wishlist.count != 0 {
                //                print(wishlist[String(sender.tag)])
                if wishlist[self.selected_product_id] != nil {
                    //Remove from wishlist
                    print("IN REMOVE")
                    var message = ""
                    message += wishlist[self.selected_product_id]!.name!
                    message += " was removed from the Wish List"
                    show_toast_message(message: message)
                    
                    wishlist.removeValue(forKey: self.selected_product_id)
                    print(wishlist)
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
                    print("IN ADD")
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
                print("IN ELSE CONDITION")
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

