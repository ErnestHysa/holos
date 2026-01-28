plugins {
    id("com.android.application")
    id("kotlin-android")
    id("kotlin-parcelize")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.holos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.holos"
        minSdk = 29  // Samsung Health Data SDK requires Android 10+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Samsung Health Data SDK
    implementation(files("libs/samsung-health-data-api-1.0.0.aar"))

    // Required dependencies for Samsung Health SDK
    implementation("com.google.code.gson:gson:2.13.2")
    implementation("androidx.activity:activity:1.10.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.9.2")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

flutter {
    source = "../.."
}
