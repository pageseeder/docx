
description = "Core DOCX API"

dependencies {

  implementation (libs.slf4j.api)

//  testImplementation (
//    "xmlunit:xmlunit:$xmlunitVersion",
//    "junit:junit:$junitVersion"
//  )
  testImplementation(platform(libs.junit.bom))
  testImplementation(libs.bundles.junit)
  testImplementation(libs.hamcrest)
  testImplementation(libs.xmlunit.core)
  testImplementation(libs.xmlunit.matchers)
  testImplementation(libs.annotations)

  testRuntimeOnly(libs.saxon.he)
}