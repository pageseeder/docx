description = "OX tasks and definition for DOCX API"

dependencies {

  // DOCX module dependencies
  implementation(project(":pso-docx-core"))
  implementation(libs.slf4j.api)
  implementation(libs.slf4j.api)
  implementation(libs.ox)

  testRuntimeOnly(libs.schematron)
  testRuntimeOnly(libs.cobble)
  testRuntimeOnly(libs.junit.jupiter.engine)
  testRuntimeOnly(libs.slf4j.simple)
  testRuntimeOnly(libs.saxon.he)

  testImplementation(platform(libs.junit.bom))
  testImplementation(libs.bundles.junit)
  testImplementation(libs.hamcrest)
  testImplementation(libs.xmlunit.core)
  testImplementation(libs.xmlunit.matchers)
  testImplementation(libs.commons.io)
  testImplementation(libs.annotations)

  testRuntimeOnly(libs.schematron)
  testRuntimeOnly(libs.cobble)
  testRuntimeOnly(libs.junit.jupiter.engine)
  testRuntimeOnly(libs.slf4j.simple)
  testRuntimeOnly(libs.saxon.he)

}
