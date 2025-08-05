/*
 *  Copyright (c) 2014 Allette Systems pty. ltd.
 */
package org.pageseeder.docx;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class DOCXProcessorTest {

  @Test
  public void testProcess() {
    File source = new File("test/source/sample-1.psml");
    File media = new File("test/source/media");

    System.out.println("source exist " + source.exists());

    File destination = new File(TestConstants.OUTPUT + "test/sample-1.docx");
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
      Assertions.fail();
    }

    Assertions.assertTrue(destination.exists());
  }

}
