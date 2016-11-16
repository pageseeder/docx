/*
 * Copyright (c) 1999-2012 weborganic systems pty. ltd.
 */
package org.pageseeder.docx.ant;

import java.io.File;
import java.io.IOException;
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
 * An ANT task to import a DOCX file as one or more PageSeeder documents
 *
 * @author Christophe Lauret
 * @version 13 February 2013
 */
public final class ImportTask extends Task {

  /**
   * The Word document to import.
   */
  private File source;

  /**
   * Where to create the PageSeeder documents (a directory).
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
   * List of parameters specified for the transformation into PSML
   */
  private List<Parameter> params = new ArrayList<Parameter>();

  /**
   * The name of the media folder
   */
  private String mediaFolder;

  // Set properties
  // ----------------------------------------------------------------------------------------------

  /**
   * Set the source file (a DOCX file).
   *
   * @param docx The Word document (DOCX) to import.
   */
  public void setSrc(File docx) {
    if (!(docx.exists())) throw new BuildException("the document " + docx.getName()+ " doesn't exist");
    if (docx.isDirectory()) throw new BuildException("the document " + docx.getName() + " can't be a directory");
    String name = docx.getName();
    if (!name.endsWith(".docx") && !name.endsWith(".zip")) {
      log("Word document file should generally end with .docx or .zip - but was "+name);
    }
    this.source = docx;
  }

  /**
   * Set the destination folder where the PageSeeder document(s) should be created.
   *
   * @param destination The destination folder.
   */
  public void setDest(File destination) {
    this.destination = destination;
  }

  /**
   * Set the working folder (optional).
   *
   * @param working The working folder.
   */
  public void setWorking(File working) {
    if (working.exists() && !working.isDirectory()) throw new BuildException("if working folder exists, it must be a directory");
    this.working = working;
  }

  /**
   * Set the configuration file (optional).
   *
   * @param config The configuration file.
   */
  public void setConfig(File config) {
    if (!config.exists() || config.isDirectory()) throw new BuildException("your configuration file must exist and be a file");
    this.config = config;
  }

  /**
   * @param mediaFolder the name of the media folder.
   */
  public void setMediaFolder(String name) {
    this.mediaFolder = name;
  }

  /**
   * Create a parameter object and stores it in the list To be used by the XSLT transformation
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
    if (this.source == null)
      throw new BuildException("Source document must be specified using 'src' attribute");

    // Defaulting working directory
    if (this.working == null) {
      this.working = getDefaultWorkingFolder();
    }
    if (!this.working.exists()) {
      this.working.mkdirs();
    }

    // Defaulting destination directory
    if (this.destination == null) {
      this.destination = this.source.getParentFile();
      log("Destination set to source directory "+this.destination.getAbsolutePath()+"");
    }

    // Check parameters
    for (Parameter p : this.params) {
      if (p.getName() == null)
        throw new BuildException("parameters must have a name");
      if (p.getName().startsWith("_"))
        throw new BuildException("parameter names must not start with an underscore");
    }

    // Defaulting config file
    if (this.config == null) {
      // com.pageseeder.ant.docx.xslt.import.wpml-config.xml
      this.config = null; // TODO
      log("Using default wpml configuration for import");
    }

    // The folder and name of the DOCX
    File folder = null;
    String name = null;
    if (this.destination.isFile()) {
      folder = this.destination.getParentFile();
      name = this.destination.getName();
      if (name.endsWith(".psml")) {
        name = name.substring(0, name.length()-5);
      }
    } else {
      folder = this.destination;
      name = this.source.getName();
      if (name.endsWith(".docx")) {
        name = name.substring(0, name.length()-5);
      }
    }
    
    String filename = this.source.getName();
    int pos = filename.lastIndexOf(".");
    if (pos > 0) {
    	filename = filename.substring(0, pos);
    }
    
    // Ensure that output folder exists
    if (!folder.exists()) {
      folder.mkdirs();
    }

    // 1. Unzip file
    log("Extracting DOCX: " + this.source.getName());
    File unpacked = new File(this.working, "unpacked");
    unpacked.mkdir();
    ZipUtils.unzip(this.source, unpacked);

    // 2. Sanity check
    log("Checking docx");
    File contentTypes = new File(unpacked, "[Content_Types].xml");
    File relationships = new File(unpacked, "_rels/.rels");
    if (!contentTypes.exists()) throw new BuildException("Not a valid DOCX: unable to find [Content_Types].xml");
    if (!relationships.exists()) throw new BuildException("Not a valid DOCX: unable to find _rels/.rels");

    // 3. copy the media files
    log("Copy media");
    String mediaFolderName = this.mediaFolder == null? filename+"_files" : this.mediaFolder;
    copyMedia(unpacked, folder, mediaFolderName);

    // 4. Unnest
    log("Unnest");
    Templates unnest = XSLT.getTemplatesFromResource("com/pageseeder/ant/docx/xslt/import/unnest.xsl");
    File document = new File(unpacked, "word/document.xml");
    File newDocument = new File(unpacked, "word/new-document.xml");
    Map<String, String> noParameters = Collections.emptyMap();
    XSLT.transform(document, newDocument, unnest, noParameters);
    
    //4.1 Unnest Endnotes file if it exists
    File endnotes = new File(unpacked, "word/endnotes.xml");
    if(endnotes.canRead()){
    	XSLT.transform(endnotes, new File(unpacked, "word/new-endnotes.xml"), unnest, noParameters);
    }
    //4.1 Unnest Footnotes file if it exists
    File footnotes = new File(unpacked, "word/footnotes.xml");
    if(footnotes.canRead()){
    	XSLT.transform(footnotes, new File(unpacked, "word/new-footnotes.xml"), unnest, noParameters);
    }
    
    // 5. Process the files
    log("Process with XSLT (this may take several minutes)");

    // Parse templates
    Templates templates = XSLT.getTemplatesFromResource("com/pageseeder/ant/docx/xslt/import.xsl");
    String outuri = folder.toURI().toString();

    // Initiate parameters
    Map<String, String> parameters = new HashMap<String, String>();
    parameters.put("_rootfolder", unpacked.toURI().toString());
    parameters.put("_outputfolder", outuri);
    
    parameters.put("_docxfilename", filename);
    parameters.put("_mediafoldername", mediaFolderName);
    if (this.config != null) {
      parameters.put("_configfileurl", this.config.toURI().toString());
    }

    // Add custom parameters
    for (Parameter p : this.params) {
      parameters.put(p.getName(), p.getValue());
    }

    // Transform
    XSLT.transform(contentTypes, new File(folder, filename+".psml"), templates, parameters);
  }

  // Helpers
  // ----------------------------------------------------------------------------------------------

  /**
   * @return the default working folder.
   */
  private static File getDefaultWorkingFolder() {
    String tmp = "psdocx-"+System.currentTimeMillis();
    return new File(System.getProperty("java.io.tmpdir"), tmp);
  }

  /**
   * Copy the images in DOCS to the media folder of the output for the PSML.
   *
   * @param from   The root directory of the unpacked DOCX folder
   * @param to     The root directory of the PSML output
   * @param folder The name of the folder receiving the files
   */
  private static void copyMedia(File from, File to, String folder) {
    File media = new File(from, "word/media");
    if (!media.exists()) return;
    File mediaOut = new File(to, folder);
    try  {
      Files.ensureDirectoryExists(mediaOut);
      for (File m : media.listFiles()) {
        Files.copy(m, new File(mediaOut, m.getName()));
      }
    } catch (IOException ex) {
      // TODO clean up files
      throw new BuildException(ex);
    }
  }

}
