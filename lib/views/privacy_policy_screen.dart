import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası'),
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
                'Gizlilik Politikası',
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
                '1. Giriş',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Tripaz olarak, gizliliğinizi korumayı taahhüt ediyoruz. Bu Gizlilik Politikası, uygulamamızı kullandığınızda hangi bilgileri topladığımızı, bu bilgileri nasıl kullandığımızı ve koruduğumuzu açıklar.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '2. Topladığımız Bilgiler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Kişisel bilgiler: Adınız, e-posta adresiniz, telefon numaranız, adresiniz ve ödeme bilgileriniz gibi kişisel bilgileri toplarız.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '3. Bilgilerin Kullanımı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Topladığımız bilgileri şu amaçlarla kullanırız:\n\n- Hizmetlerimizi sağlamak ve iyileştirmek\n- Rezervasyonlarınızı işlemek ve yönetmek\n- Müşteri desteği sağlamak\n- Uygulamayı geliştirmek ve kullanıcı deneyimini iyileştirmek',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '4. Bilgilerin Paylaşımı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Bilgilerinizi şu taraflarla paylaşabiliriz:\n\n- Tur operatörleri ve hizmet sağlayıcıları: Rezervasyonunuzu tamamlamak için gerekli bilgileri paylaşırız\n- Hizmet sağlayıcılarımız: Ödeme işlemcileri, bulut depolama sağlayıcıları gibi hizmetleri yürütmemize yardımcı olan şirketler\n- Yasal gereklilikler: Yasal bir yükümlülüğe uymak için bilgilerinizi paylaşabiliriz',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '5. Veri Güvenliği',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Kişisel bilgilerinizi korumak için çeşitli güvenlik önlemleri uyguluyoruz. Verileriniz, şifreleme teknolojileri ve erişim kontrolleri ile korunmaktadır.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '6. Haklarınız',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Kişisel verilerinizle ilgili aşağıdaki haklara sahipsiniz:\n\n- Bilgilerinize erişim talep etme\n- Bilgilerinizin düzeltilmesini talep etme\n- Bilgilerinizin silinmesini talep etme\n- İşlemeye itiraz etme\n- Veri taşınabilirliği talep etme',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '7. İletişim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Gizlilik uygulamalarımızla ilgili sorularınız veya endişeleriniz varsa, lütfen info@tripaz.az adresinden bizimle iletişime geçin.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
