import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// 👇 OJO: SIN versión para com.android.application ni org.jetbrains.kotlin.android
plugins {
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
    // Solo google-services lleva versión
    id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Mover la carpeta build (esto es lo que agrega Flutter)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
