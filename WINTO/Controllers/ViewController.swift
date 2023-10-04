//
//
//Berkay Sarıpınar
//
//
import UIKit
import SwiftQRScanner
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import AudioToolbox
import CoreImage


class QRCodeGenerator {
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let context = CIContext()
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}



class ViewController: UIViewController, QRScannerCodeDelegate {
    
    
    // Değişkenler
    @IBOutlet weak var bilgiLabel: UILabel!
    @IBOutlet weak var adminBtn: UIButton!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    var selectedButtonType: String?
    var timer: Timer?
    var lastGeneratedUUID: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        checkUserVisibility()
        
        startQRCodeGenerationTimer()
        
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "exitVC", sender: nil)
        } catch{
            print("Hata")
        }
    }
    @IBAction func girdiButtonPressed(_ sender: Any) {
        selectedButtonType = "Giris"
        scanQRCode((Any).self)
    }
    
    @IBAction func ciktiButtonPressed(_ sender: Any) {
        selectedButtonType = "Çıkış"
        scanQRCode((Any).self)
    }
    
    func startQRCodeGenerationTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2 * 60, target: self, selector: #selector(generateNewQRCode), userInfo: nil, repeats: true)
        timer?.fire() // İlk QR kodu hemen üret
        
    }
    
    @objc func generateNewQRCode() {
        let uuid = UUID().uuidString
        lastGeneratedUUID = uuid
        
        let qrCodeData = "BDS-" + uuid
        if let qrCodeImage = QRCodeGenerator.generateQRCode(from: qrCodeData) {
            let resizedImage = resizeImage(image: qrCodeImage, targetSize: CGSize(width: 250 , height: 160)) // Ayarlamak istediğiniz boyutu burada belirtebilirsiniz
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.qrCodeImageView.image = resizedImage
                self.bilgiLabel.text = ""
                
            }
            bilgiLabel.text = "Yeni QR Kod Oluşturuluyor"
            bilgiLabel.textColor = .systemBlue
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return newImage
    }
    
    
    //MARK: QR Kodu Tarayıcı ve Firebase Bağlantı Kodları
    @IBAction func scanQRCode(_ sender: Any) {
        let scanner = QRCodeScannerController()
        scanner.delegate = self
        self.present(scanner, animated: true, completion: nil)
    }
    
    // QR Kodu Tarayıcı Delegate
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("QR kod tarayıcı iptal edildi.")
    }
    
    
    func qrScannerDidFail(_ controller: UIViewController, error: SwiftQRScanner.QRCodeError) {
        print("QR kod tarayıcı çalışmadı  ya da kapandi")
        
    }
    
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        if let selectedType = selectedButtonType {
            let turkeyTimeZone = TimeZone(identifier: "Europe/Istanbul")
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            
            dateFormatter.timeZone = turkeyTimeZone
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            timeFormatter.timeZone = turkeyTimeZone
            timeFormatter.dateFormat = "HH:mm:ss"
            
            let currentDate = Date()
            let formattedDate = dateFormatter.string(from: currentDate)
            let formattedTime = timeFormatter.string(from: currentDate)
            
            let qrCodePrefix = "BDS-" // QR Kodun bize ait olduğunu anlamak için, QR Kod başlangıcına BDS başlangıcı ekliyorum.
            
            if result.starts(with: qrCodePrefix) {
                let uuid = result.replacingOccurrences(of: qrCodePrefix, with: "")
                
                if uuid == lastGeneratedUUID {
                    bilgiLabel.text = "Bu QR kod zaten kullanıldı!"
                    bilgiLabel.textColor = .systemRed
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                } else {
                    // Firebase kayıt işlemleri
                    if let currentUserEmail = Auth.auth().currentUser?.email {
                        let hareket = selectedType
                        let firestoreDatabase = Firestore.firestore()
                        let firebaseData = [
                            "email": currentUserEmail,
                            "date": formattedDate,
                            "time": formattedTime,
                            "hareket": hareket
                        ]
                        
                        firestoreDatabase.collection("Veri").addDocument(data: firebaseData) { error in
                            if let error = error {
                                self.hataMesaji(titleInput: "Hata!", messageInput: "Veritabanı ile iletişimde sorun yaşadık. Hata: \(error.localizedDescription)")
                            } else {
                                self.bilgiLabel.text = "Kod başarıyla okundu ve veritabanına kaydedildi."
                                self.bilgiLabel.textColor = .systemGreen
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                self.hataMesaji(titleInput: "", messageInput: "Yeni QR Kod Üretiiyor.")
                                
                                
                            }
                        }
                    }
                }
            } else {
                bilgiLabel.text = "Geçerli bir QR kod değil!"
                bilgiLabel.textColor = .systemRed
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }
    
    // Klavyeyi Kapatma
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: Hata Mesajı Gösterme
    func hataMesaji(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Yönetici Kontrolü
    
    func checkUserVisibility() {
        if let currentUser = Auth.auth().currentUser {
            let userEmailAddress = currentUser.email
            if userEmailAddress == "admin@example.com"{
                adminBtn.isEnabled = true
                qrCodeImageView.isHidden = false
            }
            else if userEmailAddress == "berkay@example.com"{
                adminBtn.isEnabled = true
              //  qrCodeImageView.image = UIImage.init(systemName: "person.crop.circle.dashed.circle")
            }
            else if userEmailAddress == "eren@example.com"{
                adminBtn.isEnabled = false
                qrCodeImageView.isHidden = false
                
            }
            else {adminBtn.isEnabled = false
                qrCodeImageView.isHidden = true
            }
        }
    }//checkUserVisibility
    
}
