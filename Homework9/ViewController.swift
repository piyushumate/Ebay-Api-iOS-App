import UIKit
import Alamofire
import SwiftyJSON

struct wishlist_table_contents: Codable {
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

class zipcode_table_cell: UITableViewCell {
    @IBOutlet weak var zipcode_label: UILabel!
}

class wishlist_table_cell : UITableViewCell {
    @IBOutlet weak var table_cell_product_image: UIImageView!
    @IBOutlet weak var table_cell_product_name: UILabel!
    @IBOutlet weak var table_cell_shipping_price: UILabel!
    @IBOutlet weak var table_cell_zip_code: UILabel!
    @IBOutlet weak var table_cell_condition: UILabel!
    @IBOutlet weak var table_cell_product_price: UILabel!
}

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var segmented_control: UISegmentedControl!
    @IBOutlet weak var search_form_view: UIView!
    @IBOutlet weak var wish_list_view: UIView!
    
    @IBOutlet weak var product_keyword_textfield: UITextField!
    @IBOutlet weak var product_category_selector: UITextField!
    
    @IBOutlet weak var new_checkbox: UIButton!
    @IBOutlet weak var used_checkbox: UIButton!
    @IBOutlet weak var unspecified_checkbox: UIButton!
    
    @IBOutlet weak var pickup_checkbox: UIButton!
    @IBOutlet weak var free_shipping_checkbox: UIButton!
    
    @IBOutlet weak var distance_textfield: UITextField!
    @IBOutlet weak var custom_location_switch: UISwitch!
    @IBOutlet weak var zipcode_textfield: UITextField!
    
    @IBOutlet weak var search_button: UIButton!
    @IBOutlet weak var clear_button: UIButton!
    
    @IBOutlet weak var wish_list_total_label: UILabel!
    @IBOutlet weak var wish_list_total_items_label: UILabel!
    @IBOutlet weak var wish_list_empty_label: UILabel!
    
    @IBOutlet weak var wish_list_table: UITableView!
    
    @IBOutlet weak var zipcode_table: UITableView!
    
    var ip_api_dictionary = [String: Any]()
    var zip_code_suggestions = [String: Any]()
    var wishlist_items = [wishlist_table_contents]()
    var zip_codes = [Any]()
    
    var product_keyword = ""
    var product_category = ""
    
    var local_pickup = false
    var free_shipping = false
    
    var new_condition = false
    var used_condition = false
    var unspecified_condition = false
    
    
    
    let category_map = [
        "All Categories": "all",
        "Art"   :"art",
        "Baby"  :"baby",
        "Books" :"books",
        "Clothing, Shoes & Accessories" :"clothing",
        "Computers/Tablets & Networking" :"computers",
        "Health & Beauty" :"health",
        "Music" :"music",
        "Video Games & Consoles" :"games"
    ]

    let product_categories = [String] (arrayLiteral: "All Categories",
                                       "Art",
                                       "Baby",
                                       "Books",
                                       "Clothing, Shoes & Accessories",
                                       "Computers/Tablets & Networking",
                                       "Health & Beauty",
                                       "Music",
                                       "Video Games & Consoles")

    var distance = "10"
    var zip_code = ""

    let http_headers: HTTPHeaders = ["Accept": "application/json"]
    
//    override func didMove(toParent parent: UIViewController?) {
//        super.didMove(toParent: parent)
//        if parent == nil {
//            print("aai ghalya")
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zipcode_table.delegate = self
        zipcode_table.dataSource = self
        zipcode_table.layer.masksToBounds = true
        zipcode_table.layer.cornerRadius = 10
        zipcode_table.layer.borderColor = UIColor( red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0 ).cgColor
        zipcode_table.layer.borderWidth = 2.0
        
        zipcode_textfield.delegate = self
        zipcode_textfield.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        
        get_ip_api_location {ip_api_info in self.ip_api_dictionary = ip_api_info}
        
        let category_picker = UIPickerView()
        category_picker.delegate = self
        
        let picker_toolBar = UIToolbar()
        picker_toolBar.barStyle = UIBarStyle.default
        
        picker_toolBar.isTranslucent = true
        picker_toolBar.tintColor = UIColor(
            red: 0/255,
            green: 122/255,
            blue: 255/255,
            alpha: 1)
        picker_toolBar.sizeToFit()
        
        let done_button = UIBarButtonItem(title: "Done",
                                          style: UIBarButtonItem.Style.plain,
                                          target: self,
                                          action: #selector(ViewController.donePicker))

        let space_button = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                           target: nil,
                                           action: nil)
        
        let cancel_button = UIBarButtonItem(title: "Cancel",
                                            style: UIBarButtonItem.Style.plain,
                                            target: self,
                                            action: #selector(ViewController.donePicker))
        
        picker_toolBar.setItems([cancel_button, space_button, done_button], animated: true)
        picker_toolBar.isUserInteractionEnabled = true
        
        product_category_selector.inputView = category_picker
        product_category_selector.inputAccessoryView = picker_toolBar
        product_category_selector.inputView?.backgroundColor = UIColor.white
        
        custom_location_switch.addTarget(self,
                                         action: #selector(ViewController.toggleSwitch),
                                         for: .valueChanged)
        
        pickup_checkbox.addTarget(self,
                                  action: #selector(checkbox_clicked(sender:)),
                                  for: .touchUpInside)
        free_shipping_checkbox.addTarget(self,
                                         action: #selector(checkbox_clicked(sender:)),
                                         for: .touchUpInside)

        new_checkbox.addTarget(self,
                               action: #selector(checkbox_clicked(sender:)),
                               for: .touchUpInside)
        
        used_checkbox.addTarget(self,
                                action: #selector(checkbox_clicked(sender:)),
                                for: .touchUpInside)
        
        unspecified_checkbox.addTarget(self,
                                       action: #selector(checkbox_clicked(sender:)),
                                       for: .touchUpInside)
        
        search_button.addTarget(self,
                                action: #selector(search_query),
                                for: .touchUpInside)
        
        clear_button.addTarget(self,
                               action: #selector(clear_form),
                               for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            self.zip_code = self.ip_api_dictionary["zip"] as! String
        }
    }
	
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return product_categories.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return product_categories[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        product_category_selector.text = product_categories[row]
    }
    
    @objc func donePicker() {
        product_category_selector.resignFirstResponder()
    }
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        var isHidden = false
        if !custom_location_switch.isOn {
            isHidden = true
            get_ip_api_location {ip_api_info in self.ip_api_dictionary = ip_api_info}
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.zip_code = self.ip_api_dictionary["zip"] as! String
            }
            
        } else {
            get_ip_api_zipcodes {zip_codes in self.zip_code_suggestions = zip_codes}
        }
        zipcode_textfield.isHidden = isHidden
    }
    
    func show_toast_message(message : String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        toastLabel.frame = CGRect(x: self.view.frame.size.width/2 - 100,
                                  y: self.view.frame.size.height - 100,
                                  width: 200,
                                  height: 35)
        toastLabel.font = UIFont(name: "Montserrat-Light",
                                 size: 12.0)
        
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 8.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
    
    func show_wishlist_toast_message(message : String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(1)
        toastLabel.textColor = UIColor.white
        toastLabel.frame = CGRect(x: self.view.frame.size.width/11,
                                  y: self.view.frame.size.height - self.view.frame.size.height/8,
                                  width: self.view.frame.size.width/1.2,
                                  height: 300)
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 1.1)
        toastLabel.adjustsFontSizeToFitWidth = true
        toastLabel.alpha = 1.1
        toastLabel.layer.cornerRadius = 6
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
    
    @objc func search_query(sender: UIButton!) {
        product_keyword = product_keyword_textfield.text!
        product_category = product_category_selector.text!
        
        if (distance_textfield.text!.trimmingCharacters(in: CharacterSet.whitespaces)).isEmpty {
            distance = "10"
        } else {
            distance = distance_textfield.text!
        }
        
        if custom_location_switch.isOn {
            zip_code = zipcode_textfield.text!
        }
        
        if (product_keyword.trimmingCharacters(in: CharacterSet.whitespaces)).isEmpty {
            show_toast_message(message: "Keyword Is Mandatory")
            return
        }
        
        if custom_location_switch.isOn && (zip_code.trimmingCharacters(in: CharacterSet.whitespaces)).isEmpty {
            show_toast_message(message: "Zipcode Is Mandatory")
            return
        }
        self.performSegue(withIdentifier: "product_list_segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(zip_code)
        
        switch segue.identifier {
            case "product_list_segue":
                let plc = segue.destination as! ProductListViewController
                plc.product_keyword = product_keyword
                plc.product_category = category_map[product_category]!

                plc.local_pickup = String(local_pickup)
                plc.free_shipping = String(free_shipping)

                plc.new_condition = String(new_condition)
                plc.used_condition = String(used_condition)
                plc.unspecified_condition = String(unspecified_condition)
                
                plc.distance = distance
                plc.zip_code = zip_code
            
                break
            case "product_details_segue":
                let product = wishlist_items[wish_list_table.indexPathForSelectedRow!.row]
                let dashboardController = segue.destination as! ProductDetailsViewController
                
                let prod_details = dashboardController.viewControllers![0] as! ProductInformation
                
                prod_details.selected_product_id = String(product.item_id!)
                prod_details.handling_time = String(product.handling_time!)
                prod_details.global_shipping = String(product.global_shipping!)
                
                prod_details.shipping = String(product.shipping!)
                prod_details.shipping_symbol = String(product.shipping_symbol!)
                break
            default:
                break
            
        }
        
    }
    
    func clear_checkbox(checkbox: UIButton!,  flag: inout Bool) {
        checkbox.isSelected = false
        flag = false
    }
    
    @objc func clear_form(sender: UIButton!) {
        clear_checkbox(checkbox: new_checkbox, flag: &new_condition)
        clear_checkbox(checkbox: used_checkbox, flag: &used_condition)
        clear_checkbox(checkbox: unspecified_checkbox, flag: &unspecified_condition)
        clear_checkbox(checkbox: pickup_checkbox, flag: &local_pickup)
        clear_checkbox(checkbox: free_shipping_checkbox, flag: &free_shipping)
        
        product_keyword_textfield.text = ""
        product_category_selector.text = "All Categories"
        distance_textfield.text = ""
        zipcode_textfield.text = ""
        
        custom_location_switch.isOn = false
        zipcode_textfield.isHidden = true
    }
    
    func get_ip_api_location(completion: @escaping(_ : Dictionary<String,Any>) -> ())
    {
        Alamofire.request("http://ip-api.com/json", method: .get, encoding:JSONEncoding.default, headers: http_headers).responseJSON { (response:DataResponse<Any>) in
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
    
    func get_ip_api_zipcodes(completion: @escaping(_ : Dictionary<String,Any>) -> ())
    {
        var url = "http://assignment9-env.jmt4k6j8tq.us-east-2.elasticbeanstalk.com/search_zip_codes?zip_code="
        
        url += self.zipcode_textfield?.text as! String
        
        Alamofire.request(url, method: .get, encoding:JSONEncoding.default, headers: http_headers).responseJSON { (response:DataResponse<Any>) in
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
    
    func update_wish_list() {
        if UserDefaults.standard.object([String: wishlist_table_contents].self, with: "wishlist") != nil {
            let wishlist = UserDefaults.standard.object([String: wishlist_table_contents].self, with: "wishlist") as! [String: wishlist_table_contents]
            
            if 0 == wishlist.count {
                wish_list_table.isHidden = true
                wish_list_total_label.isHidden = true
                wish_list_total_items_label.isHidden = true
                wish_list_empty_label.isHidden = false
            } else {
                var total_price = 0.0
                wishlist_items = [wishlist_table_contents]()
                
                for wishlist_item in wishlist {
                    wishlist_items.append(wishlist_item.value)
                    
                    let price = Double(wishlist_item.value.price!)
                    total_price += price!
                }
                
                var currency_symbol = ""
                let wishlist_item = wishlist_items[0] as! wishlist_table_contents
                var locale = NSLocale(localeIdentifier: wishlist_item.currency_symbol!)
                
                if locale.displayName(forKey: .currencySymbol, value: wishlist_item.currency_symbol!) == wishlist_item.currency_symbol! {
                    let newlocale = NSLocale(localeIdentifier: wishlist_item.currency_symbol!.dropLast() + "_en")
                    currency_symbol = newlocale.displayName(forKey: .currencySymbol,
                                                            value: wishlist_item.currency_symbol!)!
                } else {
                    currency_symbol = locale.displayName(forKey: .currencySymbol,
                                                         value: wishlist_item.currency_symbol!)!
                }
                
                wish_list_total_label?.text = (currency_symbol + String(total_price))
                wish_list_total_label.isHidden = false
                
                let wishlist_total_items = ["WishList Total(",
                                            String(wishlist_items.count),
                                            " items):"].joined(separator: "")
                
                wish_list_total_items_label?.text = wishlist_total_items
                
                wish_list_total_items_label.isHidden = false
                wish_list_table.isHidden = false
                wish_list_empty_label.isHidden = true
                wish_list_table.reloadData()
            }
        } else {
            wish_list_table.isHidden = true
            wish_list_total_label.isHidden = true
            wish_list_total_items_label.isHidden = true
            wish_list_empty_label.isHidden = false
        }

    }
    
    @IBAction func segmented_control_change(_ sender: Any) {
        let search_view = 0
        let wish_list = 1
        switch segmented_control.selectedSegmentIndex {
            case search_view:
                search_form_view.isHidden = false
                wish_list_view.isHidden = true
                break
            case wish_list:
                search_form_view.isHidden = true
                wish_list_view.isHidden = false
                update_wish_list()
                break
            default:
                break
        }
    }
    
    func toggle_checkbox(checkbox: UIButton!,  flag: inout Bool) {
        flag = !flag;
        checkbox.isSelected = !checkbox.isSelected;
        checkbox.setBackgroundImage(UIImage(named: flag ? "checked" : "uwnchecked"), for: flag ? .selected:.normal)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        print("aaighalya")
    }
    
    @IBAction func checkbox_clicked(sender: UIButton)
    {
        // Instead of specifying each button we are just using the sender (button that invoked) the method
        switch sender {
            case new_checkbox:
                toggle_checkbox(checkbox: new_checkbox, flag: &new_condition)
                break
            case used_checkbox:
                toggle_checkbox(checkbox: used_checkbox, flag: &used_condition)
                break
            case unspecified_checkbox:
                toggle_checkbox(checkbox: unspecified_checkbox, flag: &unspecified_condition)
                break
            case pickup_checkbox:
                toggle_checkbox(checkbox: pickup_checkbox, flag: &local_pickup)
                break
            case free_shipping_checkbox:
                toggle_checkbox(checkbox: free_shipping_checkbox, flag: &free_shipping)
                break
            default:
                break
        }
    }
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        textfield.isHidden = false
        let zipcode = textfield.text! as String
        get_autocomplete_entries(zipcode: zipcode)
    }
    
    func get_autocomplete_entries(zipcode: String) {
        get_ip_api_zipcodes{zip_codes in self.zip_code_suggestions = zip_codes}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.zip_codes = self.zip_code_suggestions["data"] as! [Any]
            self.zipcode_table.isHidden = false
            self.zipcode_table.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView != zipcode_table {
            return self.wishlist_items.count
        } else {
            return self.zip_codes.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print(tableView)
        if tableView == self.zipcode_table {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Zipcode_Cell", for: indexPath) as! zipcode_table_cell
            let zipcode = zip_codes[indexPath.row] as! String
            cell.zipcode_label!.text = zipcode
            return cell
        } else {
            var currency_symbol = ""
            let cell = tableView.dequeueReusableCell(withIdentifier: "Wishlist_Cell", for: indexPath) as! wishlist_table_cell
            let product = wishlist_items[indexPath.row]
            
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.zipcode_table {
            zipcode_textfield.text = zip_codes[indexPath.row] as! String
            zip_code = zip_codes[indexPath.row] as! String
            zipcode_table.isHidden = true
            zipcode_textfield.endEditing(true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == self.wish_list_table {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == self.wish_list_table {
            if (editingStyle == .delete) {
                let product = wishlist_items[indexPath.row]
                var message = ""
                message += product.name!
                
                if UserDefaults.standard.object([String: wishlist_table_contents].self, with: "wishlist") != nil {
                    var wishlist = UserDefaults.standard.object(
                        [String: wishlist_table_contents].self,
                        with: "wishlist") as! [String: wishlist_table_contents]
                    wishlist.removeValue(forKey: String(product.item_id!))
                
                    if 0 == wishlist.count {
                        UserDefaults.standard.removeObject(forKey: "wishlist")
                        wishlist_items = [wishlist_table_contents]()
                        wish_list_total_label.isHidden = true
                        wish_list_total_items_label.isHidden = true
                        wish_list_table.isHidden = true
                        wish_list_empty_label.isHidden = false
                    } else {
                        UserDefaults.standard.set(object: wishlist, forKey: "wishlist")
                        wishlist_items = [wishlist_table_contents]()
                        var total_price = 0.0
                        for wishlist_item in wishlist {
                            wishlist_items.append(wishlist_item.value)
                            total_price += Double(wishlist_item.value.price!)!
                        }
                        
                        var currency_symbol = ""
                        let wishlist_item = wishlist_items[0] as! wishlist_table_contents
                        var locale = NSLocale(localeIdentifier: wishlist_item.currency_symbol!)
                        if locale.displayName(forKey: .currencySymbol, value: wishlist_item.currency_symbol!) == wishlist_item.currency_symbol! {
                            let newlocale = NSLocale(localeIdentifier: wishlist_item.currency_symbol!.dropLast() + "_en")
                            currency_symbol = newlocale.displayName(forKey: .currencySymbol,
                                                                    value: wishlist_item.currency_symbol!)!
                        } else {
                            currency_symbol = locale.displayName(forKey: .currencySymbol,
                                                                 value: wishlist_item.currency_symbol!)!
                        }
                        
                        wish_list_total_label?.text = (currency_symbol + String(total_price))
                        wish_list_total_label.isHidden = false
                        let wishlist_total_items = ["WishList Total(",
                                                    String(wishlist_items.count),
                                                    " items):"].joined(separator: "")
                        wish_list_total_items_label?.text = wishlist_total_items
                        wish_list_total_items_label.isHidden = false
                        wish_list_table.isHidden = false
                        wish_list_empty_label.isHidden = true
                        wish_list_table.reloadData()
                    }
                    show_wishlist_toast_message(message: message + " was removed from the Wish List")
                } else {
                    wishlist_items = [wishlist_table_contents]()
                    
                    wish_list_total_label.isHidden = true
                    wish_list_total_items_label.isHidden = true
                    wish_list_table.isHidden = true
                    wish_list_empty_label.isHidden = false
                }
            }
        }
    }
    
}

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}

