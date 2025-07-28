plugins {
  id("java-library")
  id("maven-publish")
  id("io.codearte.nexus-staging") version "0.30.0"
}

group = "org.pageseeder.docx"
version = file("version.txt").readText().trim()
description = findProperty("description") as String?

subprojects {
  group   = "org.pageseeder.docx"
  version = rootProject.version

  apply(plugin = "java")
//  apply(from = "$rootDir/gradle/publish-mavencentral.gradle.kts")

  // Enforce Java 11
  configure<JavaPluginExtension> {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    toolchain {
      languageVersion.set(JavaLanguageVersion.of(11))
    }
    withSourcesJar()
  }

  repositories {
    mavenCentral()
  }

//  TODO javadoc {
//    failOnError= false
//  }

  tasks.test {
    useJUnitPlatform()
  }
}