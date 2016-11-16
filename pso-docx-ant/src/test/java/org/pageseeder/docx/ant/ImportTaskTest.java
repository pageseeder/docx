package org.pageseeder.docx.ant;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;

import org.custommonkey.xmlunit.XMLAssert;
import org.junit.Assert;
import org.junit.Test;
import org.xml.sax.SAXException;

import junit.framework.AssertionFailedError;

public class ImportTaskTest {

  private static final File CASES = new File("src/test/import/cases");

  private static final File RESULTS = new File("build/test/import/results");

  @Test
  public void testAll() throws IOException, SAXException {
    File[] tests = CASES.listFiles();
    for (File test : tests) {
      if (test.isDirectory()) {

        if (new File(test, test.getName()+".docx").exists()) {
          System.out.println(test.getName());
          File actual = process(test);
          File expected = new File(test, "expected.psml");

          // Check that the files exist
          Assert.assertTrue(actual.exists());
          Assert.assertTrue(expected.exists());

          Assert.assertTrue(actual.length() > 0);
          Assert.assertTrue(expected.length() > 0);
          assertXMLEqual(expected, actual);
        } else {
          System.out.println("Unable to find DOCX file for test:"+test.getName());
        }
      }
    }
  }


  private File process(File test) {
    File result = new File(RESULTS, test.getName());
    result.mkdirs();

    ImportTask task = new ImportTask();
    task.setSrc(new File(test, test.getName()+".docx"));
    task.setConfig(new File(test, "word-import-config.xml"));
    task.setDest(result);
    Parameter parameter = task.createParam();
    parameter.setName("generate-processed-psml");
    parameter.setValue("true");
    task.execute();

    return new File(result, test.getName()+".psml");
  }


  private static void assertXMLEqual(File expected, File actual) throws IOException, SAXException {
    FileReader exp = new FileReader(expected);
    FileReader got = new FileReader(actual);
    try {
      XMLAssert.assertXMLEqual(exp, got);
    } catch (AssertionFailedError error) {
      System.err.println("Expected:");
      copyToSystemErr(expected);
      System.err.println();
      System.err.println("Actual:");
      copyToSystemErr(actual);
      System.err.println();
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
