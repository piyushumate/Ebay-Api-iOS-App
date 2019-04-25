import UIKit
import Alamofire
import SwiftyJSON
import McPicker
import Toast_Swift
//import EasyToast

struct wishlist_table_cell_contents: Codable {
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

class SearchController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmented_control: UISegmentedControl!
    @IBOutlet weak var search_form_view: UIView!
    @IBOutlet weak var wish_list_view: UIView!
    
    @IBOutlet weak var product_keyword_textfield: UITextField!
    @IBOutlet weak var product_category_selector: McTextField!
    
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
    var zip_code_suggestion = [String: Any]()
    var wishlist_items = [wishlist_table_cell_contents]()
    var zip_codes = [Any]()
    var selected_row = IndexPath()
    
    var product_keyword = ""
    var product_category = ""
    var new_condition = false
    var used_condition = false
    var unspecified_condition = false
    var local_pickup = false
    var free_shipping = false
    var distance = "10"
    var zip_code = "90089"
    
    let category_map = [
        "All": "all",
        "Art"   :"art",
        "Baby"  :"baby",
        "Books" :"books",
        "Clothing, Shoes & Accessories" :"clothing",
        "Computers/Tablets & Networking" :"computers",
        "Health & Beauty" :"health",
        "Music" :"music",
        "Video Games & Consoles" :"games"
    ]
    
    let product_categories:[[String]] = [["All",
                                          "Art",
                                          "Baby",
                                          "Books",
                                          "Clothing, Shoes & Accessories",
                                          "Computers/Tablets & Networking",
                                          "Health & Beauty",
                                          "Music",
                                          "Video Games & Consoles"]]
    
    let http_headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //        UserDefaults.standard.removeObject(forKey: "wishlist")
        if UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") != nil {
            let wishlist = UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") as! [String: wishlist_table_cell_contents]
            print(wishlist.count)
            if wishlist.count == 0 {
                wish_list_table.isHidden = true
                wish_list_total_label.isHidden = true
                wish_list_total_items_label.isHidden = true
                wish_list_empty_label.isHidden = false
            }
            else {
                // Display wishlist
                var total_price = 0.0
                wishlist_items = [wishlist_table_cell_contents]()
                
                for wishlist_item in wishlist {
                    wishlist_items.append(wishlist_item.value)
                }
                
                for wishlist_item in wishlist_items {
                    let price = Double(wishlist_item.price!)
                    total_price += price!
                }
                
                var currency_symbol = ""
                let wishlist_item = wishlist_items[0] as! wishlist_table_cell_contents
                var locale = NSLocale(localeIdentifier: wishlist_item.currency_symbol!)
                if locale.displayName(forKey: .currencySymbol, value: wishlist_item.currency_symbol!) == wishlist_item.currency_symbol! {
                    let newlocale = NSLocale(localeIdentifier: wishlist_item.currency_symbol!.dropLast() + "_en")
                    currency_symbol = newlocale.displayName(forKey: .currencySymbol, value: wishlist_item.currency_symbol!)!
                } else {
                    currency_symbol = locale.displayName(forKey: .currencySymbol, value: wishlist_item.currency_symbol!)!
                }
                
                wish_list_total_label?.text = (currency_symbol + String(total_price))
                wish_list_total_label.isHidden = false
                var wishlist_total_items = "WishList Total("
                wishlist_total_items += String(wishlist_items.count)
                wishlist_total_items += " items):"
                wish_list_total_items_label?.text = wishlist_total_items
                wish_list_total_items_label.isHidden = false
                wish_list_table.isHidden = false
                wish_list_empty_label.isHidden = true
                wish_list_table.reloadData()
                print(selected_row)
                if wishlist_items.count > 0 && selected_row.count > 0 && wishlist_items.count > selected_row.row {
                    self.wish_list_table.selectRow(at:selected_row, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
                }
            }
        } else {
            wish_list_table.isHidden = true
            wish_list_total_label.isHidden = true
            wish_list_total_items_label.isHidden = true
            wish_list_empty_label.isHidden = false
        }
        
        zipcode_table.delegate = self
        zipcode_table.dataSource = self
        zipcode_table.layer.masksToBounds = true
        zipcode_table.layer.cornerRadius = 8
        zipcode_table.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        zipcode_table.layer.borderWidth = 1
        
        zipcode_textfield.delegate = self
        zipcode_textfield.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        
        get_ip_api_location {ip_api_information in self.ip_api_dictionary = ip_api_information}
        
        let category_picker = McPicker(data: product_categories)
        //        category_picker.delegate = self
        product_category_selector.inputViewMcPicker = category_picker
        product_category_selector.selectionChangedHandler = {[weak product_category_selector] (selected_category, changed_category) in product_category_selector?.text = selected_category[changed_category]!}
        product_category_selector.doneHandler = {[weak product_category_selector] (selected_category) in product_category_selector?.text = selected_category[0]!}
        product_category_selector.cancelHandler = {[weak product_category_selector] in product_category_selector?.text = "All"}
        product_category_selector.textFieldWillBeginEditingHandler = {[weak product_category_selector] (selecte_category) in
            if product_category_selector?.text == "All" {
                product_category_selector?.text = selecte_category[0]
            }
        }
        
        custom_location_switch.addTarget(self, action: #selector(SearchController.toggleSwitch), for: .valueChanged)
        
        new_checkbox.addTarget(self, action: #selector(checkbox_clicked(sender:)), for: .touchUpInside)
        used_checkbox.addTarget(self, action: #selector(checkbox_clicked(sender:)), for: .touchUpInside)
        unspecified_checkbox.addTarget(self, action: #selector(checkbox_clicked(sender:)), for: .touchUpInside)
        
        pickup_checkbox.addTarget(self, action: #selector(checkbox_clicked(sender:)), for: .touchUpInside)
        free_shipping_checkbox.addTarget(self, action: #selector(checkbox_clicked(sender:)), for: .touchUpInside)
        
        search_button.addTarget(self, action: #selector(search_query), for: .touchUpInside)
        clear_button.addTarget(self, action: #selector(clear_form), for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.ip_api_dictionary["zip"] == nil {
                self.zip_code = self.ip_api_dictionary["zip"] as! String
            }
            //            print(self.zip_code)
        }
    }
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        var isHidden = false
        if !custom_location_switch.isOn {
            isHidden = true
            get_ip_api_location {ip_api_info in self.ip_api_dictionary = ip_api_info}
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.zip_code = self.ip_api_dictionary["zip"] as! String
            }
        } else {
            get_ip_api_zipcodes{zip_codes in self.zip_code_suggestion = zip_codes}
        }
        zipcode_textfield.isHidden = isHidden
    }
    
    func show_toast_message(message : String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom, style: ToastStyle())
    }
    
    @objc func search_query(sender: UIButton!) {
        product_keyword = product_keyword_textfield.text!
        product_category = product_category_selector.text!
        
        if custom_location_switch.isOn {
            zip_code = zipcode_textfield.text!
        }
        
        if distance_textfield.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            distance = "10"
        } else {
            distance = distance_textfield.text!
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
        switch segue.identifier {
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
            
        case "product_list_segue":
            let plc = segue.destination as! ProductListController
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
        product_category_selector.text = "All"
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
        var url = "http://csci571homework8-env.crc386dumd.us-east-2.elasticbeanstalk.com/get_zip?zip-code="
        
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
    
    func update_wish_list() {
        if UserDefaults.standard.object([String: wishlist_table_cell_contents].self, with: "wishlist") == nil {
            wish_list_table.isHidden = true
            wish_list_total_label.isHidden = true
            wish_list_total_items_label.isHidden = true
            wish_list_empty_label.isHidden = false
        } else {
            
            let wishlist = UserDefaults.standard.object(
                [String: wishlist_table_cell_contents].self,
                with: "wishlist") as! [String: wishlist_table_cell_contents]
            
            if 0 != wishlist.count {
                
                var total_price = 0.0
                wishlist_items = [wishlist_table_cell_contents]()
                
                for wishlist_item in wishlist {
                    wishlist_items.append(wishlist_item.value)
                    let price = Double(wishlist_item.value.price!)
                    total_price += price!
                }
                
                var currency_symbol = ""
                let wishlist_item = wishlist_items[0] as! wishlist_table_cell_contents
                var locale = NSLocale(localeIdentifier: wishlist_item.currency_symbol!)
                if locale.displayName(forKey: .currencySymbol, value: wishlist_item.currency_symbol!) == wishlist_item.currency_symbol! {
                    let newlocale = NSLocale(localeIdentifier: wishlist_item.currency_symbol!.dropLast() + "_en")
                    currency_symbol = newlocale.displayName(forKey: .currencySymbol, value: wishlist_item.currency_symbol!)!
                } else {
                    currency_symbol = locale.displayName(forKey: .currencySymbol, value: wishlist_item.currency_symbol!)!
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
            else {
                wish_list_table.isHidden = true
                wish_list_total_label.isHidden = true
                wish_list_total_items_label.isHidden = true
                wish_list_empty_label.isHidden = false
            }
        }
    }
    
    func toggle_checkbox(checkbox: UIButton!,  flag: inout Bool) {
        flag = !flag;
        checkbox.isSelected = !checkbox.isSelected;
        checkbox.setBackgroundImage(UIImage(named: flag ? "checked" : "uwnchecked"), for: flag ? .selected:.normal)
    }
    
    @IBAction func checkbox_clicked(sender: UIButton)
    {
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
        get_autocomplete_entries(zipcode: textfield.text! as String)
    }
    
    func get_autocomplete_entries(zipcode: String) {
        get_ip_api_zipcodes {zip_codes in self.zip_code_suggestion = zip_codes}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.zip_codes = self.zip_code_suggestion["data"] as! [Any]
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
        if tableView != self.zipcode_table {
            selected_row = indexPath
        } else {
            zipcode_textfield.text = zip_codes[indexPath.row] as! String
            zip_code = zip_codes[indexPath.row] as! String
            zipcode_table.isHidden = true
            zipcode_textfield.endEditing(true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView != self.wish_list_table {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == self.wish_list_table {
            switch editingStyle {
            case .delete:
                let product = wishlist_items[indexPath.row]
                var message = product.name!
                
                if UserDefaults.standard.object(
                    [String: wishlist_table_cell_contents].self,
                    with: "wishlist") == nil {
                    wishlist_items = [wishlist_table_cell_contents]()
                    wish_list_total_label.isHidden = true
                    wish_list_total_items_label.isHidden = true
                    wish_list_table.isHidden = true
                    wish_list_empty_label.isHidden = false
                    
                } else {
                    
                    var wishlist = UserDefaults.standard.object(
                        [String: wishlist_table_cell_contents].self,
                        with: "wishlist") as! [String: wishlist_table_cell_contents]
                    wishlist.removeValue(forKey: String(product.item_id!))
                    
                    if 0 == wishlist.count {
                        UserDefaults.standard.removeObject(forKey: "wishlist")
                        wishlist_items = [wishlist_table_cell_contents]()
                        wish_list_total_label.isHidden = true
                        wish_list_total_items_label.isHidden = true
                        wish_list_table.isHidden = true
                        wish_list_empty_label.isHidden = false
                    } else {
                        UserDefaults.standard.set(object: wishlist, forKey: "wishlist")
                        wishlist_items = [wishlist_table_cell_contents]()
                        var total_price = 0.0
                        for wishlist_item in wishlist {
                            wishlist_items.append(wishlist_item.value)
                            total_price += Double(wishlist_item.value.price!)!
                        }
                        
                        
                        var currency_symbol = ""
                        let wishlist_item = wishlist_items[0] as! wishlist_table_cell_contents
                        var locale = NSLocale(localeIdentifier: wishlist_item.currency_symbol!)
                        if locale.displayName(forKey: .currencySymbol, value: wishlist_item.currency_symbol!) == wishlist_item.currency_symbol! {
                            let newlocale = NSLocale(localeIdentifier: wishlist_item.currency_symbol!.dropLast() + "_en")
                            currency_symbol = newlocale.displayName(forKey: .currencySymbol, value: wishlist_item.currency_symbol!)!
                        } else {
                            currency_symbol = locale.displayName(forKey: .currencySymbol, value: wishlist_item.currency_symbol!)!
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
                    
                    show_toast_message(message: message + " was removed from the Wish List")
                }
                break
            default:
                break
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
