//
//  NetworkManager.swift
//  commuteTracker
//
//  Created by Kevin Veldkamp on 7/22/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation



class NetworkManager{
    

    
    class func getTravelTimeFromGoogle(originLat: Double , originLon: Double , destinationLat: Double, destinationLon: Double, completion: @escaping (Int ,Error?) -> Void){
        let methodParameters: [String:String] = [
            "units" : "imperial",
            "origins": "\(originLat),\(originLon)",
            "destinations": "\(destinationLat),\(destinationLon)",
            "key" : Constants.googleApiKey
        ]
        
        let urlRequest = URLRequest(url: buildRequest(methodParameters))
        
        getRequest(urlRequest: urlRequest, response: DistanceResponse.self) { response, error in
            guard error == nil else {
                completion(0,error)
                return
            }
           
            if let response = response{
                guard response.status == "OK" else{
                    completion(0,error)
                    return
                }
                completion(response.rows[0].elements[0].duration.value, nil)
            }
        }
    }
    
    
    class func buildRequest(_ parameters: [String:String]) -> URL {
        var components = URLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.googleHost
        components.path = Constants.googlePath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    
    
    
    //reusable functions
    class func getRequest<ResponseType:Decodable>(urlRequest: URLRequest, response: ResponseType.Type, completion: @escaping (ResponseType?,Error?) -> Void){
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if error != nil{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                if let data = data{
                    print(data)
                    let decoder = JSONDecoder()
                    do {
                        let responseObject = try decoder.decode(ResponseType.self, from: data)
                        DispatchQueue.main.async {
                            completion(responseObject, nil)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
            }
            else{
                completion(nil,error)
            }
        }
        task.resume()
    }
    
    
}
