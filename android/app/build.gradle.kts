plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // El plugin de Flutter SIEMPRE va después del de Android/Kotlin
    id("dev.flutter.flutter-gradle-plugin")
    // Plugin de Firebase / Google Services
    id("com.google.gms.google-services")
}

android {
    // 👇 Debe coincidir con tu package de Firebase
    namespace = "com.mycompany.routeprice"

    compileSdk = flutter.compileSdkVersion

    // NDK que te instaló el SDK Manager
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // 👇 Igual que en Firebase: com.mycompany.routeprice
        applicationId = "com.mycompany.routeprice"

        // Flutter ya define el minSdk (para Firebase ≥ 23)
        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Para pruebas usamos la debug key
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
