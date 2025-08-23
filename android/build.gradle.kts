import java.util.Properties
import java.io.FileInputStream
import java.io.File

import org.gradle.api.tasks.Delete
import org.gradle.api.Project
import org.gradle.api.file.Directory

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Define a custom root build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Apply to all subprojects
subprojects {
    // Set new build directory per subproject
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Force dependency on app project
    project.evaluationDependsOn(":app")
}

// Delay namespace patching until all projects are evaluated
gradle.projectsEvaluated {
    subprojects {
        if (plugins.hasPlugin("com.android.library")) {
            val androidExtension = extensions.findByName("android")
            if (androidExtension is com.android.build.gradle.LibraryExtension) {
                if (androidExtension.namespace.isNullOrBlank()) {
                    val newNamespace = "com.motosekur.app1"
                    println("Adding missing namespace '$newNamespace' to ${project.name}")
                    androidExtension.namespace = newNamespace
                }
            }
        }
    }
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
