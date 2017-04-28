/*
 *  Copyright (c) 2014 Allette Systems pty. ltd.
 */
package org.pageseeder.docx;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

import org.junit.Assert;
import org.junit.Test;

public class TestPSMLProcessor {

  @Test
  public void TestProcess() {
    File source = new File("test/source/sample-1.psml");
    File media = new File("test/source/media");

    System.out.println("source exist " + source.exists());

    File destination = new File("test/destination/sample-1.docx");
    if (!destination.getParentFile().exists()) {
      destination.getParentFile().mkdirs();
    }

    if (destination.exists()) {
      destination.delete();
    }

    try {
      DOCXProcessor process = new DOCXProcessor.Builder()
          .source(source)
          .destination(destination)
          .media(media)
          .log(new PrintWriter(System.out))
          .build();
      process.process();
      System.out.println(process.getLog());
    } catch (IOException ex) {
      ex.printStackTrace();
      Assert.fail();
    }

    Assert.assertTrue(destination.exists());
  }

}
