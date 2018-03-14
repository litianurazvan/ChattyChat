//
//  UIImageView+ImageCache.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 14/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

fileprivate let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    func loadImageFromUrl(_ urlString: String?, defaultImage: UIImage) {
        
        if let urlString = urlString, let image = imageCache.object(forKey: NSString(string: urlString)) as? UIImage {
            self.image = image
            return
        }
        
        guard let urlString = urlString, let profileImageUrl = URL(string: urlString) else { self.image = defaultImage; return }
        let request = URLRequest(url: profileImageUrl)
        URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.image = defaultImage
                }
                return
            }
            
            guard let image = data.flatMap(UIImage.init) else {
                DispatchQueue.main.async {
                    self.image = defaultImage
                }
                return
            }
            
            imageCache.setObject(image, forKey: NSString(string: urlString))
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
