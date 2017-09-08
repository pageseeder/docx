/*
 *  Copyright (c) 2014 Allette Systems pty. ltd.
 */
package org.pageseeder.docx;

import org.pageseeder.docx.util.Files;
import org.pageseeder.docx.util.XSLT;
import org.pageseeder.docx.util.ZipUtils;

import javax.xml.transform.Templates;
import java.io.*;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/**
 * <p>The docx processor is extract from {@link ExportTask} in the future implementation should merge the
 * {@link DOCXProcessor} with the ExportTask. </p>
 *
 * @author Ciber Cai
 * @author Christophe Lauret
 * @version 0.6
 */
public final class DOCXProcessor {

  /**
   * The builder
   */
  private final Builder _builder;

  /**
   * A writer to store the log
   */
  private final Writer _log;

  /**
   * @param builder
   */
  private DOCXProcessor(Builder builder) {
    this(builder, new StringWriter());
  }

  /**
   * @param builder
   * @param log the writer to store log
   */
  private DOCXProcessor(Builder builder, Writer log) {
    if (builder.source() == null) { throw new NullPointerException("source is null"); }
    if (builder.destination() == null) { throw new NullPointerException("destination is null"); }
    this._builder = builder;
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
   * to generate the docx.
   * @throws IOException
   */
  public void process() throws IOException {
    // The name of the presentation
    String name = this._builder.source().getName();
    if (name.endsWith(".psml")) {
      name = name.substring(0, name.length() - 5);
    }

    // 0. Ensure we have a word template to use

    // 1. Let's unzip the dotx
    log("Extracting DOTX: " + this._builder.dotx().getName());
    File dotx = new File(this._builder.working(), "dotx");
    dotx.mkdirs();
    ZipUtils.unzip(this._builder.dotx(), dotx);

    // 2. Sanity check
    log("Checking DOTX");
    File contentTypes = new File(dotx, "[Content_Types].xml");
    File relationships = new File(dotx, "_rels/.rels");
    File numbering = new File(dotx, "word/numbering.xml");
    if (!contentTypes.exists()) { throw new DOCXException("Not a valid DOTX: unable to find [Content_Types].xml"); }
    if (!relationships.exists()) { throw new DOCXException("Not a valid DOTX: unable to find _rels/.rels"); }
    if (!numbering.exists()) { throw new DOCXException("Not a valid DOTX: unable to find word/numbering.xml"); }

    // 3. Preparing the output
    File prepacked = new File(this._builder.working(), "prepacked");
    prepacked.mkdirs();
    ZipUtils.unzip(this._builder.dotx(), prepacked);
    File document = new File(prepacked, "word/document.xml");
    Files.ensureDirectoryExists(document.getParentFile());

    // 3. (extra) copy everything from the media folder to prepacked folder
    if (this._builder.media() != null) {
      log("Copy media files");
      File mediaFolder = new File(prepacked, "word/media");
      if (!mediaFolder.exists()) {
        mediaFolder.mkdirs();
      }
      Files.copyDirectory(this._builder.media(), mediaFolder);
    }

    // 4. Unnest the files
    log("Unnest");
    Templates unnest = XSLT.getTemplatesFromResource("org/pageseeder/docx/xslt/export/unnest.xsl");
    File sourceDocument = this._builder.source();
    File newSourceDocument = new File(this._builder.working(), "unnested/document-unnested.psml");
    newSourceDocument.getParentFile().mkdir();
    Map<String, String> noParameters = Collections.emptyMap();
    XSLT.transform(sourceDocument, newSourceDocument, unnest, noParameters);

    // 5. Process the files
    log("Process with XSLT");
    // Parse templates
    Templates templates = XSLT.getTemplatesFromResource("org/pageseeder/docx/xslt/export.xsl");

    // Initiate parameters
    Map<String, String> parameters = new HashMap<>();
    parameters.put("_outputfolder", prepacked.toURI().toString());
    parameters.put("_dotxfolder", dotx.toURI().toString());
    parameters.put("_docxfilename", this._builder.destination().getName());
    if (this._builder.config() != null) {
      parameters.put("_configfileurl", this._builder.config().toURI().toString());
    }

    // Add custom parameters
    parameters.putAll(this._builder.params());

    // Transform
    XSLT.transform(newSourceDocument, document, templates, parameters);

    // 6. Zip the generator content
    // TODO is this a good name and behavior for the parameter?
    if (parameters.containsKey("generate-processed-psml") && parameters.get("generate-processed-psml").equals("true")) {
      log("Debug Mode");
      File newDestinationDocument = new File(this._builder.destination().getParentFile() + "/document.xml");
      try {
        Files.copy(document, newDestinationDocument);
      } catch (IOException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      }
      this._builder.destination().getParentFile().mkdirs();
      ZipUtils.zip(prepacked, this._builder.destination());
    } else {
      log("Zipping");
      this._builder.destination().getParentFile().mkdirs();
      ZipUtils.zip(prepacked, this._builder.destination());
    }
  }

  // Helpers
  // ----------------------------------------------------------------------------------------------

  private void log(String log) throws IOException {
    this._log.append(log).append("\n");
  }

  public static class Builder {

    /**
     * The PageSeeder documents to export.
     * <p>The source should point to the main PSML document.
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
     * The dotx file to use.
     */
    private File dotx;

    /**
     * The configuration.
     */
    private File config;

    /**
     * The media files folder location.
     */
    private File media;

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
        this.destination = new File(this.source.getParentFile(), "output.docx");
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
     * @return the doxc template
     */
    private File dotx() {
      if (this.dotx == null) {
        this.dotx = getBuiltinWordTemplate(working());
      }
      // check whether the file is exist
      if (this.dotx != null && this.dotx.exists()) {
        return this.dotx;
      } else {
        return null;
      }

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
    private File media() {
      if (this.media != null && this.media.exists() && this.media.isDirectory()) {
        return this.media;
      } else {
        return null;
      }
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
     * @param dotx set the template
     * @return {@link Builder}
     */
    public Builder dotx(File dotx) {
      this.dotx = dotx;
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
    public Builder media(File media) {
      this.media = media;
      return this;
    }

    /**
     * @param params set the custom parameters.
     * @return {@link Builder}
     */
    public Builder params(Map<String, String> params) {
      this.params = params;
      return this;
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
     * @return the DocxProcessor
     */
    public DOCXProcessor build() {
      if (this.log != null) {
        return new DOCXProcessor(this, this.log);
      } else {
        return new DOCXProcessor(this);
      }
    }

    /**
     * Loads the built-in word template from the resource in classpath and saves it as a file.
     *
     * @param working The working folder where the template file should be loaded.
     *
     * @return a copy of the built-in template as a file
     */
    private static File getBuiltinWordTemplate(File working) {
      File tmp = new File(working, "default.dotx");
      try {
        ClassLoader loader = DOCXProcessor.class.getClassLoader();
        try (InputStream in = loader.getResourceAsStream("org/pageseeder/docx/resource/default.dotx")) {
          FileOutputStream out = new FileOutputStream(tmp);
          try {
            final byte[] buffer = new byte[1024];
            int n;
            while ((n = in.read(buffer)) != -1) {
              out.write(buffer, 0, n);
            }
          } finally {
            out.close();
          }
        }
      } catch (IOException ex) {
        throw new DOCXException("Unable to extract default word template", ex);
      }
      return tmp;
    }

  }

}
