//
//  SignUpViewController.swift
//  FirebaseLogin
//
//  Created by Razvan Litianu on 09/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, SegueHandlerType {

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
    
    var rootReference = Database.database().reference()
    var usersReference: DatabaseReference {
        return rootReference.child("users")
    }
    
    var rootStorageReference = Storage.storage().reference()
    var usersProfileImagesReference: StorageReference {
        return rootStorageReference.child("user-profile-images")
    }
    
    var authetificationSucceded: ()->() = { }
    
    @IBAction func onProfileImageTap(_ sender: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    lazy var didSelectImage: (UIImage) -> () = { [weak self] image in
        self?.profileImageView.image = image
    }
    
    var observerShowKeyboard: NSObjectProtocol!
    var observerHideKeyboard: NSObjectProtocol!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observerShowKeyboard = NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: .main, using: keyboardWillShow(_:))
        observerHideKeyboard = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: .main, using: keyboardWillHide(_:))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(observerShowKeyboard)
        NotificationCenter.default.removeObserver(observerHideKeyboard)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func keyboardWillShow(_ notification: Notification) {
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
    
    fileprivate func createUser(withName name: String, email: String, password: String, urlString: String?) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] user, error in
            if let error = error {
                let alert = UIAlertController.alertWithTitle("Error", message: error.localizedDescription)
                self?.present(alert, animated: true, completion: nil)
            }
            
            if let user = user,
                let userRef = self?.usersReference.child(user.uid) {
                userRef.updateChildValues(["email": email,
                                           "name": name,
                                           "profileImage": urlString ?? ""
                    ])
                
                self?.authetificationSucceded()
            }
        })
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
        
        
        uploadProfileImage { [weak self] urlString in
            self?.createUser(withName: name,
                             email: email,
                             password: password,
                             urlString: urlString)
        }

    }
    
    func uploadProfileImage(completion: @escaping (String?)->()) {
        guard let profileImage = profileImageView.image, profileImage != #imageLiteral(resourceName: "default_user") else { completion(nil); return }
        guard let data = UIImageJPEGRepresentation(profileImage, 0.1) else { completion(nil); return }
        let imageStorageRef = usersProfileImagesReference.child("\(NSUUID().uuidString).png")
        
        imageStorageRef.putData(data, metadata: nil) { [weak self] metadata, error in
            if let error = error {
                let alert = UIAlertController.alertWithTitle("Error", message: error.localizedDescription)
                self?.present(alert, animated: true, completion: nil)
            }
            
            if let imageUrlString = metadata?.downloadURL()?.absoluteString {
                completion(imageUrlString)
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
