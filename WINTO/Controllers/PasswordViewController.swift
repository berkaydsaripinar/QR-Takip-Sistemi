//
//  PasswordViewController.swift
//  TalkidoQR
//
//  Created by Berkay Sarıpınar on 20.07.2023.
//

import UIKit

class PasswordViewController: UIViewController {

    @IBOutlet weak var adminPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
   /* @IBAction func adminLoginButton(_ sender: Any) {
        if adminPasswordTextField.text == "canyildiz2023"{
            performSegue(withIdentifier: "adminVC", sender: nil)
        }else{
                let alert = UIAlertController(title: "HATA", message: "Şifre yanlış.", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            
            
        }
    }*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func dismissKeyboard() {
           view.endEditing(true)
       }
}
