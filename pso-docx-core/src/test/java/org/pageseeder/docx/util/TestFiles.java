/*
 *  Copyright (c) 2014 Allette Systems pty. ltd.
 */
package org.pageseeder.docx.util;

import java.io.File;
import java.io.IOException;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.pageseeder.docx.DOCXException;

import static org.junit.jupiter.api.Assertions.assertThrows;

public class TestFiles {

  private File testingFolder1;
  private File testingFolder2;

  @BeforeEach
  public void init() throws IOException {
    this.testingFolder1 = new File("test/c1/source");
    this.testingFolder2 = new File("test/c1/target");

    if (!this.testingFolder1.exists()) {
      this.testingFolder1.mkdirs();
    }
    if (!this.testingFolder2.exists()) {
      this.testingFolder2.mkdirs();
    }

    File sampleImage = new File(this.testingFolder1, "media");
    sampleImage.createNewFile();

    File sampleText = new File(this.testingFolder1, "test.txt");
    sampleText.createNewFile();

    File sampleFolder = new File(this.testingFolder1, "folder");
    sampleFolder.mkdirs();

    File sampleFile = new File(sampleFolder, "file-in-sub.txt");
    sampleFile.createNewFile();

    sampleImage = null;
    sampleText = null;

  }

  @Test
  public void copyDir() throws IOException {
    Files.copyDirectory(this.testingFolder1, this.testingFolder2);

    Assertions.assertEquals(this.testingFolder2.exists(), true);
    Assertions.assertEquals(new File(this.testingFolder2, "folder").exists(), true);

  }

  @Test
  public void copyNullDir() throws IOException {
    assertThrows(NullPointerException.class, () -> {
      Files.copyDirectory(null, null);
    });
  }

  @Test
  public void copyDirToFile() throws IOException {
    assertThrows(DOCXException.class, () -> {
      File file = new File(this.testingFolder2, "file");
      file.createNewFile();

      Files.copyDirectory(this.testingFolder1, file);
    });
  }
}
