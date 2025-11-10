pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("${rootDir}/local-maven-build-repo")
        }
    }
}

rootProject.name = "projectm-android-builds"
include(":projectm-android")
include(":projectm-android-test")
