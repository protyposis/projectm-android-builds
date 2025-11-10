plugins {
    alias(libs.plugins.android.library)
}

android {
    namespace = "com.example.android_native_test"
    compileSdk {
        version = release(36)
    }

    defaultConfig {
        minSdk = 24

        testInstrumentationRunner = "android.support.test.runner.AndroidJUnitRunner"
        consumerProguardFiles("consumer-rules.pro")
        externalNativeBuild {
            cmake {
                cppFlags("-std=c++11")
                arguments("-DANDROID_STL=c++_shared")
            }
        }

        ndk {
            abiFilters += setOf("arm64-v8a")
        }
    }

    buildFeatures {
        prefab = true
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    externalNativeBuild {
        cmake {
            path("src/main/cpp/CMakeLists.txt")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    // Directly referencing the module does not work due to manual prefab packaging which doesn't
    // create expected CMake configs. They are only created with `externalNativeBuild` or when
    // including an external package.
    // implementation(project(":projectm-android"))
    //
    // To create this package, run from root dir:
    // `./gradlew :projectm-android:publishProjectMAndroidPublicationToGitHubPagesRepository -PPROJECTM_VERSION="local-SNAPSHOT" -PghPagesRepoDir="$pwd/local-maven-build-repo"`
    //
    // This is super hacky and may be improved by running this automatically with Gradle.
    implementation("net.protyposis.projectm-unofficial:projectm-android:local-SNAPSHOT")
}