package org.pageseeder.docx.util;

import org.pageseeder.docx.DOCXException;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;

/**
 * A bunch of IO utility functions.
 *
 * @author Christophe Lauret
 * @version 0.6
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
   * @throws DOCXException if the directory could not created.
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
      if (children != null) {
        for (String aChildren : children) {
          copyDirectory(new File(source, aChildren), new File(target, aChildren));
        }
      }
    } else {
      copy(source, target);
    }
  }
}
