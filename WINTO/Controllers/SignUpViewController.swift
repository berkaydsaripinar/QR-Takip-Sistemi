//
//  SignUpViewController.swift
//  TalkidoQR
//
//  Created by Berkay Sarıpınar on 15.09.2023.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var managerNameTextField: UITextField!
    @IBOutlet weak var managerTelTextField: UITextField!
    @IBOutlet weak var maanagerMailTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpButton(_ sender: Any) {
      
          
        }
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
}
