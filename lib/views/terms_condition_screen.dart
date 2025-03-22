import 'package:flutter/material.dart';

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanım Koşulları'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kullanım Koşulları',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Son Güncelleme: 1 Temmuz 2023',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '1. Genel Kabul',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Tripaz uygulamasını kullanarak, bu Kullanım Koşullarını okuduğunuzu, anladığınızı ve kabul ettiğinizi beyan etmiş olursunuz. Bu koşullar, Tripaz mobil uygulaması ("Uygulama") aracılığıyla sunulan tüm hizmetler için geçerlidir.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '2. Hizmet Tanımı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Tripaz, kullanıcılara seyahat ve tur rezervasyonu yapma imkanı sunan bir platformdur. Uygulama üzerinden tur paketleri inceleyebilir, rezervasyon yapabilir ve ödeme işlemleri gerçekleştirebilirsiniz.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '3. Kullanıcı Hesapları',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Uygulama hizmetlerinden tam olarak yararlanabilmek için bir hesap oluşturmanız gerekir. Hesap bilgilerinizin gizliliğinden ve güvenliğinden siz sorumlusunuz. Hesabınızla ilgili herhangi bir yetkisiz kullanım fark ettiğinizde, bizi derhal bilgilendirmelisiniz.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '4. Rezervasyonlar ve Ödemeler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Uygulama üzerinden yapılan tüm rezervasyonlar, ilgili tur sağlayıcısının müsaitlik durumuna tabidir. Ödeme işlemleri, güvenli ödeme altyapımız üzerinden gerçekleştirilir. İptal ve iade politikaları, seçilen tur paketine göre değişiklik gösterebilir.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '5. Değişiklikler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Bu Kullanım Koşullarını herhangi bir zamanda değiştirme hakkını saklı tutarız. Değişiklikler, Uygulama üzerinden duyurulacaktır ve yayınlandıktan sonra geçerli olacaktır.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '6. İletişim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Bu Kullanım Koşulları ile ilgili sorularınız için info@tripaz.az adresinden bizimle iletişime geçebilirsiniz.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
