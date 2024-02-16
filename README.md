# Parakolay Dart SDK

Parakolay Dart SDK, Dart dilinde yazılmış ve [Parakolay](https://www.parakolay.com) ödeme servisleri ile kolayca entegrasyon sağlayan bir kütüphanedir. Bu SDK, kart tokenizasyonu, 3D Secure ile ödeme başlatma ve ödeme tamamlama işlemlerini kolay bir şekilde gerçekleştirmenize olanak tanır.

## Özellikler

- Kart Tokenizasyonu
- 3D Secure ile Ödeme Başlatma
- Ödeme Sonucunun Sorgulanması
- Ödeme İşleminin Tamamlanması

## Başlarken

Bu SDK'yı kullanabilmek için, [Parakolay](https://www.parakolay.com) tarafından sağlanan bir API anahtarı ve gizli anahtara ihtiyacınız olacaktır.

### Gereksinimler

- Dart 3.2.0 veya üzeri
- crypto 3.0.3
- http 1.2.0
- webview eklentisi

### Kurulum

Bu kütüphaneyi projenize dahil etmek için, `pubspec.yaml` dosyanıza aşağıdaki bağımlılığı ekleyin:

```yaml
dependencies:
  parakolay:
    path: ../
```

## Örnek Uygulama Kullanımı

Bu bölüm, Flutter tabanlı bir mobil uygulamada Parakolay Dart SDK'sının nasıl kullanılacağını göstermektedir. Bu örnekte, bir kullanıcının kart bilgilerini kullanarak 3D Secure ile ödeme işlemi başlatma ve tamamlama işlemleri ele alınmaktadır.

### Ön Koşullar

Bu örnek uygulamayı çalıştırabilmek için, Flutter'ın sisteminizde kurulu olması gerekmektedir.

### Uygulama Kodu

Örnek uygulama, kullanıcıya 3D Secure ile ödeme işlemi başlatma ve tamamlama seçenekleri sunan basit bir Flutter uygulamasıdır.

### Ödeme İşlemi Başlatma

Kullanıcı, ödeme işlemine başlarken, `init3Ds` fonksiyonu çağrılır ve kullanıcının kart bilgileri kullanılarak 3D Secure işlemi başlatılır. Başlatılan işlem sonucunda alınan HTML içeriği, uygulama içi bir web görünümünde kullanıcıya gösterilir.

### Ödeme İşlemi Tamamlama

Kullanıcı 3D Secure işlemini tamamladıktan sonra, webview geri dönüşünde işlemini sonlandıracaktır. Bu işlem, `complete3DS` fonksiyonu aracılığıyla gerçekleştirilir ve ödeme sonucu konsola yazdırılır.

### Test ve Geliştirme

Bu örnek uygulamayı geliştirirken, Parakolay API'sinin test modunu kullanarak gerçek ödeme yapmadan işlemlerinizi test edebilirsiniz.

## Destek ve Katkıda Bulunma

Bu kütüphane ile ilgili sorunlarınız veya önerileriniz varsa, lütfen GitHub üzerinden bir issue açın. Ayrıca, kütüphaneye katkıda bulunmak istiyorsanız, pull request'lerinizi bekliyoruz.


## Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.