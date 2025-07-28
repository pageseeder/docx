description = "ANT tasks and definition for DOCX API"

dependencies {

  // DOCX module dependencies
  implementation(project(":pso-docx-core"))

  implementation(libs.slf4j.api)

  compileOnly(libs.ant)

  // Test dependencies
//  testImplementation (
//    "org.apache.ant:ant:$antVersion",
//    "junit:junit:$junitVersion",
//    "org.hamcrest:java-hamcrest:2.0.0.0",
//    "org.hamcrest:hamcrest-junit:2.0.0.0",
//    "org.xmlunit:xmlunit-core:2.10.0",
//    "org.xmlunit:xmlunit-matchers:2.10.0",
//    "commons-io:commons-io:2.18.0"
//  )
  testImplementation(platform(libs.junit.bom))
  testImplementation(libs.bundles.junit)
  testImplementation(libs.hamcrest)
  testImplementation(libs.xmlunit.core)
  testImplementation(libs.xmlunit.matchers)
  testImplementation(libs.commons.io)
  testImplementation(libs.annotations)
  testImplementation(libs.ant)


//  testRuntimeOnly (
//    "org.pageseeder.schematron:pso-schematron:$psoSchematronVersion",
//    "org.pageseeder.cobble:pso-cobble:$psoCobleVersion",
//    "net.sf.saxon:Saxon-HE:$saxonHEVersion",
//  )
  testRuntimeOnly(libs.schematron)
  testRuntimeOnly(libs.cobble)
  testRuntimeOnly(libs.junit.jupiter.engine)
  testRuntimeOnly(libs.slf4j.simple)
  testRuntimeOnly(libs.saxon.he)

}
