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

        // Deep-link values consumed by AndroidManifest.xml.
        // Keep them in sync with DeepLinkConfig in deep_link_service.dart.
        manifestPlaceholders["deepLinkHost"] = "delta-asg.com"
        manifestPlaceholders["deepLinkScheme"] = "hajedcar"
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
            // Same verified domain as prod. The domain's assetlinks.json
            // contains a statement for com.Hajed.car.dev, so the dev build
            // verifies too. Do not install dev and prod on the same device
            // for link testing (Android would show an app chooser).
            // For full isolation, use a subdomain instead:
            //   manifestPlaceholders["deepLinkHost"] = "dev.delta-asg.com"
            // and publish an assetlinks.json on that subdomain.
            manifestPlaceholders["deepLinkHost"] = "delta-asg.com"
            manifestPlaceholders["deepLinkScheme"] = "hajedcar"
        }
        create("staging") {
            dimension = "default"
            applicationIdSuffix = ".testing"
            // applicationId is com.Hajed.car.testing, which is also listed in
            // the domain's assetlinks.json.
            manifestPlaceholders["deepLinkHost"] = "delta-asg.com"
            manifestPlaceholders["deepLinkScheme"] = "hajedcar"
        }
        create("prod") {
            dimension = "default"
            manifestPlaceholders["deepLinkHost"] = "delta-asg.com"
            manifestPlaceholders["deepLinkScheme"] = "hajedcar"
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
