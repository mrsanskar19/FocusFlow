import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. LOAD THE KEYSTORE PROPERTIES
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties") // Looks in android/ folder

if (keystorePropertiesFile.exists()) {
    println("✅ Found key.properties at: ${keystorePropertiesFile.absolutePath}")
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    println("⚠️ WARNING: key.properties NOT FOUND at ${keystorePropertiesFile.absolutePath}")
    println("   Release build will NOT be signed.")
}

android {
    namespace = "com.cycberx.sleeping"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.cycberx.sleeping"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // 2. CONFIGURE SIGNING
            // If key.properties was loaded, we use it.
            if (keystoreProperties.isNotEmpty()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storePassword = keystoreProperties["storePassword"] as String

                enableV1Signing = true
                enableV2Signing = true
                
                // Resolves relative to android/app/
                storeFile = file(keystoreProperties["storeFile"] as String)
                
                println("✅ Signing Configured using key alias: $keyAlias")
            } else {
                println("❌ Skipping signing config - Properties missing")
            }
        }
    }

    buildTypes {
        getByName("release") {
            // 3. FORCE USE OF RELEASE CONFIG
            signingConfig = signingConfigs.getByName("release")
            
            // Optimization settings (Keep false for debugging signing issues)
            isMinifyEnabled = false 
            isShrinkResources = false
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}