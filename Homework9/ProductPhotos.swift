//
//  ProductPhotos.swift
//  Homework9
//
//  Created by usc on 4/14/19.
//  Copyright © 2019 usc. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON

class ProductPhotos: UIViewController {

    var input_query_parameters = [String: Any] ()
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
    var product_photos = [String]()
    
    @IBOutlet weak var scroll_view: UIScrollView!
    
    var url = "http://assignment9-env.jmt4k6j8tq.us-east-2.elasticbeanstalk.com/search_product_images/"
    
    let http_headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        } else {
            let wish_list_button = UIButton.init(type: .custom)
            wish_list_button.setImage(UIImage.init(named: "wishListEmpty")?.maskWithColor(color: UIColor(name: "pureblue")!), for: .normal)
            wish_list_button.addTarget(self, action:#selector(wish_list), for:.touchUpInside)
            wish_list_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
            let wish_list_bar_button = UIBarButtonItem.init(customView: wish_list_button)
            self.tabBarController?.navigationItem.rightBarButtonItems = [wish_list_bar_button, facebook_bar_button]
        }
        
        // Do any additional setup after loading the view.
        input_query_parameters = [
            "search_query" : selected_product_name,
        ]
        
        ebay_request{input_list in
            self.product_photos = input_list}
        
        SwiftSpinner.show(delay: 1.0, title: "Fetching Google Images...", animated: true)
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 4.0) {
            // Start background thread so that image loading does not make app unresponsive
//            print(self.product_photos)
            
            if self.product_photos.count != 0 {
                for index in 0 ..< self.product_photos.count {
                    let imageUrl:URL = URL(string: self.product_photos[index])!
                    if NSData(contentsOf: imageUrl) == nil {
                        continue
                    }
                    let imageData:NSData = NSData(contentsOf: imageUrl)!
                    let myImageView = UIImageView(frame: CGRect(x: 0,
                                                                y: self.scroll_view.frame.width * CGFloat(index),
                                                                width: self.scroll_view.frame.width,
                                                                height: self.scroll_view.frame.width))
                    
                    let image = UIImage(data: imageData as Data)
                    myImageView.image = image
                    
                    // When from background thread, UI needs to be updated on main_queue
                    DispatchQueue.main.async {
                        self.scroll_view.addSubview(myImageView)
                        self.scroll_view.contentSize = CGSize(width:self.scroll_view.frame.width,
                                                              height:self.scroll_view.frame.height * CGFloat(self.product_photos.count))
                    }
                    SwiftSpinner.hide()
                }
            } else {
                SwiftSpinner.hide()
                var alert : UIAlertView = UIAlertView(title: "No Google Photos Found!", message: "Failed to fetch search results", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
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
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func ebay_request(completion: @escaping(_ : [String]) -> ())
    {
        Alamofire.request(url, method: .post, parameters: input_query_parameters, encoding:JSONEncoding.default, headers: http_headers).responseJSON { (response:DataResponse<Any>) in
            var result_array = [String]()
            switch(response.result)
            {
                case .success(_):
                    
                    if response.result.value != nil
                    {
                        result_array = response.result.value! as! [String]
    //                    print(result_array)
                    }
                    break
                
                case .failure(_):
                    if response.result.error != nil
                    {
                        print(response.result.error!)
                    }
                    break
            }
            completion(result_array)
        }
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
                    
                    message += self.selected_product_name
                    message += " was added to the Wish List"
                    show_toast_message(message: message)
                    
                    wishlist[self.selected_product_id] = wishlist_cell
                    //                print(wishlist)
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
                
                message += self.selected_product_name
                message += " was added to the Wish List"
                show_toast_message(message: message)
                
                wishlist[self.selected_product_id] = wishlist_cell
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

