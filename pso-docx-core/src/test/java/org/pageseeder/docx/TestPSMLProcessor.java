/*
 *  Copyright (c) 2014 Allette Systems pty. ltd.
 */
package org.pageseeder.docx;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class TestPSMLProcessor {

  @Test
  public void TestProcess() {
    File source = new File("test/source/sample-1.docx");
    File config = new File("test/source/sample-1.config");


    System.out.println("source exist " + source.exists());

    File destination = new File("test/destination/sample-1.psml");
    if (!destination.getParentFile().exists()) {
      destination.getParentFile().mkdirs();
    }

    if (destination.exists()) {
      destination.delete();
    }

    try {
      PSMLProcessor process = new PSMLProcessor.Builder()
          .source(source)
          .destination(destination)
          .config(config)
          .media("media")
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
