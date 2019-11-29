//
//  ViewController+Extension.swift
//  Virtual Tourist
//
//  Created by Abdulla Hasanov on 11/27/19.
//  Copyright © 2019 Abdulla Hasanov. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlertVC(errorMessage: String, completion: ((UIAlertAction) -> Void)?) {
        let errorAlertController = UIAlertController(title: "Error ocurred", message: errorMessage, preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler:  completion))
        self.navigationController?.present(errorAlertController, animated: true, completion: nil)
    }
}
