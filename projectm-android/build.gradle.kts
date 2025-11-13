plugins {
    alias(libs.plugins.android.library)
    id("maven-publish")
}

android {
    namespace = "net.protyposis.projectmlib.android"
    compileSdk {
        version = release(34)
    }
    ndkVersion = "25.2.9519653"

    defaultConfig {
        minSdk = 21
    }

    buildTypes {
        getByName("debug") { isJniDebuggable = true }
        getByName("release") { isMinifyEnabled = false }
    }

    publishing {
        multipleVariants {
            allVariants()
        }
    }
}

// Prefab: copy prefab/ tree into each variant's AAR
// We detect src/<variant>/prefab first; if absent, we fall back to src/main/prefab.
// We package manually because AGP's `prefabPublishing` requires an `externalNativeBuild` and
// doesn't work with prebuilt binaries.
androidComponents {
    onVariants { variant ->
        val variantName = variant.name
        val cap = variantName.replaceFirstChar { it.titlecase() }

        val stagePrefab = tasks.register<Copy>("stagePrefab$cap") {
            val variantPrefabDir = project.layout.projectDirectory.dir("src/$variantName/prefab")
            val mainPrefabDir = project.layout.projectDirectory.dir("src/main/prefab")
            val chosenPrefabDir = if (variantPrefabDir.asFile.exists()) variantPrefabDir else mainPrefabDir
            val prefabOutputDir = layout.buildDirectory.dir("intermediates/prefab-pack/$variantName/prefab")

            from(chosenPrefabDir)
            into(prefabOutputDir)

            doFirst {
                // Ensure stale prefab files never leak into the packaged AAR.
                prefabOutputDir.get().asFile.deleteRecursively()
            }
        }

        tasks.withType(Zip::class.java).configureEach {
            if (name == "bundle${cap}Aar") {
                dependsOn(stagePrefab)
                from(layout.buildDirectory.dir("intermediates/prefab-pack/$variantName/prefab")) {
                    into("prefab")
                }
            }
        }
    }
}

afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("projectMAndroid") {
                from(components["default"])
                groupId = "net.protyposis.projectm-unofficial"
                artifactId = "projectm-android"
                version = rootProject.extra["projectMVersion"] as String

                pom {
                    name.set("projectM Android Native Library")
                    description.set("Android native library package for projectM music visualizer")
                    url.set("https://github.com/projectM-visualizer/projectm")

                    licenses {
                        license {
                            name.set("GNU Lesser General Public License v2.1")
                            url.set("https://github.com/projectM-visualizer/projectm/blob/master/LICENSE.txt")
                        }
                    }

                    developers {
                        developer {
                            name.set("projectM Team")
                            url.set("https://github.com/projectM-visualizer")
                        }
                    }

                    scm {
                        connection.set("scm:git:git://github.com/projectM-visualizer/projectm.git")
                        developerConnection.set("scm:git:ssh://github.com/projectM-visualizer/projectm.git")
                        url.set("https://github.com/projectM-visualizer/projectm")
                    }
                }
            }
        }

        repositories {
            // Local repository for GitHub Pages
            maven {
                name = "GitHubPages"
                val ghPagesRepoDir = providers.gradleProperty("ghPagesRepoDir").orNull
                val targetDir = ghPagesRepoDir?.let { file(it) }
                    ?: layout.buildDirectory.dir("gh-pages-repo").get().asFile
                url = uri(targetDir)
            }
        }
    }
}
