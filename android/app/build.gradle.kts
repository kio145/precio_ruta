plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.routeprice.precio_ruta"
    compileSdk = flutter.compileSdkVersion

    // 👇 VOLVEMOS AL NDK QUE TRAE FLUTTER (26.x), NO FORZAMOS EL 27.
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.routeprice.precio_ruta"

        // 👇 mantenemos el minSdk en 23 para Firebase
        minSdk = 23

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: añade tu signingConfig propia para publicar en Play Store.
            // De momento firmamos con la debug key para que `flutter run --release` funcione.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
