package org.pageseeder.docx.ant;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;

import org.custommonkey.xmlunit.XMLAssert;
import org.junit.Assert;
import org.junit.Test;
import org.pageseeder.docx.util.Files;
import org.xml.sax.SAXException;

import junit.framework.AssertionFailedError;

/**
 * Test cases for export task
 */
public final class ExportTaskTest {

  private static final File CASES = new File("src/test/export/cases");

  private static final File RESULTS = new File("build/test/export/results");

  @Test
  public void testBlockDefaultNone() throws IOException, SAXException {
    testIndividual("block-default-none");
  }

  @Test
  public void testBlockDefaultNoneWithBlockGeneration() throws IOException, SAXException {
    testIndividual("block-default-none-with-block-generation");
  }

  @Test
  public void testBlockDefaultNoneWithBlockGenerationIgnore() throws IOException, SAXException {
    testIndividual("block-default-none-with-block-generation-ignore");
  }

  @Test
  public void testBlockDefaultNoneWithBlockPSStyle() throws IOException, SAXException {
    testIndividual("block-default-none-with-block-psstyle");
  }

  @Test
  public void testBlockDefaultPSStyle() throws IOException, SAXException {
    testIndividual("block-default-psstyle");
  }

  @Test
  public void testBlockDefaultPSStyleWithBlockGeneration() throws IOException, SAXException {
    testIndividual("block-default-psstyle-with-block-generation");
  }

  @Test
  public void testBlockDefaultPSStyleWithBlockGenerationIgnore() throws IOException, SAXException {
    testIndividual("block-default-psstyle-with-block-generation-ignore");
  }

  @Test
  public void testBlockDefaultStyle() throws IOException, SAXException {
    testIndividual("block-default-style");
  }

  @Test
  public void testBlockDefaultStyleWithBlockGeneration() throws IOException, SAXException {
    testIndividual("block-default-style-with-block-generation");
  }

  @Test
  public void testBlockDefaultStyleWithBlockGenerationIgnore() throws IOException, SAXException {
    testIndividual("block-default-style-with-block-generation-ignore");
  }

  @Test
  public void testBlockDefaultStyleWithBlockPSStyle() throws IOException, SAXException {
    testIndividual("block-default-style-with-block-psstyle");
  }

  @Test
  public void testBlockWhitespace() throws IOException, SAXException {
    testIndividual("block-whitespace");
  }

  @Test
  public void testCommentsFalse() throws IOException, SAXException {
    testIndividual("comments-false");
  }

  @Test
  public void testCommentsTrue() throws IOException, SAXException {
    testIndividual("comments-true");
  }


  @Test
  public void testCustomTemplateHeadings() throws IOException, SAXException {
    testIndividual("custom-template-headings");
  }

  @Test
  public void testCustomTemplateLists() throws IOException, SAXException {
    testIndividual("custom-template-lists", "document,numbering");
  }

  @Test
  public void testCustomTemplateTables() throws IOException, SAXException {
    testIndividual("custom-template-tables");
  }

  @Test
  public void testDefaultcharacterstyleNone() throws IOException, SAXException {
    testIndividual("defaultcharacterstyle-none");
  }

  @Test
  public void testDefaultcharacterstyleSet() throws IOException, SAXException {
    testIndividual("defaultcharacterstyle-set");
  }

  @Test
  public void testDefaultparagraphstyleNone() throws IOException, SAXException {
    testIndividual("defaultparagraphstyle-none");
  }

  @Test
  public void testDefaultparagraphstyleSet() throws IOException, SAXException {
    testIndividual("defaultparagraphstyle-set");
  }

  @Test
  public void testEmptyConfigurationBasicDocument() throws IOException, SAXException {
    testIndividual("empty-configuration-basic-document");
  }

  @Test
  public void testEmptyConfigurationBlock() throws IOException, SAXException {
    testIndividual("empty-configuration-block");
  }

  @Test
  public void testEmptyConfigurationCharacterStyles() throws IOException, SAXException {
    testIndividual("empty-configuration-character-styles");
  }

  @Test
  public void testEmptyConfigurationDefaultLists() throws IOException, SAXException {
    testIndividual("empty-configuration-default-lists", "document,numbering");
  }

  @Test
  public void testEmptyConfigurationHeadings() throws IOException, SAXException {
    testIndividual("empty-configuration-headings");
  }

  @Test
  public void testEmptyConfigurationImages() throws IOException, SAXException {
    testIndividual("empty-configuration-images");
  }

  @Test
  public void testEmptyConfigurationInline() throws IOException, SAXException {
    testIndividual("empty-configuration-inline");
  }

  @Test
  public void testEmptyConfigurationLinks() throws IOException, SAXException {
    testIndividual("empty-configuration-links");
  }

  @Test
  public void testEmptyConfigurationLists() throws IOException, SAXException {
    testIndividual("empty-configuration-lists", "document,numbering");
  }

  @Test
  public void testEmptyConfigurationNumberedHeadings() throws IOException, SAXException {
    testIndividual("empty-configuration-numbered-headings");
  }

  @Test
  public void testParagraphIndentStylesSet() throws IOException, SAXException {
    testIndividual("paragraph-indent-style-set");
  }

  @Test
  public void testEmptyConfigurationSections() throws IOException, SAXException {
    testIndividual("empty-configuration-sections");
  }

  @Test
  public void testEmptyConfigurationTables() throws IOException, SAXException {
    testIndividual("empty-configuration-tables");
  }

  @Test
  public void testHeadingsStyleSet() throws IOException, SAXException {
    testIndividual("headings-style-set");
  }

  @Test
  public void testHeadingsStyleSetNumberingFalse() throws IOException, SAXException {
    testIndividual("headings-style-set-numbering-false");
  }

  @Test
  public void testInlineDefaultNone() throws IOException, SAXException {
    testIndividual("inline-default-none");
  }

  @Test
  public void testInlineDefaultNoneWithFieldcode() throws IOException, SAXException {
    testIndividual("inline-default-none-with-fieldcode");
  }

  @Test
  public void testInlineDefaultNoneWithInlineGeneration() throws IOException, SAXException {
    testIndividual("inline-default-none-with-inline-generation");
  }

  @Test
  public void testInlineDefaultNoneWithInlineGenerationIgnore() throws IOException, SAXException {
    testIndividual("inline-default-none-with-inline-generation-ignore");
  }

  @Test
  public void testInlineDefaultNoneWithInlineGenerationTab() throws IOException, SAXException {
    testIndividual("inline-default-none-with-inline-generation-tab");
  }

  @Test
  public void testInlineDefaultNoneWithInlinePSStyle() throws IOException, SAXException {
    testIndividual("inline-default-none-with-inline-psstyle");
  }

  @Test
  public void testInlineDefaultPSStyle() throws IOException, SAXException {
    testIndividual("inline-default-psstyle");
  }

  @Test
  public void testInlineDefaultPSStyleWithFieldcode() throws IOException, SAXException {
    testIndividual("inline-default-psstyle-with-fieldcode");
  }

  @Test
  public void testInlineDefaultPSStyleWithInlineGeneration() throws IOException, SAXException {
    testIndividual("inline-default-psstyle-with-inline-generation");
  }

  @Test
  public void testInlineDefaultPSStyleWithInlineGenerationIgnore() throws IOException, SAXException {
    testIndividual("inline-default-psstyle-with-inline-generation-ignore");
  }

  @Test
  public void testInlineDefaultPSStyleWithInlineGenerationTab() throws IOException, SAXException {
    testIndividual("inline-default-psstyle-with-inline-generation-tab");
  }

  @Test
  public void testInlineDefaultStyle() throws IOException, SAXException {
    testIndividual("inline-default-style");
  }

  @Test
  public void testInlineDefaultStyleWithFieldcode() throws IOException, SAXException {
    testIndividual("inline-default-style-with-fieldcode");
  }

  @Test
  public void testInlineDefaultStyleWithInlineGeneration() throws IOException, SAXException {
    testIndividual("inline-default-style-with-inline-generation");
  }

  @Test
  public void testInlineDefaultStyleWithInlineGenerationIgnore() throws IOException, SAXException {
    testIndividual("inline-default-style-with-inline-generation-ignore");
  }

  @Test
  public void testInlineDefaultStyleWithInlineGenerationTab() throws IOException, SAXException {
    testIndividual("inline-default-style-with-inline-generation-tab");
  }

  @Test
  public void testInlineDefaultStyleWithInlinePSStyle() throws IOException, SAXException {
    testIndividual("inline-default-style-with-inline-psstyle");
  }

  // TODO fix roles so this test passes
  public void testListDefaultWithRoleSet() throws IOException, SAXException {
    testIndividual("list-default-with-role-set", "document,numbering");
  }

  @Test
  public void testListItemWhitespace() throws IOException, SAXException {
    testIndividual("list-item-whitespace");
  }

  @Test
  public void testPreformatSet() throws IOException, SAXException {
    testIndividual("preformat-set");
  }


  @Test
  public void testTableCellWhitespace() throws IOException, SAXException {
    testIndividual("table-cell-whitespace");
  }

  @Test
  public void testTablesDefaultEmpty() throws IOException, SAXException {
    testIndividual("tables-default-empty");
  }

  @Test
  public void testTablesDefaultEmptyWithRole() throws IOException, SAXException {
    testIndividual("tables-default-empty-with-role");
  }

  @Test
  public void testTablesDefaultEmptyWithRoleMultiple() throws IOException, SAXException {
    testIndividual("tables-default-empty-with-role-multiple");
  }

  @Test
  public void testTablesDefaultSet() throws IOException, SAXException {
    testIndividual("tables-default-set");
  }

  @Test
  public void testTablesDefaultSetWithRole() throws IOException, SAXException {
    testIndividual("tables-default-set-with-role");
  }

  @Test
  public void testTablesDefaultSetWithRoleMultiple() throws IOException, SAXException {
    testIndividual("tables-default-set-with-role-multiple");
  }

  @Test
  public void testTablesDefaultWithWidthAuto() throws IOException, SAXException {
    testIndividual("tables-default-with-width-auto");
  }

  @Test
  public void testTablesDefaultWithWidthDxa() throws IOException, SAXException {
    testIndividual("tables-default-with-width-dxa");
  }

  @Test
  public void testTablesDefaultWithWidthPct() throws IOException, SAXException {
    testIndividual("tables-default-with-width-pct");
  }

  @Test
  public void testTablesRoleWithWidthAuto() throws IOException, SAXException {
    testIndividual("tables-role-with-width-auto");
  }

  @Test
  public void testTablesRoleWithWidthDxa() throws IOException, SAXException {
    testIndividual("tables-role-with-width-dxa");
  }

  @Test
  public void testTablesRoleWithWidthPct() throws IOException, SAXException {
    testIndividual("tables-role-with-width-pct");
  }

  //@Test
  //public void testTemplateLists() throws IOException, SAXException {
  //  testIndividual("template-lists", "document,numbering");
  //}

  @Test
  public void testTocFalse() throws IOException, SAXException {
    testIndividual("toc-false");
  }

  @Test
  public void testTocTrue() throws IOException, SAXException {
    testIndividual("toc-true");
  }

  @Test
  public void testTocTrueHeadingFalse() throws IOException, SAXException {
    testIndividual("toc-true-heading-false");
  }

  @Test
  public void testTocTrueHeadingParagraphOutline() throws IOException, SAXException {
    testIndividual("toc-true-heading-paragraph-outline");
  }

  @Test
  public void testTocTrueHeadingTrue() throws IOException, SAXException {
    testIndividual("toc-true-heading-true");
  }

  @Test
  public void testTocTrueHeadingTrueMultiple() throws IOException, SAXException {
    testIndividual("toc-true-heading-true-multiple");
  }

  @Test
  public void testTocTrueOutlineFalse() throws IOException, SAXException {
    testIndividual("toc-true-outline-false");
  }

  @Test
  public void testTocTrueOutlineTrue() throws IOException, SAXException {
    testIndividual("toc-true-outline-true");
  }

  @Test
  public void testTocTrueOutlineTrueMultiple() throws IOException, SAXException {
    testIndividual("toc-true-outline-true-multiple");
  }

  @Test
  public void testTocTrueParagraphFalse() throws IOException, SAXException {
    testIndividual("toc-true-paragraph-false");
  }

  @Test
  public void testTocTrueParagraphTrue() throws IOException, SAXException {
    testIndividual("toc-true-paragraph-true");
  }

  @Test
  public void testTocTrueParagraphTrueMultiple() throws IOException, SAXException {
    testIndividual("toc-true-paragraph-true-multiple");
  }

  @Test
  public void testXrefStyle() throws IOException, SAXException {
    testIndividual("xref-style");
  }

  public void testAll() throws IOException, SAXException {
    File[] tests = CASES.listFiles();
    for (File test : tests) {
      testIndividual(test, "document", false);
    }
  }

  public void testIndividual(String folderName) throws IOException, SAXException {
    testIndividual(new File(CASES, folderName), "document", false);
  }

  public void testIndividual(String folderName, boolean saveWorking) throws IOException, SAXException {
    testIndividual(new File(CASES, folderName), "document", saveWorking);
  }

  public void testIndividual(String folderName, String filenames) throws IOException, SAXException {
    testIndividual(new File(CASES, folderName), filenames, true);
  }

  public void testIndividual(File dir, String filenames, boolean saveWorking) throws IOException, SAXException {
    if (dir.isDirectory()) {

      if (new File(dir, dir.getName() + ".psml").exists()) {
        System.out.println(dir.getName());
        File result = new File(RESULTS, dir.getName());
        result.mkdirs();
        process(dir, result, saveWorking);
        String[] names = filenames.split(",");
        for (String name : names) {
          File actual = new File(result, (!"document".equals(name) ? "working/prepacked/word/" : "") + name + ".xml");
          File expected = new File(dir, name + ".xml");

          // Check that the files exist
          Assert.assertTrue(actual.exists());
          Assert.assertTrue(expected.exists());

          Assert.assertTrue(actual.length() > 0);
          Assert.assertTrue(expected.length() > 0);
          assertXMLEqual(expected, actual, result);
        }
      } else {
        System.out.println("Unable to find PSML file for test:" + dir.getName());
      }
    }
  }


  private void process(File test, File result, boolean saveWorking) {

    ExportTask task = new ExportTask();
    task.setSrc(new File(test, test.getName() + ".psml"));
    task.setConfig(new File(test, "word-export-config.xml"));
    File template = new File(test, "word-export-template.dotx");
    if (!template.exists()) {
      template = new File(test, "word-export-template.docx");
    }
    task.setWordTemplate(template);
    task.setDest(new File(result, test.getName() + ".docx"));
    if (saveWorking) {
      File working = new File(result, "working");
      if (working.exists()) deleteDir(working);
      task.setWorking(working);
    }
    File media = new File(test, "media");
    if (media.exists()) {
      task.setMedia(media);
    }

    Parameter parameter = task.createParam();
    parameter.setName("generate-processed-psml");
    parameter.setValue("true");
    task.execute();

    return;
  }

  private static void deleteDir(File file) {
    File[] contents = file.listFiles();
    if (contents != null) {
        for (File f : contents) {
            deleteDir(f);
        }
    }
    file.delete();
  }

  private static void assertXMLEqual(File expected, File actual, File result) throws IOException, SAXException {
    FileReader exp = new FileReader(expected);
    FileReader got = new FileReader(actual);
    try {
      XMLAssert.assertXMLEqual(exp, got);
    } catch (AssertionFailedError error) {
      File expfile = new File(result, "expected-" + actual.getName());
      File actfile = new File(result, "actual-" + actual.getName());
      System.err.println("Expected: " + expfile.getCanonicalPath());
      //copyToSystemErr(expected);
      //System.err.println();
      System.err.println("Actual: " + actfile.getCanonicalPath());
      //copyToSystemErr(actual);
      //System.err.println();
      Files.copy(expected, expfile);
      Files.copy(actual, actfile);
      // uncomment the following to bulk update expected files for changes effecting all documents
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
