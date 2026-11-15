import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") apply false
}

// O Firebase só é ligado se o android/app/google-services.json existir
// (baixado no console do Firebase). Sem ele o app compila e roda sem login.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

// A chave do Google Maps fica no android/local.properties (MAPS_API_KEY=...),
// que é ignorado pelo Git.
val localProperties = Properties().apply {
    val arquivo = rootProject.file("local.properties")
    if (arquivo.exists()) arquivo.inputStream().use { load(it) }
}

android {
    namespace = "br.com.lixozero.lixozero"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // O flutter_local_notifications (lembretes de coleta) precisa de desugaring.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "br.com.lixozero.lixozero"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["mapsApiKey"] = localProperties.getProperty("MAPS_API_KEY", "")
    }

    buildTypes {
        release {
            // Por enquanto o release usa a assinatura de debug.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
