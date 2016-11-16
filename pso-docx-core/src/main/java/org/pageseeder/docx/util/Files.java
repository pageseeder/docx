package org.pageseeder.docx.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;

import org.pageseeder.docx.DOCXException;

/**
 * A bunch of IO utility functions.
 *
 * @author Christophe Lauret
 * @version 28 February 2013
 */
public class Files {

  /** Utility class */
  private Files() {}

  /**
   * Copies the file using NIO
   *
   * @param from File to copy
   * @param to   Target file
   */
  public static void copy(File from, File to) throws IOException {
    Files.ensureDirectoryExists(to.getParentFile());
    if (!to.exists()) {
      to.createNewFile();
    }

    FileChannel source = null;
    FileChannel destination = null;
    try {
      source = new FileInputStream(from).getChannel();
      destination = new FileOutputStream(to).getChannel();
      destination.transferFrom(source, 0, source.size());
    } finally {
      if (source != null) {
        source.close();
      }
      if (destination != null) {
        destination.close();
      }
    }
  }

  /**
   * Ensures that the specified directory actually exists and creates it if necessary.
   *
   * @param directory The directory to check
   *
   * @throws BuildException if the directory could not created.
   */
  public static void ensureDirectoryExists(File directory) throws DOCXException {
    if (!directory.exists()) {
      boolean done = directory.mkdirs();
      if (!done) { throw new DOCXException("Unable to create target directory for preprocessor"); }
    }
  }

  /**
   * @param source The source folder
   * @param target The target folder
   * @throws IOException when I/O error occur.
   */
  public static void copyDirectory(File source, File target) throws IOException {
    if (source == null) { throw new NullPointerException("source is null"); }
    if (target == null) { throw new NullPointerException("target is null"); }

    if (source.isDirectory()) {
      if (!target.exists()) {
        target.mkdir();
      }
      String[] children = source.list();
      for (int i = 0; i < children.length; i++) {
        copyDirectory(new File(source, children[i]), new File(target, children[i]));
      }
    } else {
      copy(source, target);
    }
  }
}
