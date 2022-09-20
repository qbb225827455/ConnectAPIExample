//
//  ViewController.swift
//  ConnectAPIExample
//
//  Created by 陳鈺翔 on 2022/9/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    var products = [Product]()
    var token: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func getProducts() {
        
        let url = "http://localhost:8080/products"
        AF.request(url, method: .get).validate().responseJSON { response in
            
            switch response.result {
            
            case .success(let value):
                
                let json = JSON(value)
                let list = json.arrayValue
                var products = [Product]()
                
                for productJSON in list {
                    let product = Product(json: productJSON)
                    products.append(product)
                }
                self.products = products
                for product in self.products {
                    print(product)
                }
                print("JSON: \(json)")
            
            case.failure(let error):
                print("error: \(error)")
            }
        }
    }
    
    @IBAction func createProduct() {
        
        let url = "http://localhost:8080/products"
        
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        
        dispatchQueue.async {
            
            self.genToken { _ in
                print("Finished get token")
                semaphore.signal()
            }
            semaphore.wait()
            
            let params = CreateProduct(name: "EEE", price: 134)
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(self.token)",
                "Accept": "application/json"
            ]
            
            AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default, headers: headers).validate().responseJSON { response
                in
                
                switch response.result {
                
                case .success(let value):
                    print("Value: \(value)")
                
                case.failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    func genToken(completionHandler: @escaping (String) -> Void) {
        
        let url = "http://localhost:8080/auth"
        let params = Login(username: "test1@", password: "123456")
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default).validate().responseJSON { response in
            
            switch response.result {
            
            case .success(let value):
                let json = JSON(value)
                self.token = json["token"].stringValue
                print("JSON: \(json)")
                print("Token: \(self.token)")
            
            case.failure(let error):
                print("error: \(error)")
            }
            completionHandler(self.token)
        }
    }
}

struct Product {
    var creator: String
    var name: String
    var id: String
    var price: Int
    
    init(json: JSON) {
        self.creator = json["creator"].stringValue
        self.name = json["name"].stringValue
        self.id = json["id"].stringValue
        self.price = json["price"].intValue
    }
}

struct Login: Encodable {
    let username: String
    let password: String
}

struct CreateProduct: Encodable {
    let name: String
    let price: Int
}
