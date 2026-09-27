plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.firebase.appdistribution")
}

android {
    namespace = "com.Hajed.car"
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
        applicationId = "com.Hajed.car"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "default"
    // ✅ SIGNING CONFIG
    signingConfigs {
        create("release") {
            keyAlias = "upload"
            keyPassword = "111111"
            storeFile = file("/Users/asgsystems/key.jks")
            storePassword = "111111"
        }
    }
    // ✅ BUILD TYPES
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false

            firebaseAppDistribution {
                artifactType = "APK"
                releaseNotes = "New Release"
            }
        }
    }

    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
        }
        create("staging") {
            dimension = "default"
            applicationIdSuffix = ".testing"
        }
        create("prod") {
            dimension = "default"
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
