//
//  AuthViewController.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/07.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    @IBOutlet weak var emailBackView: UIView!
    @IBOutlet weak var pwBackView: UIView!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var googleImageView: UIImageView!
    @IBOutlet weak var appleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        keyboardGesture()
        googleImageViewTapped()
        appleImageViewTapped()
    }
    
    func keyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func configureUI() {
        backView.layer.cornerRadius = 10
        backView.clipsToBounds = false
        backView.layer.shadowColor = UIColor.darkGray.cgColor
        backView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backView.layer.shadowOpacity = 0.5
        backView.layer.shadowRadius = 4
        backView.backgroundColor = UIColor(hexCode: "F5F5F4")
        
        emailBackView.layer.cornerRadius = 15
        emailBackView.clipsToBounds = true
        emailBackView.layer.borderColor = UIColor.lightGray.cgColor
        emailBackView.layer.borderWidth = 1
        pwBackView.layer.cornerRadius = 15
        pwBackView.clipsToBounds = true
        pwBackView.layer.borderColor = UIColor.lightGray.cgColor
        pwBackView.layer.borderWidth = 1
        
        signInButton.backgroundColor = UIColor(hexCode: "F77D8D")
        signInButton.layer.cornerRadius = 20
        signInButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    @IBAction func SignInButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text, let password = pwTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                }
                else {
                    self.performSegue(withIdentifier: "SignInToHome", sender: self)
                }
            }
        }
    }
    
    func googleImageViewTapped() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(googleImageTapped))
        googleImageView.isUserInteractionEnabled = true
        googleImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func googleImageTapped() {
        print("구글 눌렸습니다.")
    }
    
    func appleImageViewTapped() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(appleImageTapped))
        appleImageView.isUserInteractionEnabled = true
        appleImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func appleImageTapped() {
        print("애플 눌렸습니다.")
    }
    

}

extension UIColor {
    
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}
