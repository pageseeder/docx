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
    if (!to.exists() && !to.createNewFile())
        throw new IOException("Unable to create file: " + to.getName());

    try (FileChannel source = new FileInputStream(from).getChannel();
         FileChannel destination = new FileOutputStream(to).getChannel()) {
      long size = source.size();
      long position = 0;
      while (position < size) {
        position += destination.transferFrom(source, position, size);
      }
      destination.transferFrom(source, 0, size);
    }
  }

  /**
   * Creates a new file and ensures it is a descendant of the base folder.
   *
   * @param base  the base folder
   * @param path  the relative path of the new file
   *
   * @return the new file
   *
   * @throws IOException if the new file is not a descendant of the base folder
   */
  public static File descendantFile(File base, String path) throws IOException {
    File descendant = new File(base, path);
    if (!descendant.getCanonicalPath().startsWith(base.getCanonicalPath())) {
      throw new IOException("Path results in a file outside base folder");
    }
    return descendant;
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
   * Rename all the files in the specified directory by adding a prefix to them.
   *
   * @param dir    the directory
   * @param prefix the prefix
   *
   * @throws IOException if problem renaming a file
   */
  public static void renameFiles(File dir, String prefix) throws IOException {
    if (dir.exists() && dir.isDirectory()) {
      File[] children = dir.listFiles();
      if (children != null) {
        for (File child : children) {
          if (!child.renameTo(new File(dir, prefix + child.getName())))
            throw new IOException("Unable to rename file: " + child.getName());
        }
      }
    }
  }

  /**
   * Copy directory and clean encoded image filenames by unencoded these chareters: !'()~
   * Word doesn't like these encoded for some reason.
   * Also it doesn't like dot encoded or unencoded so replace it with %25
   * which is encoded % that is not allowed in PageSeeder filenames
   * so there is no clash.
   *
   * @param source The source folder
   * @param target The target folder
   *
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
          int dot = aChildren.lastIndexOf('.');
          String base = (dot == -1) ? aChildren : aChildren.substring(0, dot);
          String extension = (dot == -1) ? "" : aChildren.substring(dot);
          String newfilename = base.replace("%21", "!").replace( "%27",
              "'").replace("%28", "(").replace("%29", ")").replace("%7E",
              "~").replace(".", "%25") + extension;
          copyDirectory(new File(source, aChildren), new File(target, newfilename));
        }
      }
    } else {
      copy(source, target);
    }
  }
}
