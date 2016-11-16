/*
 * Copyright (c) 1999-2012 weborganic systems pty. ltd.
 */
package org.pageseeder.docx.ant;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.transform.Templates;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.pageseeder.docx.util.Files;
import org.pageseeder.docx.util.XSLT;
import org.pageseeder.docx.util.ZipUtils;

/**
 * An ANT task to export a PageSeeder document to a Word document using the DOCX format.
 *
 * @author Christophe Lauret
 * @version 18 March 2014
 */
public final class ExportTask extends Task {

  /**
   * The PageSeeder documents to export.
   *
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
   * The media folder.
   */
  private File media;

  /**
   * List of custom parameters specified that can be specified from the command-line
   */
  private List<Parameter> params = new ArrayList<Parameter>();

  // Set properties
  // ----------------------------------------------------------------------------------------------

  /**
   * Set the source file: a PageSeeder document to export as DOCX.
   *
   * @param source The master document for document to export.
   */
  public void setSrc(File source) {
    if (!(source.exists())) { throw new BuildException("the document " + source.getName() + " doesn't exist"); }
    if (source.isDirectory()) { throw new BuildException("the document " + source.getName() + " can't be a directory"); }
    this.source = source;
  }

  /**
   * Set the destination folder where PSML files should be stored.
   *
   * @param destination Where to store the PSML files.
   */
  public void setDest(File destination) {
    if (destination.exists() && destination.isDirectory()) { throw new BuildException("if document DOCX exists, it must be a file, not " + destination); }
    this.destination = destination;
  }

  /**
   * Set DOTX template to use as a base.
   *
   * @param source The master document for document to export.
   */
  public void setWordTemplate(File dotx) {
    if (!(dotx.exists())) { throw new BuildException("the Word template " + dotx.getName() + " doesn't exist"); }
    if (dotx.isDirectory()) { throw new BuildException("the document " + dotx.getName() + " can't be a directory"); }
    this.dotx = dotx;
  }

  /**
   * Set the working folder (optional).
   *
   * @param working The working folder.
   */
  public void setWorking(File working) {
    if (working.exists() && !working.isDirectory()) { throw new BuildException("if working folder exists, it must be a directory"); }
    this.working = working;
  }

  /**
   * Set the configuration file (optional).
   *
   * @param config The configuration file.
   */
  public void setConfig(File config) {
    if (!config.exists() || config.isDirectory()) { throw new BuildException("your configuration file must exist and be a file"); }
    this.config = config;
  }

  /**
   * Set the media folder (optional).
   * @param media The media folder.
   */
  public void setMedia(File media) {
    if (!media.exists() || !media.isDirectory()) { throw new BuildException("your media folder must exist and be a directory"); }
    this.media = media;
  }

  /**
   * Create a parameter object and stores it in the list To be used by the XSLT transformation
   *
   * <p>This follows the ANT convention to allow the <code>param</code> element to be specified.
   *
   * @return The parameter object.
   */
  public Parameter createParam() {
    Parameter param = new Parameter();
    this.params.add(param);
    return param;
  }

  // Execute
  // ----------------------------------------------------------------------------------------------

  @Override
  public void execute() throws BuildException {
    if (this.source == null) { throw new BuildException("Source presentation must be specified using 'src' attribute"); }
    // Defaulting working directory
    if (this.working == null) {
      String tmp = "antdocx-" + System.currentTimeMillis();
      this.working = new File(System.getProperty("java.io.tmpdir"), tmp);
    }
    if (!this.working.exists()) {
      this.working.mkdirs();
    }

    // Check parameters
    for (Parameter p : this.params) {
      if (p.getName() == null) { throw new BuildException("parameters must have a name"); }
      if (p.getName().startsWith("_")) { throw new BuildException("parameter names must not start with an underscore"); }
    }

    // The name of the presentation
    String name = this.source.getName();
    if (name.endsWith(".psml")) {
      name = name.substring(0, name.length() - 5);
    }

    // Defaulting destination directory
    if (this.destination == null) {
      this.destination = new File(this.source.getParentFile(), ".docx");
      log("Destination set to " + this.destination.getName());
    }

    // Defaulting config file
    if (this.config == null) {
      // com.pageseeder.ant.docx.xslt.export.wpml-config.xml
      this.config = null; // TODO
      log("Using default wpml configuration for export");
    }

    // 0. Ensure we have a word template to use
    if (this.dotx == null) {
      log("No DOTX specified, using default word temlate ");
      this.dotx = getBuiltinWordTemplate(this.working);
    }

    // 1. Let's unzip the dotx
    log("Extracting DOTX: " + this.dotx.getName());
    File dotx = new File(this.working, "dotx");
    dotx.mkdirs();
    ZipUtils.unzip(this.dotx, dotx);
    File prepacked = new File(this.working, "prepacked");
    prepacked.mkdirs();
    ZipUtils.unzip(this.dotx, prepacked);
    // 2. Sanity check
    log("Checking DOTX");
    File contentTypes = new File(dotx, "[Content_Types].xml");
    File relationships = new File(dotx, "_rels/.rels");
    if (!contentTypes.exists()) { throw new BuildException("Not a valid DOTX: unable to find [Content_Types].xml"); }
    if (!relationships.exists()) { throw new BuildException("Not a valid DOTX: unable to find _rels/.rels"); }

    // 3. Preparing the output
    //File prepacked = new File(this.working, "prepacked");
    File document = new File(prepacked, "word/document.xml");
    Files.ensureDirectoryExists(document.getParentFile());

    // 3. (extra) copy everything from the media folder to prepacked folder
    if (this.media != null) {
      log("Copy media files");
      File mediaFolder = new File(prepacked, "word/media");
      if (!mediaFolder.exists()) {
        mediaFolder.mkdirs();
      }
      try {
        Files.copyDirectory(this.media, mediaFolder);
      } catch (IOException e) {
        // FIXME store to somewhere for debug.
        e.printStackTrace();
      }
    }
    
    File unnestedFolder = new File(this.working, "unnested");
    if (!unnestedFolder.exists()) {
    	unnestedFolder.mkdirs();
    }
    try {
      Files.copyDirectory(this.source.getParentFile(), unnestedFolder);
    } catch (IOException e) {
      // FIXME store to somewhere for debug.
      e.printStackTrace();
    }
    
    // 4. Unnest the files
    log("Unnest");
    Templates unnest = XSLT.getTemplatesFromResource("org/pageseeder/docx/xslt/export/unnest.xsl");
    File sourceDocument = this.source;
    File newSourceDocument = new File(this.working, "unnested/document-unnested.psml");
    newSourceDocument.getParentFile().mkdir();
    Map<String, String> noParameters = Collections.emptyMap();
    XSLT.transform(sourceDocument, newSourceDocument, unnest, noParameters);
  	
    
    // 5. Process the files
    log("Process with XSLT");

    // Parse templates
    Templates templates = XSLT.getTemplatesFromResource("org/pageseeder/docx/xslt/export.xsl");

    // Initiate parameters
    Map<String, String> parameters = new HashMap<String, String>();
    parameters.put("_outputfolder", prepacked.toURI().toString());
    parameters.put("_dotxfolder", dotx.toURI().toString());
    parameters.put("_docxfilename", this.destination.getName());
    if (this.config != null) {
      parameters.put("_configfileurl", this.config.toURI().toString());
    }

    // Add custom parameters
    for (Parameter p : this.params) {
      parameters.put(p.getName(), p.getValue());
    }

    // Transform
    XSLT.transform(newSourceDocument, document, templates, parameters);

    // 6. Zip the generator content
    if (parameters.containsKey("generate-processed-psml") && parameters.get("generate-processed-psml").equals("true"))
    {
      log("Debug Mode");
      File newDestinationDocument = new File(this.destination.getParentFile() + "/document.xml");
      try {
        Files.copy(document, newDestinationDocument);
      } catch (IOException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      }
      this.destination.getParentFile().mkdirs();
      ZipUtils.zip(prepacked, this.destination);
    }
    else
    {
      log("Zipping");
      this.destination.getParentFile().mkdirs();
      ZipUtils.zip(prepacked, this.destination);
    }

  }

  // Helpers
  // ----------------------------------------------------------------------------------------------

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
      ClassLoader loader = ExportTask.class.getClassLoader();
      InputStream in = loader.getResourceAsStream("org/pageseeder/docx/resource/default.dotx");
      try {
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
      } finally {
        in.close();
      }
    } catch (IOException ex) {
      throw new BuildException("Unable to extract default word template", ex);
    }
    return tmp;
  }

}
