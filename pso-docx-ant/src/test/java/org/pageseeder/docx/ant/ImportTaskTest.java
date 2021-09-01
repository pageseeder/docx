package org.pageseeder.docx.ant;

import org.junit.Assert;
import org.junit.Test;
import org.pageseeder.docx.util.Files;
import org.xml.sax.SAXException;
import org.xmlunit.matchers.CompareMatcher;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class ImportTaskTest {

  private static final File CASES = new File("src/test/import/cases");

  private static final File RESULTS = new File("test/import/results");

  @Test
  public void testBlockMultipleParagraphStyles() throws IOException, SAXException {
    testIndividual("block-multiple-paragraph-styles");
  }

  @Test
  public void testBlockOneParagraphStyle() throws IOException, SAXException {
    testIndividual("block-one-paragraph-style");
  }

  @Test
  public void testDefaultCharacterStyleInline() throws IOException, SAXException {
    testIndividual("default-character-style-inline");
  }

  @Test
  public void testDefaultCharacterStyleNone() throws IOException, SAXException {
    testIndividual("default-character-style-none");
  }

  @Test
  public void testDefaultParagraphStyleBlock() throws IOException, SAXException {
    testIndividual("default-paragraph-style-block");
  }

  @Test
  public void testDefaultParagraphStylePara() throws IOException, SAXException {
    testIndividual("default-paragraph-style-para");
  }

  @Test
  public void testDefaultReferencesLink() throws IOException, SAXException {
    testIndividual("default-references-link");
  }

  @Test
  public void testDefaultReferencesLinkBibliography() throws IOException, SAXException {
    testIndividual("default-references-link-bibliography");
  }

  @Test
  public void testDocumentSplitDocumentFalse() throws IOException, SAXException {
    testIndividual("document-split-document-false");
  }

  @Test
  public void testDocumentSplitDocumentFalseNumberingFalse() throws IOException, SAXException {
    testIndividual("document-split-document-false-numbering-false");
  }

  @Test
  public void testDocumentSplitDocumentFalseNumberingTrue() throws IOException, SAXException {
    testIndividual("document-split-document-false-numbering-true");
  }

  @Test
  public void testDocumentSplitDocumentTrueNumberingTrueMultipleOutlineLevel() throws IOException, SAXException {
    testIndividual("document-split-document-true-numbering-true-multiple-outline-level");
  }

  @Test
  public void testDocumentSplitDocumentTrueNumberingTrueMultipleParagraphStyles() throws IOException, SAXException {
    testIndividual("document-split-document-true-numbering-true-multiple-paragraph-styles");
  }

  @Test
  public void testDocumentSplitDocumentTrueNumberingFalseOutlineLevel() throws IOException, SAXException {
    testIndividual("document-split-document-true-numbering-false-outline-level");
  }

  @Test
  public void testDocumentSplitDocumentTrueNumberingTrueOutlineLevel() throws IOException, SAXException {
    testIndividual("document-split-document-true-numbering-true-outline-level");
  }

  @Test
  public void testDocumentSplitDocumentTrueNumberingTrueParagraphStyles() throws IOException, SAXException {
    testIndividual("document-split-document-true-numbering-true-paragraph-styles");
  }

  @Test
  public void testDocumentSplitMultipleOutlineLevel() throws IOException, SAXException {
    testIndividual("document-split-multiple-outline-level");
  }

  @Test
  public void testDocumentSplitMultipleParagraphStyle() throws IOException, SAXException {
    testIndividual("document-split-multiple-paragraph-style");
  }

  @Test
  public void testDocumentSplitMultipleParagraphStyleWithMultipleLabels() throws IOException, SAXException {
    testIndividual("document-split-multiple-paragraph-style-with-multiple-labels");
  }

  @Test
  public void testDocumentSplitMultipleParagraphStyleWithMultipleTypes() throws IOException, SAXException {
    testIndividual("document-split-multiple-paragraph-style-with-multiple-types");
  }

  @Test
  public void testDocumentSplitMultipleParagraphStyleWithOneLabel() throws IOException, SAXException {
    testIndividual("document-split-multiple-paragraph-style-with-one-label");
  }

  @Test
  public void testDocumentSplitMultipleParagraphStyleWithOneType() throws IOException, SAXException {
    testIndividual("document-split-multiple-paragraph-style-with-one-type");
  }

  @Test
  public void testDocumentSplitMultipleSplitValues1() throws IOException, SAXException {
    testIndividual("document-split-multiple-split-values-1");
  }

  @Test
  public void testDocumentSplitMultipleSplitValues2() throws IOException, SAXException {
    testIndividual("document-split-multiple-split-values-2");
  }

  @Test
  public void testDocumentSplitOutlineLevel() throws IOException, SAXException {
    testIndividual("document-split-outline-level");
  }

  @Test
  public void testDocumentSplitParagraphStyle() throws IOException, SAXException {
    testIndividual("document-split-paragraph-style");
  }

  @Test
  public void testDocumentSplitSplitstyle() throws IOException, SAXException {
    testIndividual("document-split-splitstyle");
  }

  @Test
  public void testDocumentTitleDcTitle() throws IOException, SAXException {
    testIndividual("document-title-dc-title");
  }

  @Test
  public void testEmptyConfigurationBasicDocument() throws IOException, SAXException {
    testIndividual("empty-configuration-basic-document");
  }

  @Test
  public void testEmptyConfigurationCharacterStyles() throws IOException, SAXException {
    testIndividual("empty-configuration-character-styles");
  }

  @Test
  public void testEmptyConfigurationDefaultLists() throws IOException, SAXException {
    testIndividual("empty-configuration-default-lists");
  }

  @Test
  public void testEmptyConfigurationImages() throws IOException, SAXException {
    testIndividual("empty-configuration-images");
    File result = new File(RESULTS, "empty-configuration-images");
    Assert.assertTrue("Image 1 missing", new File(result, "images/image1.jpg").exists());
    Assert.assertTrue("Image 2 missing", new File(result, "images/image 2.jpeg").exists());
  }

  @Test
  public void testEmptyConfigurationImagesDrawingAnchorElement() throws IOException, SAXException {
    testIndividual("empty-configuration-images-drawing-anchor-element");
  }

  @Test
  public void testEmptyConfigurationImagesEmbededPictElement() throws IOException, SAXException {
    testIndividual("empty-configuration-images-embeded-pict-element");
  }

  @Test
  public void testEmptyConfigurationImagesPictElement() throws IOException, SAXException {
    testIndividual("empty-configuration-images-pict-element");
  }

  @Test
  public void testEmptyConfigurationMultilevelLists() throws IOException, SAXException {
    testIndividual("empty-configuration-multilevel-lists");
  }

  @Test
  public void testEmptyConfigurationNumberedParagraphStyles() throws IOException, SAXException {
    testIndividual("empty-configuration-numbered-paragraph-styles");
  }

  @Test
  public void testEmptyConfigurationParagraphStyles() throws IOException, SAXException {
    testIndividual("empty-configuration-paragraph-styles");
  }

  @Test
  public void testEmptyConfigurationTables() throws IOException, SAXException {
    testIndividual("empty-configuration-tables");
  }

  @Test
  public void testFormFields() throws IOException, SAXException {
    testIndividual("form-fields");
  }

  @Test
  public void testHeadingsMultipleParagraphStyles() throws IOException, SAXException {
    testIndividual("headings-multiple-paragraph-styles");
  }

  @Test
  public void testHeadingsMultipleWithNumberingInline() throws IOException, SAXException {
    testIndividual("headings-multiple-with-numbering-inline");
  }

  @Test
  public void testHeadingsMultipleWithNumberingNumbering() throws IOException, SAXException {
    testIndividual("headings-multiple-with-numbering-numbering");
  }

  @Test
  public void testHeadingsMultipleWithNumberingPrefix() throws IOException, SAXException {
    testIndividual("headings-multiple-with-numbering-prefix");
  }

  @Test
  public void testHeadingsMultipleWithNumberingPrefixNumberingInline() throws IOException, SAXException {
    testIndividual("headings-multiple-with-numbering-prefix-numbering-inline");
  }

  @Test
  public void testHeadingsMultipleWithNumberingText() throws IOException, SAXException {
    testIndividual("headings-multiple-with-numbering-text");
  }

  @Test
  public void testHeadingsOneParagraphStyle() throws IOException, SAXException {
    testIndividual("headings-one-paragraph-style");
  }

  @Test
  public void testHeadingsOneParagraphStyleWithBlock() throws IOException, SAXException {
    testIndividual("headings-one-paragraph-style-with-block");
  }

  @Test
  public void testHeadingsOneParagraphStyleWithInline() throws IOException, SAXException {
    testIndividual("headings-one-paragraph-style-with-inline");
  }

  @Test
  public void testHeadingsWithNumberingInline() throws IOException, SAXException {
    testIndividual("headings-with-numbering-inline");
  }

  @Test
  public void testHeadingsWithNumberingNumbering() throws IOException, SAXException {
    testIndividual("headings-with-numbering-numbering");
  }

  @Test
  public void testHeadingsWithNumberingPrefix() throws IOException, SAXException {
    testIndividual("headings-with-numbering-prefix");
  }

  @Test
  public void testHeadingsWithNumberingText() throws IOException, SAXException {
    testIndividual("headings-with-numbering-text");
  }

  @Test
  public void testIgnoreStylesBodyTextParagraphStyle() throws IOException, SAXException {
    testIndividual("ignore-styles-body-text-paragraph-style");
  }

  @Test
  public void testIgnoreStylesMultipleParagraphStyles() throws IOException, SAXException {
    testIndividual("ignore-styles-multiple-paragraph-styles");
  }

  @Test
  public void testIgnoreStylesOneParagraphStyle() throws IOException, SAXException {
    testIndividual("ignore-styles-one-paragraph-style");
  }

  @Test
  public void testIgnoreStylesTocParagraphStyles() throws IOException, SAXException {
    testIndividual("ignore-styles-toc-paragraph-styles");
  }

  @Test
  public void testInlineMultiCharacterStyle() throws IOException, SAXException {
    testIndividual("inline-multi-character-style");
  }

  @Test
  public void testInlineMultipleParagraphStyle() throws IOException, SAXException {
    testIndividual("inline-multiple-paragraph-style");
  }

  @Test
  public void testInlineOneCharacterStyle() throws IOException, SAXException {
    testIndividual("inline-one-character-style");
  }

  @Test
  public void testInlineOneParagraphStyle() throws IOException, SAXException {
    testIndividual("inline-one-paragraph-style");
  }

  @Test
  public void testListsBulletContinueStyles() throws IOException, SAXException {
    testIndividual("lists-bullet-continue-style");
  }

  @Test
  public void testListsBulletSyles() throws IOException, SAXException {
    testIndividual("lists-bullet-style");
  }

  @Test
  public void testListsBulletGapLevels() throws IOException, SAXException {
    testIndividual("lists-bullet-style-gap-levels");
  }

  @Test
  public void testTableColWidth() throws IOException, SAXException {
    testIndividual("table-col-width");
  }

  @Test
  public void testTableColAutoWidth() throws IOException, SAXException {
    testIndividual("table-col-auto-width");
  }

  @Test
  public void testTableInsideList() throws IOException, SAXException {
    testIndividual("table-inside-list");
  }

  @Test
  public void testListsDefaultListRoleFalse() throws IOException, SAXException {
    testIndividual("lists-default-list-role-false");
  }

  @Test
  public void testListsDefaultListRoleTrue() throws IOException, SAXException {
    testIndividual("lists-default-list-role-true");
  }

  @Test
  public void testListsHyperlink() throws IOException, SAXException {
    testIndividual("lists-hyperlink");
  }

  @Test
  public void testListsLinkedListStylesSplit() throws IOException, SAXException {
    testIndividual("lists-linked-list-styles-split");
  }

  @Test
  public void testListsMultilevelListRoleFalse() throws IOException, SAXException {
    testIndividual("lists-multilevel-list-role-false");
  }

  @Test
  public void testListsMultilevelListRoleTrue() throws IOException, SAXException {
    testIndividual("lists-multilevel-list-role-true");
  }

  @Test
  public void testListsNumberedParagraphsRoleFalse() throws IOException, SAXException {
    testIndividual("lists-numbered-paragraphs-role-false");
  }

  @Test
  public void testListsNumberedParagraphsRoleTrue() throws IOException, SAXException {
    testIndividual("lists-numbered-paragraphs-role-true");
  }

  @Test
  public void testManualNumberingFalse() throws IOException, SAXException {
    testIndividual("manual-numbering-false");
  }

  @Test
  public void testManualNumberingTrueAutonumbering() throws IOException, SAXException {
    testIndividual("manual-numbering-true-autonumbering");
  }

  @Test
  public void testManualNumberingTrueInline() throws IOException, SAXException {
    testIndividual("manual-numbering-true-inline");
  }

  @Test
  public void testManualNumberingTruePrefix() throws IOException, SAXException {
    testIndividual("manual-numbering-true-prefix");
  }

  @Test
  public void testManualNumberingTruePrefixInline() throws IOException, SAXException {
    testIndividual("manual-numbering-true-prefix-inline");
  }

  @Test
  public void testMathmlGenerateFiles() throws IOException, SAXException {
    testIndividual("mathml-generate-files");
  }

  @Test
  public void testMathmlGenerateFragments() throws IOException, SAXException {
    testIndividual("mathml-generate-fragments");
  }

  @Test
  public void testMathmlMathtypePlugin() throws IOException, SAXException {
    testIndividual("mathml-mathtype-plugin");
  }

  @Test
  public void testMonospaceMultiCharacterStyle() throws IOException, SAXException {
    testIndividual("monospace-multi-character-style");
  }

  @Test
  public void testMonospaceMultiParagraphStyle() throws IOException, SAXException {
    testIndividual("monospace-multi-paragraph-style");
  }

  @Test
  public void testMonospaceOneCharacterStyle() throws IOException, SAXException {
    testIndividual("monospace-one-character-style");
  }

  @Test
  public void testMonospaceOneParagraphStyle() throws IOException, SAXException {
    testIndividual("monospace-one-paragraph-style");
  }

  @Test
  public void testNumberedParagraphsFalse() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-false");
  }

  @Test
  public void testNumberedParagraphsTrueMultilevelOutputInline() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-true-multilevel-output-inline");
  }

  @Test
  public void testNumberedParagraphsTrueMultilevelOutputNumbering() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-true-multilevel-output-numbering");
  }

  @Test
  public void testNumberedParagraphsTrueMultilevelOutputNumberingPrefix() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-true-multilevel-output-numbering-prefix");
  }

  @Test
  public void testNumberedParagraphsTrueMultilevelOutputNumberingTextInlinePrefix() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-true-multilevel-output-numbering-text-inline-prefix");
  }

  @Test
  public void testNumberedParagraphsTrueMultilevelOutputPrefix() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-true-multilevel-output-prefix");
  }

  @Test
  public void testNumberedParagraphsTrueMultilevelOutputText() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-true-multilevel-output-text");
  }

  @Test
  public void testNumberedParagraphsTrueMultilevelOutputTextPrefix() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-true-multilevel-output-text-prefix");
  }

  @Test
  public void testNumberedParagraphsTrueOutputInline() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-true-output-inline");
  }

  @Test
  public void testNumberedParagraphsTrueOutputNumbering() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-true-output-numbering");
  }

  @Test
  public void testNumberedParagraphsTrueOutputPrefix() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-true-output-prefix");
  }

  @Test
  public void testNumberedParagraphsTrueOutputText() throws IOException, SAXException {
    testIndividual("numbered-paragraphs-true-output-text");
  }

  @Test
  public void testOrientationEndOfBlock() throws IOException, SAXException {
    testIndividual("orientation-end-of-block");
  }

  @Test
  public void testOrientationEndOfPara() throws IOException, SAXException {
    testIndividual("orientation-end-of-para");
  }

  @Test
  public void testOrientationInsideList() throws IOException, SAXException {
    testIndividual("orientation-inside-list");
  }

  @Test
  public void testOrientationWithWordImportConfigStyles() throws IOException, SAXException {
    testIndividual("orientation-with-word-import-config-styles");
  }

  @Test
  public void testParaMultipleParagraphStyles() throws IOException, SAXException {
    testIndividual("para-multiple-paragraph-styles");
  }

  @Test
  public void testParaMultipleWithNumberingInline() throws IOException, SAXException {
    testIndividual("para-multiple-with-numbering-inline");
  }

  @Test
  public void testParaMultipleWithNumberingNumbering() throws IOException, SAXException {
    testIndividual("para-multiple-with-numbering-numbering");
  }

  @Test
  public void testParaMultipleWithNumberingPrefix() throws IOException, SAXException {
    testIndividual("para-multiple-with-numbering-prefix");
  }

  @Test
  public void testParaMultipleWithNumberingPrefixNumberingInline() throws IOException, SAXException {
    testIndividual("para-multiple-with-numbering-prefix-numbering-inline");
  }

  @Test
  public void testParaMultipleWithNumberingText() throws IOException, SAXException {
    testIndividual("para-multiple-with-numbering-text");
  }

  @Test
  public void testParaOneParagraphStyle() throws IOException, SAXException {
    testIndividual("para-one-paragraph-style");
  }

  @Test
  public void testParaOneParagraphStyleWithBlock() throws IOException, SAXException {
    testIndividual("para-one-paragraph-style-with-block");
  }

  @Test
  public void testParaOneParagraphStyleWithInline() throws IOException, SAXException {
    testIndividual("para-one-paragraph-style-with-inline");
  }

  @Test
  public void testParaWithNumberingInline() throws IOException, SAXException {
    testIndividual("para-with-numbering-inline");
  }

  @Test
  public void testParaWithNumberingNumbering() throws IOException, SAXException {
    testIndividual("para-with-numbering-numbering");
  }

  @Test
  public void testParaWithNumberingPrefix() throws IOException, SAXException {
    testIndividual("para-with-numbering-prefix");
  }

  @Test
  public void testParaWithNumberingText() throws IOException, SAXException {
    testIndividual("para-with-numbering-text");
  }

  @Test
  public void testPreformatMultiParagraphStyle() throws IOException, SAXException {
    testIndividual("preformat-multi-paragraph-style");
  }

  @Test
  public void testPreformatOneParagraphStyle() throws IOException, SAXException {
    testIndividual("preformat-one-paragraph-style");
  }

  @Test
  public void testSectionSplitDocumentFalse() throws IOException, SAXException {
    testIndividual("section-split-document-false");
  }

  @Test
  public void testSectionSplitMultipleOutlineLevel() throws IOException, SAXException {
    testIndividual("section-split-multiple-outline-level");
  }

  @Test
  public void testSectionSplitMultipleParagraphStyle() throws IOException, SAXException {
    testIndividual("section-split-multiple-paragraph-style");
  }

  @Test
  public void testSectionSplitMultipleSplitValues1() throws IOException, SAXException {
    testIndividual("section-split-multiple-split-values-1");
  }

  @Test
  public void testSectionSplitMultipleSplitValues2() throws IOException, SAXException {
    testIndividual("section-split-multiple-split-values-2");
  }

  @Test
  public void testSectionSplitOutlineLevel() throws IOException, SAXException {
    testIndividual("section-split-outline-level");
  }

  @Test
  public void testSectionSplitParagraphStyle() throws IOException, SAXException {
    testIndividual("section-split-paragraph-style");
  }

  @Test
  public void testSectionSplitSplitstyle() throws IOException, SAXException {
    testIndividual("section-split-splitstyle");
  }

  @Test
  public void testSmartTagFalse() throws IOException, SAXException {
    testIndividual("smart-tag-false");
  }

  @Test
  public void testSmartTagTrue() throws IOException, SAXException {
    testIndividual("smart-tag-true");
  }

  @Test
  public void testTextBox() throws IOException, SAXException {
    testIndividual("textbox");
  }

  @Test
  public void testTextBoxWithWordImportConfigStyles() throws IOException, SAXException {
    testIndividual("textbox-with-word-import-config-styles");
  }

  public void testAll() throws IOException, SAXException {
    File[] tests = CASES.listFiles();
    for (File test : tests) {
      testIndividual(test);
    }
  }

  public void testIndividual(String folderName) throws IOException, SAXException {
    testIndividual(new File(CASES, folderName));
  }

  public void testIndividual(File dir) throws IOException, SAXException {
    if (dir.isDirectory()) {

      if (new File(dir, dir.getName() + ".docx").exists()) {
        System.out.println(dir.getName());
        File result = new File(RESULTS, dir.getName());
        result.mkdirs();
        File actual = process(dir, result);
        File expected = new File(dir, "expected.psml");

        // Check that the files exist
        Assert.assertTrue(actual.exists());
        Assert.assertTrue(expected.exists());

        Assert.assertTrue(actual.length() > 0);
        Assert.assertTrue(expected.length() > 0);
        assertXMLEqual(expected, actual, result);
      } else {
        System.out.println("Unable to find DOCX file for test:" + dir.getName());
      }
    }
  }

  private File process(File test, File result) {
    ImportTask task = new ImportTask();
    task.setSrc(new File(test, test.getName() + ".docx"));

    // validate config file
    File import_config = new File(test, "word-import-config.xml");
    // if not using deprecated split element then validate config
    if (!test.getName().contains("split")) {
      Assert.assertThat(import_config, XML.validates("word-import-config.xsd"));
    }

    task.setConfig(import_config);

    task.setDest(result);
    Parameter parameter = task.createParam();
    parameter.setName("generate-processed-psml");
    parameter.setValue("true");
    task.execute();

    // validate result PSML
    File actual = new File(result, test.getName() + ".psml");
    Assert.assertThat(actual, XML.validates("psml-processed.xsd"));

    return actual;
  }

  private static void assertXMLEqual(File expected, File actual, File result) throws IOException, SAXException {
    try {
      Assert.assertThat(actual, CompareMatcher.isIdenticalTo(expected));
    } catch (AssertionError error) {
      //System.err.println("Expected:");
      //copyToSystemErr(expected);
      //System.err.println();
      //System.err.println("Actual:");
      //copyToSystemErr(actual);
      //System.err.println();
      File expfile = new File(result, "expected-" + actual.getName());
      File actfile = new File(result, "actual-" + actual.getName());
      System.err.println("Expected: " + expfile.getCanonicalPath());
      System.err.println("Actual: " + actfile.getCanonicalPath());
      Files.copy(expected, expfile);
      Files.copy(actual, actfile);
      // uncomment the following to bulk update expected files for changes effecting multiple documents
      //Files.copy(actual, expected);
      throw error;
    }
  }

  private static void copyToSystemErr(File f) throws IOException {
    InputStream in = new FileInputStream(f);

    // Transfer bytes from in to out
    byte[] buf = new byte[1024];
    int len;
    while ((len = in.read(buf)) > 0) {
      System.err.write(buf, 0, len);
    }
    in.close();
  }

}
