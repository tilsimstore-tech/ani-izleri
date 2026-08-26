import java.util.Properties
import java.io.FileInputStream

// 1. Ekleme: Özellikleri yükle
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "store.tilsim.ani_izleri"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "30.0.14904198"

    // 2. Ekleme: İmzalama konfigürasyonu
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            val storeFileValue = keystoreProperties.getProperty("storeFile")
            if (storeFileValue != null) {
                storeFile = file(storeFileValue)
            }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "store.tilsim.ani_izleri"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 3. Değişiklik: Debug yerine yeni oluşturduğumuz release konfigürasyonunu kullan
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}