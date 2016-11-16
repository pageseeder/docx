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

public class ExportTaskTest {

  private static final File CASES = new File("src/test/export/cases");

  private static final File RESULTS = new File("build/test/export/results");

  @Test
  public void testAll() throws IOException, SAXException {
    File[] tests = CASES.listFiles();
    for (File test : tests) {
      if (test.isDirectory()) {

        if (new File(test, test.getName()+".psml").exists()) {
          System.out.println(test.getName());
          File actual = process(test);
          File expected = new File(test, "document.xml");

          // Check that the files exist
          Assert.assertTrue(actual.exists());
          Assert.assertTrue(expected.exists());

          Assert.assertTrue(actual.length() > 0);
          Assert.assertTrue(expected.length() > 0);
          assertXMLEqual(expected, actual);
        } else {
          System.out.println("Unable to find PSML file for test:"+test.getName());
        }
      }
    }
  }


  private File process(File test) {
    File result = new File(RESULTS, test.getName());
    result.mkdirs();
    
    ExportTask task = new ExportTask();
    task.setSrc(new File(test, test.getName()+".psml"));
    task.setConfig(new File(test, "word-export-config.xml"));
    task.setWordTemplate(new File(test, "word-export-template.dotx"));
    task.setDest(new File(result,test.getName()+".docx"));
    
    Parameter parameter = task.createParam();
    parameter.setName("generate-processed-psml");
    parameter.setValue("true");
    task.execute();

    return new File(result, "document.xml");
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
