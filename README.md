
# Ofis Uygulaması - Ofiste Kim Var?

Bu uygulama, küçük ve orta ölçekli şirketler için özel olarak tasarlanmış bir QR kod sistemi içerir. Kullanıcılar giriş ve çıkış işlemleri için QR kodlarını tarayabilirler. Ayırca anlık olarak ofiste olanları görüntülebilirler.

## Başlangıç

Bu uygulamayı yerel bir geliştirme ortamında çalıştırmak için aşağıdaki adımları izleyebilirsiniz.

### Gereksinimler

- [Xcode](https://developer.apple.com/xcode/)
- Firebase projesi ve Firebase konfigürasyon dosyası (Google Firebase kullanımı için)
- [SwiftQRScanner](https://github.com/vinodiOS/SwiftQRCodeScanner) kütüphanesi( Kütüphanenin default ekranında, "upload photo" butonu olacaktır. Güvenlik sebebiyle bu butonun silinmesi gerekir. Kütüphanenin delegate dosyalarına giderek, butonu kaldırabilirsiniz.) 

### Kurulum

1. Bu projeyi klonlayın.
   ```sh
   git clone https://github.com/berkaydsaripinar/QR-Kod-Takip-Sistemi.git
Firebase konfigürasyon dosyasını ekleyin.

Firebase projesi oluşturun ve konfigürasyon dosyasını Xcode projesine ekleyin.
SwiftQRScanner kütüphanesini ekleyin.

Projeye SwiftQRScanner'ı entegre edin.
Projeyi Xcode'da açın ve başlatın.

### Kullanım
Uygulamada, giriş veya çıkış yapmak istediğinizde ilgili düğmeye basın ve bir QR kod tarayıcısı açılacaktır.
Tarayıcı, geçerli bir QR kod taraması yaparsa, Firebase veritabanına bir kayıt ekler. 
Ayrıca Ofiste Kim Var ekranından anlık olarak ofiste olanlar görüntülünebilir, giriş ve çıkış kayıtları yönetici panelinden kontrol edilebilir ve filtrelenebilir.
### Katkıda Bulunma
Katkıda bulunmak isterseniz, lütfen bir sorun bildirin veya bir istek gönderin. Katkılarınızı memnuniyetle karşılarız.


#  Sayfalar ve Açıklamaları
### ControlViewController
ControlViewController, kullanıcıların giriş ve çıkışlarını izlemek ve bu verileri filtrelemek için kullanılır. Aşağıda bu View Controller'ın nasıl kullanılacağına dair örnek bir açıklama:


#### ControlViewController

**Açıklama:** ControlViewController, kullanıcıların ofise giriş ve çıkışlarını izlemek ve bu verileri filtrelemek için kullanılır. Kullanıcılar, tarih ve saat filtreleriyle girişleri ve çıkışları sorgulayabilirler.

**Nasıl Kullanılır:**

1. Uygulamayı başlatın ve bir admin kullanıcıyla giriş yaparak Admin Paneline erişin.
2. Ekrandaki PickerView ile izlemek istediğiniz e-postayı seçin.
3. Zaman aralığı filtresini UISegmentedControl ile ayarlayın (Tümü, Bir Ay, Bir Hafta, Bugün gibi).
4. Veriler otomatik olarak güncellenecek ve seçilen e-postaya ve zaman aralığına göre filtrelenmiş olacak.
5. TableView'da sonuçları görüntüleyin.


#### Ekran Görüntüleri:
![controlViewController](https://github.com/berkaydsaripinar/talkidoQR2023/assets/115491611/f469bcae-be03-4abe-9145-d0b588b20e7c)



### OnlineViewController

**OnlineViewController**, kullanıcıların anlık durumlarını izlemek için kullanılır. 


#### OnlineViewController

**Açıklama:** OnlineViewController, kullanıcıların anlık durumlarını (ofiste mi, dışarıda mı) izlemek için kullanılır. Kullanıcılar, her kullanıcının anlık durumunu görebilirler.

**Nasıl Kullanılır:**

1. Uygulamayı başlatın ve Ofiste Kim Var ekranına erişin.
2. TableView'da kullanıcıların anlık durumlarını görüntüleyin.
3. "Giriş" durumundaysa, kullanıcı ofiste demektir. "Çıkış" durumundaysa, kullanıcı ofiste değil demektir.

Örnek kod:

```swift
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! OnlineTableViewCell
        
        cell.usernameLabel.text = emailArray[indexPath.row] // Firebase'den çektiğimiz verileri Array'e atmıştık.
        cell.onlineLabel.text = hareketArray[indexPath.row] // Firebase'den çektiğimiz verileri Array'e atmıştık.
        
        if cell.onlineLabel.text == "Giris"{
            cell.onlineLabel.text = "Ofiste"
            cell.onlineLabel.textColor = .systemGreen
        } else {
            cell.onlineLabel.text = "Ofiste Değil"
            cell.onlineLabel.textColor = .systemRed
        }
        return cell
    }
```
#### Ekran Görüntüsü:
![ofisteKimVar](https://github.com/berkaydsaripinar/talkidoQR2023/assets/115491611/4faad26f-5912-4ffa-ab52-9c4d4b5abb78)


### LateComersViewController

**LateComersViewController**, geç giriş yapan kullanıcıları izlemek için kullanılır. Yalnızca yöneticiler erişebilir.


#### LateComersViewController

**Açıklama:** LateComersViewController, geç giriş yapan kullanıcıları tespit etmek için kullanılır. Kullanıcılar, tarih ve saat filtreleriyle geç giriş yapanları görüntüleyebilirler.

**Nasıl Kullanılır:**

1. Uygulamayı başlatın ve bir admin kullanıcısıyla giriş yaparak, Admin Paneli'ne erişin.
2. DatePicker ile izlemek istediğiniz tarihi ve saati seçin.
3. "Sorgula" düğmesine tıklayın ve geç giriş yapan kullanıcıları görüntüleyin.


#### Ekran Görüntüsü:
![gecGiris](https://github.com/berkaydsaripinar/talkidoQR2023/assets/115491611/f218a15b-72e7-4850-85cb-10e36d464267)

#### LoginViewController

**Açıklama:** LoginViewController, uygulamanın giriş ekranıdır. Bu aşamada girilen mailler ve şifreler kullanıcılara yönetici tarafından manuel olarak oluşturulur.
Buradaki mail ve şifreye göre uygulama admin mi , kullanıcı mı olduğunu anlar. O sorguyu ViewController sayfasından şu fonksiyonla sağladım (Fonksiyon viewDidLoad içerisinde çağrılıyor.): 
```swift
 func checkUserVisibility() {
        if let currentUser = Auth.auth().currentUser {
            let userEmailAddress = currentUser.email
            if userEmailAddress == "admin@example.com"{
                adminBtn.isEnabled = true
                qrCodeImageView.isHidden = true
            }
            else if userEmailAddress == "berkay@example.com"{
                adminBtn.isEnabled = true
                qrCodeImageView.isHidden = true
            }
            else {adminBtn.isEnabled = false
                qrCodeImageView.isHidden = true
            }
        }
    }
```
#### Ekran Görüntüsü: 
![Simulator Screenshot - iPhone 8 - 2023-09-06 at 19 44 48](https://github.com/berkaydsaripinar/talkidoQR2023/assets/115491611/7375e84d-ded0-4f87-8c3a-961cdec36755)

# Yararlı Bilgiler: 
Genel olarak sınıfların nasıl çalıştıklarının açıklaması: 

### QRCodeGenerator Sınıfı

**generateQRCode(from string: String)** adında bir statik fonksiyon içerir.
Bu fonksiyon, girdi olarak bir metin alır.
Metni ASCII kodlamasına çevirir.
Bir QR kodu oluşturmak için **CIFilter** kullanır.
Oluşturulan QR kodunu bir **UIImage** olarak döndürür.

### ViewController Sınıfı

QR kodunu üretmek için **generateNewQRCode()** adında bir fonksiyon içerir.
QR kodu belirli bir süre aralığıyla otomatik olarak üretmek için bir zamanlayıcı kullanır.
Kullanıcı bir düğmeye tıkladığında QR kodu tarama işlemine başlatmak için **scanQRCode(_:)** adında bir fonksiyon içerir.
Tarayıcı tarafından okunan QR kodunu işlemek için **qrScanner(_:scanDidComplete:)** adında bir fonksiyon içerir.
QR kodu veritabanına kaydetmek için **Firebase** kullanır.
Kullanıcıları yönetici veya standart kullanıcı olarak ayırmak için Firebase kimlik doğrulamasını kullanır.

### ControlViewController Sınıfı

Kullanıcının tarih ve saat filtreleriyle verileri filtrelemesine olanak tanır.
Kullanıcılar arasında benzersiz e-postaları bulur ve bir **UIPickerView** ile bu e-postaları listeleyerek seçmelerine izin verir.
Seçilen zaman filtresine göre Firebase'den veri çeker.
Firebase'den gelen verileri tarih ve saat filtrelerine göre filtreler ve tabloya ekler.

### OnlineViewController Sınıfı

Kullanıcıların çevrimiçi durumunu gösteren bir tabloyu Firebase'den veri çekerek doldurur.
Firebase'den alınan verileri kullanarak "Ofiste" veya "Ofiste Değil" olarak etiketler.

### LateComersViewController Sınıfı

Kullanıcının seçtiği tarih ve saatteki girişleri bulmak için Firebase'den veri çeker.
Kullanıcının belirtilen tarihe ve saate kadar giriş yapmadığını kontrol eder.

# Class Diyagramları

<h1>QRCodeGenerator Sınıfı</h1>
<table border="1">
    <tr>
        <th>Özellikler (Properties)</th>
        <th>Metodlar (Methods)</th>
    </tr>
    <tr>
        <td>None</td>
        <td>
            <ul>
                <li>generateQRCode(from string: String) -> UIImage</li>
            </ul>
        </td>
    </tr>
</table>

<h1>ViewController Sınıfı</h1>
<table border="1">
    <tr>
        <th>Özellikler (Properties)</th>
        <th>Metodlar (Methods)</th>
    </tr>
    <tr>
        <td>None</td>
        <td>
            <ul>
                <li>generateNewQRCode()</li>
                <li>scanQRCode(_:)</li>
                <li>qrScanner(_:scanDidComplete:)</li>
            </ul>
        </td>
    </tr>
</table>

<h1>ControlViewController Sınıfı</h1>
<table border="1">
    <tr>
        <th>Özellikler (Properties)</th>
        <th>Metodlar (Methods)</th>
    </tr>
    <tr>
        <td>
            <ul>
                <li>emailArray: [String]</li>
                <li>hareketArray: [String]</li>
                <li>dateArray: [String]</li>
                <li>timeArray: [String]</li>
                <li>uniqueEmailArray: [String]</li>
                <li>filteredData: [(email: String, hareket: String, dateTime: String, time: String)]</li>
                <li>selectedEmail: String?</li>
                <li>selectedTimeFilter: TimeFilter</li>
            </ul>
        </td>
        <td>
            <ul>
                <li>timeFilterChanged(_:)</li>
                <li>tableView(_:cellForRowAt:)</li>
                <li>tableView(_:numberOfRowsInSection:)</li>
                <li>numberOfComponents(in:)</li>
                <li>pickerView(_:numberOfRowsInComponent:)</li>
                <li>pickerView(_:titleForRow:forComponent:)</li>
                <li>pickerView(_:didSelectRow:inComponent:)</li>
                <li>viewDidLoad()</li>
                <li>firebaseData()</li>
                <li>filterTableData(_:)</li>
                <li>timeFilterTableData(_:)</li>
                <li>isDateTimeWithinOneMonth(_:_:)</li>
                <li>isDateTimeWithinOneWeek(_:_:)</li>
                <li>isDateTimeToday(_:_:)</li>
            </ul>
        </td>
    </tr>
</table>

<h2>İçsel Enum (Inner Enum)</h2>
<table border="1">
    <tr>
        <th>TimeFilter</th>
    </tr>
    <tr>
        <td>
            <ul>
                <li>all</li>
                <li>oneMonth</li>
                <li>oneWeek</li>
                <li>today</li>
            </ul>
        </td>
    </tr>
</table>

<h1>OnlineViewController Sınıfı</h1>
<table border="1">
    <tr>
        <th>Özellikler (Properties)</th>
        <th>Metodlar (Methods)</th>
    </tr>
    <tr>
        <td>
            <ul>
                <li>emailArray: [String]</li>
                <li>hareketArray: [String]</li>
                <li>dateArray: [String]</li>
                <li>timeArray: [String]</li>
            </ul>
        </td>
        <td>
            <ul>
                <li>viewDidLoad()</li>
                <li>onlineFirebaseData()</li>
 <li>tableView(_:numberOfRowsInSection:)</li>
                <li>tableView(_:cellForRowAt:)</li>
            </ul>
        </td>
    </tr>
</table>

<h1>LateComersViewController Sınıfı</h1>
<table border="1">
    <tr>
        <th>Özellikler (Properties)</th>
        <th>Metodlar (Methods)</th>
    </tr>
    <tr>
        <td>
            <ul>
                <li>emailArray: [String]</li>
                <li>hareketArray: [String]</li>
                <li>dateArray: [String]</li>
                <li>timeArray: [String]</li>
                <li>selectedDate: Date</li>
                <li>selectedTime: Date</li>
            </ul>
        </td>
        <td>
            <ul>
                <li>viewDidLoad()</li>
                <li>sorgulaButtonTapped(_:)</li>
                <li>datePickerValueChanged(sender:)</li>
                <li>tableView(_:numberOfRowsInSection:)</li>
                <li>tableView(_:cellForRowAt:)</li>
                <li>onlineFirebaseData(afterTime:afterDate:)</li>
                <li>hataMesaji(titleInput:messageInput:)</li>
            </ul>
        </td>
    </tr>
</table>

<i><b> Başarılar!</b></i>
