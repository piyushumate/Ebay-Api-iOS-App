//
//  ViewController.swift
//  Homework9
//
//  Created by usc on 4/5/19.
//  Copyright © 2019 usc. All rights reserved.
//

import UIKit

class SearchController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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

    let product_categories = [String] (arrayLiteral: "All Categories",
                                       "Art",
                                       "Baby",
                                       "Books",
                                       "Clothing, Shoes & Accessories",
                                       "Computers/Tablets & Networking",
                                       "Health & Beauty",
                                       "Music",
                                       "Video Games & Consoles")
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

    var product_keyword = ""
    var product_category = ""
    var zip_code = ""
    var distance = "10"
    
    var new_condition = false
    var used_condition = false
    var unspecified_condition = false
    var local_pickup = false
    var free_shipping = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        
        let done_button = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(SearchController.donePicker))
        let space_button = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancel_button = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(SearchController.donePicker))
        
        picker_toolBar.setItems([cancel_button, space_button, done_button], animated: true)
        picker_toolBar.isUserInteractionEnabled = true
        
        product_category_selector.inputView = category_picker
        product_category_selector.inputAccessoryView = picker_toolBar
        product_category_selector.inputView?.backgroundColor = UIColor.white
        
        custom_location_switch.addTarget(self, action: #selector(SearchController.toggleSwitch), for: .valueChanged)

        pickup_checkbox.addTarget(self, action: #selector(checkbox_clicked(sender:)), for: .touchUpInside)
        free_shipping_checkbox.addTarget(self, action: #selector(checkbox_clicked(sender:)), for: .touchUpInside)

        new_checkbox.addTarget(self, action: #selector(checkbox_clicked(sender:)), for: .touchUpInside)
        used_checkbox.addTarget(self, action: #selector(checkbox_clicked(sender:)), for: .touchUpInside)
        unspecified_checkbox.addTarget(self, action: #selector(checkbox_clicked(sender:)), for: .touchUpInside)
        
        
        search_button.addTarget(self, action: #selector(search_query), for: .touchUpInside)
        clear_button.addTarget(self, action: #selector(clear_form), for: .touchUpInside)
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
        if custom_location_switch.isOn {
            zipcode_textfield.isHidden = false
        } else {
            zipcode_textfield.isHidden = true
        }
    }
    
    func show_toast_message(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height - 100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    @objc func search_query(sender: UIButton!) {
        product_category = product_category_selector.text!
        product_keyword = product_keyword_textfield.text!
        zip_code = zipcode_textfield.text!
        
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
        case "product_list_segue":
            let product_list_view_controller = segue.destination as! ProductListViewController
            product_list_view_controller.product_keyword = product_keyword
            product_list_view_controller.product_category = category_map[product_category]!
            product_list_view_controller.distance = distance
            product_list_view_controller.zip_code = zip_code
            product_list_view_controller.local_pickup = String(local_pickup)
            product_list_view_controller.free_shipping = String(free_shipping)
            product_list_view_controller.new_condition = String(new_condition)
            product_list_view_controller.used_condition = String(used_condition)
            product_list_view_controller.unspecified_condition = String(unspecified_condition)
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
        product_category_selector.text = "All Categories"
        clear_checkbox(checkbox: new_checkbox, flag: &new_condition)
        clear_checkbox(checkbox: used_checkbox, flag: &used_condition)
        clear_checkbox(checkbox: unspecified_checkbox, flag: &unspecified_condition)
        clear_checkbox(checkbox: pickup_checkbox, flag: &local_pickup)
        clear_checkbox(checkbox: free_shipping_checkbox, flag: &free_shipping)
        product_keyword_textfield.text = ""
        distance_textfield.text = ""
        zipcode_textfield.text = ""
        zipcode_textfield.isHidden = true
        custom_location_switch.isOn = false
    }
    
    @IBAction func segmented_control_change(_ sender: Any) {
        switch segmented_control.selectedSegmentIndex {
        case 0:
            search_form_view.isHidden = false
            wish_list_view.isHidden = true
            break
        case 1:
            search_form_view.isHidden = true
            donePicker()
            wish_list_view.isHidden = false
            wish_list_empty_label.isHidden = false
            wish_list_total_items_label.isHidden = true
            wish_list_total_label.isHidden = true
            break
        default:
            break
        }
    }
    
    func toggle_checkbox(checkbox: UIButton!,  flag: inout Bool) {
        flag = !flag;
        checkbox.isSelected = !checkbox.isSelected;
        checkbox.setBackgroundImage(UIImage(named: flag ? "checked" : "unchecked"), for: flag ? .selected:.normal)
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
}
