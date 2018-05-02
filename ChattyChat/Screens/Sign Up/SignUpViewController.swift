//
//  SignUpViewController.swift
//  FirebaseLogin
//
//  Created by Razvan Litianu on 09/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, SegueHandlerType {
    
    //MARK:- IBOutlets

    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.delegate = self
        }
    }
    @IBOutlet weak var userNameTextField: UITextField! {
        didSet {
            userNameTextField.delegate = self
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    @IBOutlet weak var retypePasswordTextField: UITextField! {
        didSet {
            retypePasswordTextField.delegate = self
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var formStack: UIStackView!

    //MARK:- Dependencies
    
    var authetificationSucceded: ()->() = { }
    var userManager: UserManager!
    
    @IBAction func onProfileImageTap(_ sender: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    lazy var didSelectImage: (UIImage) -> () = { [weak self] image in
        self?.profileImageView.image = image
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        let keyboardHeight = keyboardSize.height
        
        guard let activeField = activeField else { return }
        let activeFieldHeight = activeField.frame.size.height
        let activeFieldOrigin = formStack.convert(activeField.frame.origin, to: view)
        let lowerLeftCorner = CGPoint(x: activeFieldOrigin.x, y: activeFieldOrigin.y + activeFieldHeight)
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var visibleRect = scrollView.frame
        visibleRect.size.height -= keyboardHeight
        
        if !visibleRect.contains(lowerLeftCorner) {
            let y = activeFieldOrigin.y - visibleRect.height
            let scrollPoint = CGPoint(x: 0, y: y)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
    }
    
    @IBAction func onSignUpButtonPress(_ sender: UIButton) {
        guard let name = nameTextField.text else {
            let alert = UIAlertController.alertWithTitle("Please enter name", message: "Missing name")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let email = userNameTextField.text else {
            let alert = UIAlertController.alertWithTitle("Please enter email", message: "Missing email")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let password = passwordTextField.text else {
            let alert = UIAlertController.alertWithTitle("Please enter Password", message: "Missing password")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard passwordTextField.text == retypePasswordTextField.text else {
            let alert = UIAlertController.alertWithTitle("Password Incorrect", message: "Please re-type password")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let profileImage = profileImageView.image, profileImage != #imageLiteral(resourceName: "default_user") else {
            let alert = UIAlertController.alertWithTitle("Error", message: "Please select a profile picture")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        userManager.uploadProfileImage(profileImage) { [weak self] result in
            switch result {
            case let .success(urlString):
                self?.userManager.createUser(withName: name, email: email, password: password, urlString: urlString) { result in
                    switch result {
                    case .success:
                        self?.authetificationSucceded()
                    case let .failure(error):
                        let alert = UIAlertController.alertWithTitle("Password Incorrect", message: error.localizedDescription)
                        self?.present(alert, animated: true, completion: nil)
                    }
                    
                }
            case let .failure(error):
                let alert = UIAlertController.alertWithTitle("Password Incorrect", message: error.localizedDescription)
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    var activeField: UITextField?
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            didSelectImage(editedImage)
        } else if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            didSelectImage(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
