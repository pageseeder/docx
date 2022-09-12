/*
 *  Copyright (c) 2014 Allette Systems pty. ltd.
 */
package org.pageseeder.docx;

import org.pageseeder.docx.util.Files;
import org.pageseeder.docx.util.XSLT;
import org.pageseeder.docx.util.ZipUtils;

import javax.xml.transform.Templates;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

/**
 * Converts DocX to PSML.
 *
 * @author Ciber Cai
 * @author Hugo Inacio
 * @author Philip Rutherford
 */
public final class PSMLProcessor {

  /**
   * The builder
   */
  private final Builder _builder;

  /**
   * A writer to store the log
   */
  private final Writer _log;

  private PSMLProcessor(Builder producer) {
    this(producer, new StringWriter());
  }

  private PSMLProcessor(Builder producer, Writer log) {
    if (producer.source() == null) { throw new NullPointerException("source is null"); }
    if (producer.destination() == null) { throw new NullPointerException("destination is null"); }
    this._builder = producer;
    this._log = log;
  }

  /**
   * @return the log in string
   */
  public String getLog() {
    if (this._log != null) {
      try {
        this._log.flush();
        this._log.close();
      } catch (IOException e) {
        return "";
      }
      return this._log.toString();
    } else {
      return "";
    }
  }

  /**
   * to generate the psml.
   * @throws IOException
   */
  public void process() throws IOException {

    // Defaulting destination directory
    if (this._builder.destination() == null) {
      this._builder.destination = this._builder.source.getParentFile();
      log("Destination set to source directory " + this._builder.destination.getAbsolutePath() + "");
    }

    // The name of the presentation
    String sourcename = this._builder.source().getName();
    if (sourcename.toLowerCase().endsWith(".docx")) {
      sourcename = sourcename.substring(0, sourcename.length()-5);
    }
    File folder;
    String filename;
    if (this._builder.destination().getName().endsWith(".psml")) {
      folder = this._builder.destination().getParentFile();
      filename = this._builder.destination().getName().substring(0, this._builder.destination().getName().length() - 5);;
    } else {
      folder = this._builder.destination();
      filename = sourcename.replaceAll(" ", "_").toLowerCase();
    }

    // Ensure that output folder exists
    if (!folder.exists()) {
      folder.mkdirs();
    }

    // 1. Unzip file
    log("Extracting DOCX: " + this._builder.source().getName());
    File unpacked = new File(this._builder.working(), "unpacked");
    unpacked.mkdir();
    ZipUtils.unzip(this._builder.source(), unpacked);

    // 2. Sanity check
    log("Checking docx");
    File contentTypes = new File(unpacked, "[Content_Types].xml");
    File relationships = new File(unpacked, "_rels/.rels");
    if (!contentTypes.exists()) throw new DOCXException("Not a valid DOCX: unable to find [Content_Types].xml");
    if (!relationships.exists()) throw new DOCXException("Not a valid DOCX: unable to find _rels/.rels");

    // Parse templates
    Templates templates = XSLT.getTemplatesFromResource("org/pageseeder/docx/xslt/import.xsl");
    String outuri = folder.toURI().toString();

    String componentFolderName = this._builder.component() == null ? "components" : this._builder.component();
    String mediaFolderName = this._builder.media() == null ? "images" :
      ("".equals(this._builder.media()) ? filename + "_files" : this._builder.media());

    // Initiate parameters
    Map<String, String> parameters = new HashMap<>();
    parameters.put("_rootfolder", unpacked.toURI().toString());
    parameters.put("_outputfolder", outuri);
    parameters.put("_docxfilename", sourcename);
    parameters.put("_mediafoldername", mediaFolderName);
    parameters.put("_componentfoldername", componentFolderName);
    if (this._builder.config() != null) {
      parameters.put("_configfileurl", this._builder.config().toURI().toString());
    }
    // Add custom parameters
    parameters.putAll(this._builder.params());

    // 3. Unnest
    log("Unnest");
    Templates unnest = XSLT.getTemplatesFromResource("org/pageseeder/docx/xslt/import-unnest.xsl");
    File document = new File(unpacked, "word/document.xml");
    File newDocument = new File(unpacked, "word/new-document.xml");
    XSLT.transform(document, newDocument, unnest, parameters, null);

    // 3.1 Unnest Endnotes file if it exists
    File endnotes = new File(unpacked, "word/endnotes.xml");
    if(endnotes.canRead()){
    	XSLT.transform(endnotes, new File(unpacked, "word/new-endnotes.xml"), unnest, parameters, null);
    }
    // 3.2 Unnest Footnotes file if it exists
    File footnotes = new File(unpacked, "word/footnotes.xml");
    if(footnotes.canRead()){
    	XSLT.transform(footnotes, new File(unpacked, "word/new-footnotes.xml"), unnest, parameters, null);
    }

	// 4. copy the media files
    log("Copy media");
    copyMedia(unpacked, folder, mediaFolderName);

    // 5. Process the files
    log("Process with XSLT (this may take several minutes)");
    XSLT.transform(contentTypes, new File(folder, filename + ".psml"), templates, parameters, null);

  }

  // Helpers
  // ----------------------------------------------------------------------------------------------

  private void log(String log) throws IOException {
    this._log.append(log).append("\n");
  }

  private static void copyMedia(File from, File to, String folder) {
    File media = new File(from, "word/media");
    if (!media.exists()) return;
    File mediaOut = new File(to, folder);
    try {
      Files.ensureDirectoryExists(mediaOut);
      File[] files = media.listFiles();
      if (files != null) {
        for (File m : files) {
          // don't import template images
          if (!m.getName().startsWith(DOCXProcessor.MEDIA_PREFIX)) {
            // decode filename because the image/@src will be decoded by PageSeeder
            Files.copy(m, new File(mediaOut, URLDecoder.decode(m.getName(), "UTF-8").toLowerCase()));
          }
        }
      }
    } catch (IOException ex) {
      // TODO clean up files
      throw new DOCXException(ex);
    }
  }

  public static class Builder {

    /**
     * The PageSeeder documents to export.
     * <p>The source should point to the main PSML document.
     *
     */
    private File source;

    /**
     * The Word document to generate.
     */
    private File destination;

    /**
     * The name of the working directory
     */
    private File working;

    /**
     * The configuration.
     */
    private File config;

    /**
     * The media files folder location.
     */
    private String media;

    /**
     * The component files folder location.
     */
    private String component;

    /**
     * List of custom parameters specified that can be specified from the command-line
     */
    private Map<String, String> params;

    /**
     *  A writer to store the log
     */
    private Writer log;

    /**
     * @return the srouce
     */
    private File source() {
      return this.source;
    }

    /**
     * @return destination
     */
    private File destination() {
      if (this.destination == null) {
        this.destination = new File(this.source.getParentFile(), "output.psml");
      }
      return this.destination;
    }

    /**
     * @return working
     */
    private File working() {
      if (this.working == null) {
        String tmp = "docx-" + System.currentTimeMillis();
        this.working = new File(System.getProperty("java.io.tmpdir"), tmp);
      }
      if (!this.working.exists()) {
        this.working.mkdirs();
      }
      return this.working;
    }

    /**
     * @return the configuration file
     */
    private File config() {
      // check whether the file is exist
      if (this.config != null && this.config.exists()) {
        return this.config;
      } else {
        return null;
      }
    }

    /**
     * @return the media folder
     */
    private String media() {
      return this.media;
    }

    /**
     * @return the component folder
     */
    private String component() {
      return this.component;
    }

    /**
     * @return the custom parameters for docx.
     */
    private Map<String, String> params() {
      if (this.params == null) {
        this.params = new HashMap<>();
      }
      return this.params;
    }

    /**
     * @param log the Writer to store the log
     * @return {@link Builder}
     */
    public Builder log(Writer log) {
      this.log = log;
      return this;
    }

    /**
     * @param source set the source
     * @return {@link Builder}
     */
    public Builder source(File source) {
      this.source = source;
      return this;
    }

    /**
     * @param destination set the destination
     * @return {@link Builder}
     */
    public Builder destination(File destination) {
      this.destination = destination;
      return this;
    }

    /**
     * @param working set the working folder
     * @return {@link Builder}
     */
    public Builder working(File working) {
      this.working = working;
      return this;
    }

    /**
     * @param config set the configuration file
     * @return {@link Builder}
     */
    public Builder config(File config) {
      this.config = config;
      return this;
    }

    /**
     * @param media the media folder
     * @return {@link Builder}
     */
    public Builder media(String media) {
      this.media = media;
      return this;
    }

    /**
     * @param component the component folder
     * @return {@link Builder}
     */
    public Builder component(String component) {
      this.component = component;
      return this;
    }

    public Builder params(Map<String, String> params) {
      this.params = params;
      return this;
    }

    /**
     * @return the DocxProcessor
     */
    public PSMLProcessor build() {
      if (this.log != null) {
        return new PSMLProcessor(this, this.log);
      } else {
        return new PSMLProcessor(this);
      }
    }
  }

}
