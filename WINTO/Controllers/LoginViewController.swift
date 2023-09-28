//
//  LoginViewController.swift
//  TalkidoQR
//
//  Created by Berkay Sarıpınar on 13.08.2023.
//

import UIKit
import SwiftQRScanner
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import AudioToolbox

class LoginViewController: UIViewController {
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var sifreTextField: UITextField!
    @IBOutlet weak var loginImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func girisButton(_ sender: Any) {
        if mailTextField.text != "" || sifreTextField.text != "" {
            Auth.auth().signIn(withEmail: mailTextField.text!, password: sifreTextField.text!) { [self] authdataresult, error in
                if error != nil {
                    self.hataMesaji(titleInput: "Dikkat", messageInput: "Beklenmedik bir hata oluştu ya da kullanıcı adı ve şifre geçerli değil. Yönetici ile iletişime geçin.")
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                } else {
                    performSegue(withIdentifier: "login", sender: nil)
                }
            }
        }
        else {
            hataMesaji(titleInput: "Dikkat", messageInput: "Kullanıcı adı veya şifre alanı boş!")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    // Klavyeyi Kapatma
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Hata Mesajı Gösterme
    func hataMesaji(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
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
