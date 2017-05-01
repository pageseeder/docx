/*
 *  Copyright (c) 2014 Allette Systems pty. ltd.
 */
package org.pageseeder.docx.ox.step;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

import org.pageseeder.docx.DOCXProcessor;
import org.pageseeder.ox.OXErrors;
import org.pageseeder.ox.api.Downloadable;
import org.pageseeder.ox.api.Result;
import org.pageseeder.ox.api.Step;
import org.pageseeder.ox.api.StepInfo;
import org.pageseeder.ox.core.Model;
import org.pageseeder.ox.core.PackageData;
import org.pageseeder.ox.tool.ResultBase;
import org.pageseeder.xmlwriter.XMLWriter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * <p>A docx processing step</p>
 * <h3>Step Parameters</h3>
 * <ul>
 *  <li><var>input</var> the xml file needs to be transformed, where is a relative path of package data.
 *  (if not specified, use upper step output as input.)</li>
 *  <li><var>output</var> the output file, where is a relative path of package data (optional)</li>
 *  <li><var>config</var> the config file for processing docx.</li>
 *  <li><var>dotx</var> the doct template.<li>
 *  <li><var>media</var> the media folder, where is a relative path of packaged data.<li>
 * </ul>
 *
 * @author Ciber Cai
 * @version 05 November 2014
 */
public class PSMLToDOCX implements Step {

  /** The logger. */
  private static Logger LOGGER = LoggerFactory.getLogger(PSMLToDOCX.class);

  /**
   * Process.
   *
   * @param model the model
   * @param data the data
   * @param info the info
   * @return the result
   */
  @Override
  public Result process(Model model, PackageData data, StepInfo info) {
    if (data == null) throw new NullPointerException("data is null.");
    // input file
    String input = info.getParameter("input", info.input());

    // output file
    String output = info.getParameter("output", getName(model.name(), info.output()));

    // the config
    String config = info.getParameter("config");

    // the doc template
    String dotx = info.getParameter("dotx");

    // the media folder
    String media = info.getParameter("media");

    //Put value to input
    input = getFile(data,input,".psml");
    //Put value to input
    String temp = dotx;
    dotx = getFile(data,dotx,".dotx");
    if (dotx.equals(temp)) {
      dotx = getFile(data,dotx,".docx");
    }
    //Put value to config
    config = getFile(data,config,".xml");
        
    if (input == null) throw new NullPointerException("input haven't defined.");
    if (output == null) throw new NullPointerException("output haven't defined.");
    if (config == null) throw new NullPointerException("config haven't defined.");
    if (dotx == null) throw new NullPointerException("dotx haven't defined.");

    // the parameters
    Map<String, String> params = new HashMap<String, String>();
    params.putAll(info.parameters());
    

    //Creating media directory
    File mediaDirectory = null;
    if (media != null && !media.isEmpty()) {
      mediaDirectory = data.getFile(media);
      mediaDirectory.mkdirs();      
    }

    LOGGER.debug("input {} output {}", input, output);
    ProduceDOCXResult result = new ProduceDOCXResult(model, data, input, output, dotx, config);
    try {
      LOGGER.debug("Process the docx");
      DOCXProcessor processor = new DOCXProcessor.Builder()
          .source(data.getFile(input))
          .destination(data.getFile(output))
          .dotx(getFile(dotx, model, data))
          .config(model.getFile(config))
          .media(mediaDirectory)
          .params(params)
          .working(data.directory())
          .log(new PrintWriter(System.out))
          .build();
      processor.process();
      result.done();
    } catch (Exception ex) {
      LOGGER.warn("Cannot process the docx ", ex);
      result.setError(ex);
    }

    return result;
  }

  /**
   * Gets the name.
   *
   * @param model the name of the model
   * @param name the name
   * @return the name of output
   */
  private static String getName(String model, String name) {
    if (name.indexOf(".") > 0) {
      return name.substring(0, name.indexOf(".")) + ".docx";
    } else {
      return model + "-" + System.nanoTime() + ".docx";
    }
  }

  /**
   * Gets the file.
   *
   * @param path the path
   * @param model the model
   * @param data the data
   * @return the file
   */
  private File getFile(String path, Model model, PackageData data) {
    File file = null;
    if (path != null && !path.isEmpty()) {
      file = model.getFile(path);
      if (file == null || !file.exists()) {
        file = data.getFile(path);
      }
    }
    return file;
  }
  
  public String getFile(PackageData data, String fromFolder, String extension){
    File folder = data.getFile(fromFolder);
    if (folder.isDirectory()) {
      for (String filenane:folder.list()){
        if(filenane.endsWith(extension)) {
          fromFolder += "/" + filenane;
          break;
        }
      }
    }
    return fromFolder;
  }

  /**
   * The Class ProduceDOCXResult.
   */
  private final class ProduceDOCXResult extends ResultBase implements Result, Downloadable {
    
    /** The input. */
    private final String _input;
    
    /** The output. */
    private final String _output;
    
    /** The dotx. */
    private final String _dotx;
    
    /** The config. */
    private final String _config;

    /**
     * Instantiates a new produce DOCX result.
     *
     * @param model the model
     * @param data the data
     * @param input the input
     * @param output the output
     * @param dotx the dotx
     * @param config the config
     */
    private ProduceDOCXResult(Model model,PackageData data, String input, String output, String dotx, String config) {
      super(model, data);
      this._input = input;
      this._output = output;
      this._dotx = dotx;
      this._config = config;
    }

    /**
     * To XML.
     *
     * @param xml the xml
     * @throws IOException Signals that an I/O exception has occurred.
     */
    @Override
    public void toXML(XMLWriter xml) throws IOException {
      xml.openElement("result");
      xml.attribute("type", "package-docx");
      xml.attribute("id", data().id());
      xml.attribute("model", model().name());
      xml.attribute("status", status().toString().toLowerCase());
      xml.attribute("time", Long.toString(time()));
      xml.attribute("downloadable", String.valueOf(isDownloadable()));
      xml.attribute("path", data().getPath(downloadPath()));

      xml.openElement("source");
      xml.attribute("path", this._input);
      xml.closeElement();

      xml.openElement("destination");
      if (this._output == null) {
        xml.attribute("path", this._input.substring(this._input.lastIndexOf(".")) + ".docx");
      } else {
        xml.attribute("path", "default");
      }
      xml.closeElement();

      xml.openElement("dotx");
      xml.attribute("path", this._dotx);
      xml.closeElement();

      xml.openElement("config");
      xml.attribute("path", this._config);
      xml.closeElement();

      // Or the details of any error
      if (this.error() != null) {
        OXErrors.toXML(error(), xml, true);
      }
      xml.closeElement();
    }

    /**
     * Download path.
     *
     * @return the file
     */
    @Override
    public File downloadPath() {
      File outputFile = null;
      if (this._output == null) {
        outputFile = data().getFile(this._input.substring(this._input.lastIndexOf(".")) + ".docx");
      } else {
        outputFile = data().getFile(this._output);
      }
      return outputFile;
    }

    /**
     * Checks if is downloadable.
     *
     * @return true, if is downloadable
     */
    @Override
    public boolean isDownloadable() {
      return true;
    }
  }
}
