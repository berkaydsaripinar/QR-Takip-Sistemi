import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import PDFGenerator

class ControlViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - VİEWS AND LABELS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var documentInteractionController: UIDocumentInteractionController?
    
    
    //MARK: - ARRAYS
    var emailArray = [String]()
    var hareketArray = [String]()
    var dateArray = [String]()
    var timeArray = [String]()
    var uniqueEmailArray = [String]() // Tekrarlanan e-postaların engellenmiş hali
    var filteredData: [(email: String, hareket: String, dateTime: String, time: String)] = [] // Filtrelenmiş verilerin saklandığı dizi
    var selectedEmail: String? // Seçilen e-postayı pickerView'dan saklamak için değişken
    var selectedTimeFilter: TimeFilter = .all // Seçilen zaman filtresi
    
    enum TimeFilter: Int {
        case all = 0
        case oneMonth = 1
        case oneWeek = 2
        case today = 3
    }
    let dateFormatter: DateFormatter = {
        let turkeyTimeZone = TimeZone(identifier: "Europe/Istanbul")
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = turkeyTimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        print(" ve \(formattedDate)")
        return dateFormatter
    }()
    let timeFormatter: DateFormatter = {
        let turkeyTimeZone = TimeZone(identifier: "Europe/Istanbul")
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = turkeyTimeZone
        timeFormatter.dateFormat = "HH:mm:ss"
        let currentDate = Date()
        let formattedTime = timeFormatter.string(from: currentDate)
        print("\(formattedTime) ve ")
        return timeFormatter
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        firebaseData()
    }
    
    //MARK: - SEGMENTED CONTROL ACTION
    @IBAction func timeFilterChanged(_ sender: UISegmentedControl) {
        // Seçilen zaman filtresini güncelle
        selectedTimeFilter = TimeFilter(rawValue: sender.selectedSegmentIndex) ?? .all
        
        // Tabloyu güncellemek için verileri filtrele
        timeFilterTableData(selectedEmail)
        tableView.reloadData()
    }
    
    //MARK: TABLE VIEW AND PICKER VIEW
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let data = filteredData[indexPath.row]
        cell.mailLabel.text = data.email
        cell.dateTimeLabel.text = data.dateTime
        cell.timeLabel.text = data.time
        cell.moveLabel.text = data.hareket
        cell.infoLabel.titleLabel?.text = data.hareket
        
        if cell.moveLabel.text == "Giris" {
            cell.moveLabel.textColor = .white
            cell.moveLabel.backgroundColor = .systemGreen
            cell.infoLabel.titleLabel?.text = "Giriş"
            cell.infoLabel.tintColor = .systemGreen
        } else {
            cell.moveLabel.textColor = .systemRed
            cell.infoLabel.titleLabel?.text = "Çıkış"
            cell.infoLabel.tintColor = .systemRed
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return uniqueEmailArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return uniqueEmailArray[row]
    }
    
    //MARK: - PICKER VIEW METHOD
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedEmail = uniqueEmailArray[row]
        filterTableData(selectedEmail)
    }
    
    
    //MARK: - FIREBASE DATA FONKSİYONU
    func firebaseData() {
        let firestoreDatabase = Firestore.firestore()
        let query = firestoreDatabase.collection("Veri").order(by: "date", descending: true)
        
        query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Beklenmedik bir hata oluştu: \(error.localizedDescription)")
            } else {
                self.emailArray.removeAll()
                self.hareketArray.removeAll()
                self.dateArray.removeAll()
                self.timeArray.removeAll() // Eklediğimiz yeni zaman array'i
                
                for document in snapshot!.documents {
                    if let hareket = document.get("hareket") as? String,
                       let date = document.get("date") as? String,
                       let time = document.get("time") as? String, // Yeni zaman alanı
                       let emailData = document.get("email") as? String
                    {
                        self.hareketArray.append(hareket)
                        self.dateArray.append(date)
                        self.timeArray.append(time) // Yeni zaman array'i
                        self.emailArray.append(emailData)
                    }
                }
                
                // Tekrarlanan e-postaları kaldır ve uniqueEmailArray'e ekle
                self.uniqueEmailArray = Array(Set(self.emailArray))
                self.pickerView.reloadAllComponents()
                self.filterTableData(self.selectedEmail) // Tabloyu başlangıçta tüm verilerle doldur
            }
        }
    }
    //MARK: - TABLE DATA FILTERING
    func filterTableData(_ selectedEmail: String?) {
        if let selectedEmail = selectedEmail {
            // Eğer seçilen bir e-posta varsa, sadece o e-postaya ait verileri filteredData'ya aktar
            filteredData = emailArray.indices.compactMap { index in
                emailArray[index] == selectedEmail ? (email: emailArray[index], hareket: hareketArray[index], dateTime: dateArray[index],time: timeArray[index]) : nil
            }
        } else {
            // Eğer seçilen e-posta yoksa, tüm verileri filteredData'ya aktar
            filteredData = emailArray.indices.map { (email: emailArray[$0], hareket: hareketArray[$0], dateTime: dateArray[$0],time: timeArray[$0])}
        }
        
        tableView.reloadData()
    }
    
    //MARK: - TIME FILTERING
    func timeFilterTableData(_ selectedEmail: String?) {
        var filteredItems: [(email: String, hareket: String, dateTime: String, time:String)] = []
        
        // Seçilen zaman filtresine göre verileri filtrele
        for (index, dateTime) in dateArray.enumerated() {
            guard let date = dateFormatter.date(from: dateTime),
                  let time = timeFormatter.date(from: timeArray[index]) else { continue }
            switch selectedTimeFilter {
            case .all:
                // Tüm verileri ekle
                filteredItems.append((email: emailArray[index], hareket: hareketArray[index], dateTime: dateTime, time: timeArray[index]))
            case .oneMonth:
                // Son bir ay içindeki verileri ekle
                if isDateTimeWithinOneMonth(date, time) {
                    filteredItems.append((email: emailArray[index], hareketArray[index], dateTime: dateTime, time: timeArray[index]))
                }
            case .oneWeek:
                // Son bir hafta içindeki verileri ekle
                if isDateTimeWithinOneWeek(date, time) {
                    filteredItems.append((email: emailArray[index], hareketArray[index], dateTime: dateTime, time: timeArray[index]))
                }
            case .today:
                // Bugünün verilerini ekle
                if isDateTimeToday(date, time) {
                    filteredItems.append((email: emailArray[index], hareketArray[index], dateTime: dateTime, time: timeArray[index]))
                }
            }
        }
        
        // E-posta filtresi de uygulanırsa, e-postaya göre filtrele
        if let selectedEmail = selectedEmail {
            filteredData = filteredItems.filter { $0.email == selectedEmail }
        } else {
            filteredData = filteredItems
        }
        
        tableView.reloadData()
    }
    
    //MARK: - DATE HELPER FUNCTIONS
    func isDateTimeWithinOneMonth(_ date: Date, _ time: Date) -> Bool {
        // Tarih ve saatin bir ay içinde olup olmadığını kontrol etmek için gerekli işlemleri yap
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return date >= oneMonthAgo
    }
    
    func isDateTimeWithinOneWeek(_ date: Date, _ time: Date) -> Bool {
        // Tarih ve saatin bir hafta içinde olup olmadığını kontrol etmek için gerekli işlemleri yap
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return date >= oneWeekAgo
    }
    
    func isDateTimeToday(_ date: Date, _ time: Date) -> Bool {
        // Tarihin ve saatin bugün olup olmadığını kontrol etmek için gerekli işlemleri yap
        let calendar = Calendar.current
        return calendar.isDateInToday(date) && calendar.isDateInToday(time)
    }
}

