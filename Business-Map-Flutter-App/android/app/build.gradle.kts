import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun loadDotEnv(file: java.io.File): Properties {
    val props = Properties()
    if (!file.exists()) return props
    file.forEachLine { line ->
        val trimmed = line.trim()
        if (trimmed.isEmpty() || trimmed.startsWith("#")) return@forEachLine
        val idx = trimmed.indexOf('=')
        if (idx <= 0) return@forEachLine
        val key = trimmed.substring(0, idx).trim()
        val value = trimmed.substring(idx + 1).trim()
        props.setProperty(key, value)
    }
    return props
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

// Prefer root `.env` so all keys live in one place; fall back to local.properties.
val envProperties = loadDotEnv(rootProject.file("../.env"))
val mapsApiKey =
    envProperties.getProperty("MAPS_API_KEY")
        ?: localProperties.getProperty("MAPS_API_KEY")
        ?: ""

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("keystore.properties")
val hasKeystore = keystorePropertiesFile.exists()

if (hasKeystore) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.nafeesa.business_map"
    compileSdk = flutter.compileSdkVersion
    //ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/publish/application-id.html).
        applicationId = "com.nafeesa.business_map"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    signingConfigs {
        if (hasKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        debug {
            if (hasKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
        release {
            if (hasKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
    }
}

flutter {
    source = "../.."
}
