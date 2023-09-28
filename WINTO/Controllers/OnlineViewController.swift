//
//  OnlineViewController.swift
//  TalkidoQR
//
//  Created by Berkay Sarıpınar on 20.07.2023.
//

import UIKit
import Firebase
import FirebaseFirestore

class OnlineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: ARRAYS
    var emailArray = [String]()
    var hareketArray = [String]()
    var dateArray = [String]()
    var timeArray = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onlineFirebaseData()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    //MARK: TABLE VİEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hareketArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! OnlineTableViewCell
        
        cell.usernameLabel.text = emailArray[indexPath.row]
        cell.onlineLabel.text = hareketArray[indexPath.row]
        
        if cell.onlineLabel.text == "Giris"{
            cell.onlineLabel.text = "Ofiste"
            cell.onlineLabel.textColor = .systemGreen
        } else {
            cell.onlineLabel.text = "Ofiste Değil"
            cell.onlineLabel.textColor = .systemRed
        }
        return cell
    }
    
    
    //MARK: FİREBASE DATA FONKSİYONU
    func onlineFirebaseData() {
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Veri").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "Beklenmedik bir hata oluştu")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    var latestEntriesDict = [String: String]() // Her kullanıcı için en son işlemi tutacak bir sözlük oluştur
                    
                    for document in snapshot!.documents {
                        if let hareket = document.get("hareket") as? String,
                           let emailData = document.get("email") as? String,
                           let date = document.get("date") as? String{
                            
                            if hareket == "Giris" || hareket == "Çıkış" { //
                                let existingEntry = latestEntriesDict[emailData]
                                
                                // Kullanıcı için daha önce bir giriş yapılmış mı diye kontrol et
                                if existingEntry == nil || (date > existingEntry!) {
                                    latestEntriesDict[emailData] = date // En son işlemi güncelle
                                }
                            }
                        }
                    } // for döngüsü
                    
                    // Dizileri temizle ve en son işlemleri ekle
                    self.emailArray.removeAll()
                    self.hareketArray.removeAll()
                    self.dateArray.removeAll()
                    self.timeArray.removeAll()
                    // Sözlükteki en son işlemleri dizilere ekle
                    for (email, date) in latestEntriesDict {
                        self.emailArray.append(email)
                        if let hareket = snapshot!.documents.first(where: { $0.get("email") as? String == email && $0.get("date") as? String == date})?.get("hareket") as? String {
                            self.hareketArray.append(hareket)
                        }
                        self.dateArray.append(date)
                    }
                    
                    self.tableView.reloadData()
                } // Snapshot
            }
        }
    } // FirebaseData
    
    
}
//TODO: Bildirim olayına bir bak!
