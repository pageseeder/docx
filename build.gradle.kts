plugins {
  id("java-library")
  id("maven-publish")
  alias(libs.plugins.jreleaser)
    //.apply(false)
//  id("org.jreleaser") version "1.18.0" apply false
//  id("io.codearte.nexus-staging") version "0.30.0"
}

val title: String by project
val gitName: String by project
val website: String by project

group = "org.pageseeder.docx"
version = file("version.txt").readText().trim()
description = findProperty("description") as String?

subprojects {
  group   = "org.pageseeder.docx"
  version = rootProject.version

  apply(plugin = "java")
  apply(plugin = "maven-publish")
  //apply(plugin = "org.jreleaser")

//  apply(from = "$rootDir/gradle/publish-mavencentral.gradle.kts")

  // Enforce Java 11
  configure<JavaPluginExtension> {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    toolchain {
      languageVersion.set(JavaLanguageVersion.of(11))
    }
    withJavadocJar()
    withSourcesJar()
  }

  repositories {
    mavenCentral()
  }

  tasks.javadoc {
    options.encoding = "UTF-8"
    (options as StandardJavadocDocletOptions).addStringOption("Xdoclint:none", "-quiet")
//    failOnError = false
  }


  tasks.test {
    useJUnitPlatform()
  }

  publishing {
    publications {
      create<MavenPublication>("maven") {
        from(components["java"])
        pom {
          name.set(title)
          description.set(project.description)
          url.set(website)
          licenses {
            license {
              name.set("The Apache Software License, Version 2.0")
              url.set("https://www.apache.org/licenses/LICENSE-2.0.txt")
            }
          }
          organization {
            name.set("Allette Systems")
            url.set("https://www.allette.com.au")
          }
          scm {
            url.set("git@github.com:pageseeder/${gitName}.git")
            connection.set("scm:git:git@github.com:pageseeder/${gitName}.git")
            developerConnection.set("scm:git:git@github.com:pageseeder/${gitName}.git")
          }
          developers {
            developer {
              name.set("Carlos Cabral")
              email.set("ccabral@allette.com.au")
            }
            developer {
              name.set("Christophe Lauret")
              email.set("clauret@weborganic.com")
            }
            developer {
              name.set("Jean-Baptiste Reure")
              email.set("jbreure@weborganic.com")
            }
            developer {
              name.set("Philip Rutherford")
              email.set("philipr@weborganic.com")
            }
          }
        }
      }
    }
    repositories {
      maven {
        url = rootProject.layout.buildDirectory.dir("staging-deploy").get().asFile.toURI()
      }
    }
  }
}

jreleaser {
  configFile.set(file("jreleaser.toml"))
  distributions {
    subprojects.forEach { subproject ->
      register(subproject.name) {
        artifact {
          path.set(subproject.layout.buildDirectory.file("libs/${subproject.name}-${project.version}.jar"))
        }
        artifact {
          path.set(subproject.layout.buildDirectory.file("libs/${subproject.name}-${project.version}-sources.jar"))
        }
        artifact {
          path.set(subproject.layout.buildDirectory.file("libs/${subproject.name}-${project.version}-javadoc.jar"))
        }
      }
    }
  }
}