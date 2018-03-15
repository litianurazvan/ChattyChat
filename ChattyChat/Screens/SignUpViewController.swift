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

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var rootReference: DatabaseReference!
    var usersReference: DatabaseReference!
    var rootStorageReference: StorageReference!
    var usersProfileImagesReference: StorageReference!
    
    
    @IBAction func onProfileImageTap(_ sender: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    lazy var didSelectImage: (UIImage) -> () = { [weak self] image in
        self?.profileImageView.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootStorageReference = Storage.storage().reference()
        usersProfileImagesReference = rootStorageReference.child("user-profile-images")
        rootReference = Database.database().reference()
        usersReference = rootReference.child("users")
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
                                           "profileImage": urlString])
                self?.performSegueWithIdentifier(.signUpToHome, sender: nil)
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
        guard let data = UIImagePNGRepresentation(profileImage) else { completion(nil); return }
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
