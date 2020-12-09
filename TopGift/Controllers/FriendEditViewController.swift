//
//  FriendEditViewController.swift
//  TopGift
//
//  Created by Micky on 19.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit

import os.log

class FriendEditViewController: UIViewController, UITextFieldDelegate,
                                UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var homeTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var genderTextField: UITextField!
    
    // MARK: Error Validation Labels
    @IBOutlet weak var fullNameErrorLabel: UILabel!
    
    var friend: NewFriend?
    
    @IBOutlet weak var lookForGiftIdeasBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        lookForGiftIdeasBtn.setTitle(NSLocalizedString("Look for clothing ideas", comment: ""), for: .normal)
        
        fullNameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        homeTextField.delegate = self
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // Set up views if editing an existing Friend.
        
        if let friend = friend {
            
            navigationItem.title = friend.fullName
            
            photoImageView.image = UIImage(data: friend.profileImage!)
            
            fullNameTextField.text = friend.fullName
            
            emailTextField.text = friend.email
            
            phoneTextField.text = friend.phoneNum
            
            emailTextField.text = friend.email
            
            homeTextField.text = friend.homeTown
            
            genderTextField.text = friend.gender
        }
        
        // Enable Save button only if text field has valid Meal name
        updateSaveButtonState()
        
        
        // Add check and display error delegates
        fullNameTextField.addTarget(self, action: #selector(checkAndDisplayError(textfield:)), for: .editingChanged)
    }
    
    deinit {
        // Stop listening for keyboard hide/show events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }
    
    @objc func checkAndDisplayError (textfield: UITextField) {
        
        if (textfield.text?.count ?? 0 <= 3) {
            fullNameErrorLabel.text = "Enter more than 3 characters."
        } else {
            fullNameErrorLabel.text = ""
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
        if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The FriendViewController is not inside a navigation controller.")
        }
    }
    
    // MARK: Validation
    
    private func updateSaveButtonState() {
        
        let text = fullNameTextField.text ?? ""
        
        saveButton.isEnabled = !text.isEmpty
    }
    
    // MARK: Actions
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        //  Set photoImageView to display the selected image.
        
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    // Hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = fullNameTextField.text
    }
    
    
    //  MARK: - Navigation
    
        // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //      Get the new view controller using segue.destination.
        //      Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem,
              button === saveButton else {
            
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        if let friend = friend {
            
            let identifier = UUID()
            
            friend.id = identifier
            
            friend.fullName = fullNameTextField.text
            
            // Create changedAt date
            let currentDateTime = Date()
            
            friend.changedAt = currentDateTime
            
            // Set new image for friend
            let jpg = photoImageView.image?.jpegData(compressionQuality: 0.75)
            
            friend.profileImage = jpg
            
            friend.email = emailTextField.text ?? "Not found."
            friend.phoneNum = phoneTextField.text ?? "Not found."
            friend.age = ageTextField.text
            friend.homeTown = homeTextField.text ?? "Not found."
            friend.gender = genderTextField.text ?? "Not found."
            
        } else {
            let newFriend = NewFriend(context: self.context)
            
            newFriend.fullName = fullNameTextField.text
            
            let identifier = UUID()
            
            newFriend.id = identifier
            
            // Create changedAt date
            let currentDateTime = Date()
            
            newFriend.changedAt = currentDateTime
            
            // Set new image for friend
            let jpg = photoImageView.image?.jpegData(compressionQuality: 0.75)
            newFriend.profileImage = jpg
            
            newFriend.email = emailTextField.text ?? "Not found."
            newFriend.phoneNum = phoneTextField.text ?? "Not found."
            newFriend.age = ageTextField.text ?? "Not found."
            newFriend.homeTown = homeTextField.text ?? "Not found."
            newFriend.gender = genderTextField.text ?? "Not found."
            
            friend = newFriend
        }
    }
}

