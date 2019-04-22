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
    var selected_product_name = ""
    var product_photos = [String]()
    
    @IBOutlet weak var scroll_view: UIScrollView!
    
    var url = "http://assignment9-env.jmt4k6j8tq.us-east-2.elasticbeanstalk.com/search_product_images/"
    
    let http_headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            for index in 0 ..< self.product_photos.count {
                let imageUrl:URL = URL(string: self.product_photos[index])!
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
        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
