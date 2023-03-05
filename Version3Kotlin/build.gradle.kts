
import org.jetbrains.compose.desktop.application.dsl.TargetFormat

plugins {
    kotlin("multiplatform")
    id("org.jetbrains.compose") version "1.3.0"
}

group = "com.example"
version = "1.0-SNAPSHOT"

repositories {
    google()
    mavenCentral()
    maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")
}



kotlin {
    jvm {
        compilations.all {
            kotlinOptions.jvmTarget = "11"
        }
        withJava()
    }
    sourceSets {
        val jvmMain by getting {
            dependencies {
//                runtimeOnly("androidx.compose.material:material-icons-extended:1.1.0")
//                implementation("androidx.constraintlayout:constraintlayout:2.1.4")
                // To use constraintlayout in compose
//                implementation("androidx.constraintlayout:constraintlayout-compose:1.0.1")
//                implementation("org.jetbrains.compose.material3:material3-desktop:1.2.1")
//                implementation("androidx.compose.material3:material3-window-size-class:1.0.1")
                implementation(compose.desktop.currentOs)
//                implementation("io.github.androidpoet:dropdown:1.0.1")

                implementation("org.jetbrains.compose.material:material-icons-extended-desktop:1.3.0")
//                implementation("androidx.compose.material:material-icons-extended")
//                implementation ("com.google.accompanist:accompanist-pager:0.27.0")
//                implementation("androidx.viewpager2:viewpager2:1.0.0")
            }
        }
        val jvmTest by getting
    }
}

compose.desktop {
    application {
        mainClass = "MainKt"
        nativeDistributions {
            targetFormats(TargetFormat.Dmg, TargetFormat.Msi, TargetFormat.Deb)
            packageName = "demo"
            packageVersion = "1.0.0"
        }
    }
}
