import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

class LateComersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - DİZİLER
    var emailArray = [String]()
    var hareketArray = [String]()
    var dateArray = [String]()
    var timeArray = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // Seçilen tarih ve saat değişkenleri
    var selectedDate = Date()
    var selectedTime = Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // DatePicker'ı tarih ve saat için ayarla
        datePicker.timeZone = TimeZone(identifier: "Europe/Istanbul")
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        // Başlangıçta verileri çekelim
        onlineFirebaseData(afterTime: selectedTime, afterDate: selectedDate)
    }
    
    
    @IBAction func sorgulaButtonTapped(_ sender: UIButton) {
        // Güncel Date Picker değerlerini kullanarak Firebase sorgusu yap
        onlineFirebaseData(afterTime: selectedTime, afterDate: selectedDate)
    }
    // DatePicker'ın değeri değiştiğinde yapılacak işlemler
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        // Seçilen tarih ve saati ayrı ayrı al (yerel saat)
        let calendar = Calendar.current
        let selectedTimeComponents = calendar.dateComponents([.hour, .minute], from: sender.date)
        let selectedHour = selectedTimeComponents.hour ?? 0
        let selectedMinute = selectedTimeComponents.minute ?? 0
        
        // Seçilen saati güncelle (yerel saat)
        self.selectedTime = calendar.date(bySettingHour: selectedHour, minute: selectedMinute, second: 0, of: sender.date) ?? Date()
        
        // Sadece tarih değerini seçilen tarihe ayarla (yerel saat)
        self.selectedDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: sender.date) ?? Date()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hareketArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! LateComersTableViewCell
        cell.dateLabel.text = dateArray[indexPath.row]
        cell.timeLabel.text = timeArray[indexPath.row]
        cell.mailLabel.text = emailArray[indexPath.row]
        
        // Renk atama kodları
        switch cell.mailLabel.text {
        case "berkay@example.com":
            cell.mailLabel.textColor = .systemRed
        case "eren@example.com":
            cell.mailLabel.textColor = .systemBlue
        case "admin@example.com":
            cell.mailLabel.textColor = .systemMint
        case "dogancan@example.com":
            cell.mailLabel.textColor = .systemBrown
        default:
            cell.mailLabel.textColor = .systemPink
        }
        
        return cell
    }
    
    
    
    //MARK: - FİREBASE'DEN VERİ ÇEKME FONKSİYONU
    func onlineFirebaseData(afterTime selectedTime: Date, afterDate selectedDate: Date) {
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Veri").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let documents = snapshot?.documents {
                    var filteredData = [(email: String, hareket: String, date: String, time: String)]()
                    
                    let turkeyTimeZone = TimeZone(identifier: "Europe/Istanbul")
                    let dateFormatter = DateFormatter()
                    let timeFormatter = DateFormatter()
                    
                    dateFormatter.timeZone = turkeyTimeZone
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    timeFormatter.timeZone = turkeyTimeZone
                    timeFormatter.dateFormat = "HH:mm:ss"
                    
                    let calendar = Calendar.current
                    let selectedTimeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
                    let selectedHour = selectedTimeComponents.hour ?? 0
                    let selectedMinute = selectedTimeComponents.minute ?? 0
                    let selectedDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                    
                    for document in documents {
                        if let hareket = document.get("hareket") as? String,
                           let date = document.get("date") as? String,
                           let time = document.get("time") as? String {
                            
                            if hareket == "Giris" {
                                let entryTime = timeFormatter.date(from: time) ?? Date()
                                let entryDate = dateFormatter.date(from: date) ?? Date()
                                
                                // entryTime'in saatini ve dakikasını al
                                let entryTimeComponents = calendar.dateComponents([.hour, .minute], from: entryTime)
                                let entryHour = entryTimeComponents.hour ?? 0
                                let entryMinute = entryTimeComponents.minute ?? 0
                                
                                // entryDate'i yerel saat dilimine çevir
                                let correctedEntryDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: entryDate) ?? Date()
                                let timeZoneOffset = turkeyTimeZone?.secondsFromGMT(for: correctedEntryDate) ?? 0
                                
                                // entryHour'u yerel saat dilimine çevir
                                // let correctedEntryHour = (entryHour + (timeZoneOffset / 3600) + 24) % 24
                                
                                // Seçilen zaman dilimiyle ve tarihle karşılaştır
                                if (entryDate > selectedDate) || (entryDate == selectedDate && (entryHour > selectedHour || (entryHour == selectedHour && entryMinute >= selectedMinute))) {
                                    if let email = document.get("email") as? String {
                                        filteredData.append((email, hareket, date, time))
                                    }
                                }else {
                                    self.hataMesaji(titleInput: "Kayıt yok", messageInput: "Seçtiğin tarih ve seçtiğin saat dikkate alındığında, işe geç giriş tespit edilemedi.")
                                }
                            }
                        }
                    }
                    
                    // Update the arrays with the filtered data
                    self.emailArray = filteredData.map { $0.email }
                    self.hareketArray = filteredData.map { $0.hareket }
                    self.dateArray = filteredData.map { $0.date }
                    self.timeArray = filteredData.map { $0.time }
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    // Firebase
    
    
    func hataMesaji(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}

extension Date {
    func withTimeZone(tz: TimeZone) -> Date {
        let formatter = DateFormatter()
        let tz = TimeZone(identifier: "Europe/Istanbul")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = tz
        let dateString = formatter.string(from: self)
        return formatter.date(from: dateString) ?? self
    }
}
