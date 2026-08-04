allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Injected to fix compilation of plugins using old styles
subprojects {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.android.support" && !requested.name.startsWith("multidex")) {
                useTarget("androidx.${requested.name.replace("support-", "")}:${requested.version}")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }

    val fixNamespace = {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                if (getNamespace.invoke(android) == null) {
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val manifestXml = manifestFile.readText()
                        val packageMatch = Regex("package=\"([^\"]+)\"").find(manifestXml)
                        if (packageMatch != null) {
                            setNamespace.invoke(android, packageMatch.groupValues[1])
                        }
                    }
                }
            } catch (e: Exception) {
                // Ignore if method not found or other issues
            }

            // Fix for missing AppCompat theme and other dependencies in plugins
            // We use api to ensure it's available during compilation and to consumers
            project.dependencies.add("api", "androidx.appcompat:appcompat:1.6.1")
            project.dependencies.add("api", "com.google.android.material:material:1.9.0")
        }
    }

    if (project.state.executed) {
        fixNamespace()
    } else {
        project.afterEvaluate {
            fixNamespace()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
