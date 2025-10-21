/*
 * Copyright (c) 1999-2012 weborganic systems pty. ltd.
 */
package org.pageseeder.docx.util;

import org.pageseeder.docx.DOCXException;

import java.io.*;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipOutputStream;


/**
 * A utility class for common Zip functions.
 *
 * @author Christophe Lauret
 * @version 12 April 2012
 */
public final class ZipUtils {

  /**
   * Size of internal buffer.
   */
  private static final int BUFFER = 2048;

  /** Utility class. */
  private ZipUtils() {
  }

  /**
   * Unzip the the file at the specified location.
   *
   * @param src  The file to unzip
   * @param dest The destination folder
   */
  public static void unzip(File src, File dest) {
    try {
      ZipEntry entry;
      try (ZipFile zip = new ZipFile(src)) {
        for (Enumeration<? extends ZipEntry> e = zip.entries(); e.hasMoreElements(); ) {
          entry = e.nextElement();
          String name = entry.getName();
          // Ensure that the folder exists
          if (name.indexOf('/') > 0) {
            String folder = name.substring(0, name.lastIndexOf('/'));
            File dir = Files.descendantFile(dest, folder);
            if (!dir.exists()) {
              dir.mkdirs();
            }
          }
          // Only process files
          if (!entry.isDirectory()) {
            BufferedInputStream is = new BufferedInputStream(zip.getInputStream(entry));
            int count;
            byte[] data = new byte[BUFFER];
            File f = Files.descendantFile(dest, name);
            FileOutputStream fos = new FileOutputStream(f);
            try (BufferedOutputStream out = new BufferedOutputStream(fos, BUFFER)) {
              while ((count = is.read(data, 0, BUFFER)) != -1) {
                out.write(data, 0, count);
              }
              out.flush();
              is.close();
            }
          }
        }
      }
    } catch (IOException ex) {
      throw new DOCXException(ex);
    }
  }


  /**
   * Zip the specified file or folder.
   *
   * @param src  The folder to zip
   * @param dest The destination zip
   */
  public static void zip(File src, File dest) {
    try (ZipOutputStream out = new ZipOutputStream(new BufferedOutputStream(new FileOutputStream(dest)))) {
      if (src.isFile()) {
        // Source is a single file
        addToZip(src, out, null);

      } else {
        // Source is directory
        File[] children = src.listFiles();
        if (children != null) {
          for (File f : children) {
            addToZip(f, out, null);
          }
        }
      }

    } catch (IOException ex) {
      throw new DOCXException(ex);
    }
  }

  /**
   * Zip the specified file or folder.
   *
   * @param file   The file or folder to zip
   * @param out    The destination zip stream
   * @param folder The current folder
   *
   * @throws IOException If an IO error occurs.
   */
  private static void addToZip(File file, ZipOutputStream out, String folder) throws IOException {
    // Directory
    if (file.isDirectory()) {
      File[] files = file.listFiles();
      if (files != null) {
        for (File f : files) {
          addToZip(f, out, (folder != null ? folder + file.getName() : file.getName()) + "/");
        }
      }

    // File
    } else {
      byte[] data = new byte[BUFFER];
      try (BufferedInputStream origin = new  BufferedInputStream(new FileInputStream(file), BUFFER)) {
        ZipEntry entry = new ZipEntry(folder != null? folder + file.getName() : file.getName());
        out.putNextEntry(entry);
        int count;
        while ((count = origin.read(data, 0, BUFFER)) != -1) {
          out.write(data, 0, count);
        }
      } catch (IOException ex) {
        throw new DOCXException(ex);
      }
    }
  }

}
