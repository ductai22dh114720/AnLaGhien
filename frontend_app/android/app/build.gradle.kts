import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Đọc các khóa bí mật từ tệp local.properties
val localProperties = Properties()
val localPropertiesFile = rootProject.file("android/local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

fun com.android.build.api.dsl.ApplicationExtension.configureDefaultConfig() {
    // Lấy giá trị từ tệp local.properties hoặc từ biến môi trường
    val googleMapsApiKey = localProperties.getProperty("GOOGLE_MAPS_API_KEY") ?: System.getenv("GOOGLE_MAPS_API_KEY")

    // Thêm khóa API vào BuildConfig để mã Java/Kotlin có thể truy cập nếu cần
    buildConfigField("String", "GOOGLE_MAPS_API_KEY", "\"$googleMapsApiKey\"")

    // Cung cấp giá trị cho placeholder trong AndroidManifest.xml
    manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
}

android {
    namespace = "com.example.flutter_dapm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.example.flutter_dapm"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Gọi hàm cấu hình ở đây
        configureDefaultConfig()
    }

    // Kích hoạt tính năng BuildConfig
    buildFeatures {
        buildConfig = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Các dependencies khác của bạn
}
