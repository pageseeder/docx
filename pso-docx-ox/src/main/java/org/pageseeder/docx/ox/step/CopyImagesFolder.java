/* Copyright (c) 2016 Allette Systems pty. ltd. */
package org.pageseeder.docx.ox.step;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import org.pageseeder.ox.OXErrors;
import org.pageseeder.ox.api.Downloadable;
import org.pageseeder.ox.api.Result;
import org.pageseeder.ox.api.Step;
import org.pageseeder.ox.api.StepInfo;
import org.pageseeder.ox.core.Model;
import org.pageseeder.ox.core.PackageData;
import org.pageseeder.ox.tool.InvalidResult;
import org.pageseeder.ox.tool.ResultBase;
import org.pageseeder.ox.util.FileUtils;
import org.pageseeder.xmlwriter.XMLWriter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * <p>Specific for copy Docx media folder</p>
 * @author Adriano
 * @since  10 May 2018
 */
public class CopyImagesFolder implements Step {

  /** The logger. */
  private static Logger LOGGER = LoggerFactory.getLogger(CopyImagesFolder.class);

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

    // input file
    String source = info.getParameter("input", info.input());

    String destination = info.getParameter("output") != null
        ? info.getParameter("output")
        : (info.input().equals(info.output()) ? (info.output() + ".copy") : info.output());

    File sourceFile = data.getFile(source);

    //Adds a folder to process document
    if(!sourceFile.exists()){
      sourceFile.mkdirs();
    }

    if (sourceFile == null || !sourceFile.exists()) {
      sourceFile = model.getFile(source);
    }

    File destinationFile = data.getFile(destination);

    // if the source file (directory) doesn't exist
    if (sourceFile == null || !sourceFile.exists()) { return new InvalidResult(model, data)
        .error(new FileNotFoundException("Cannot find the input file " + source + ".")); }

    CopyResult result = new CopyResult(model, data, source, destination);
    try {
      FileUtils.copy(sourceFile, destinationFile);
    } catch (IOException ex) {
      LOGGER.error("Error while copying the files: {}", ex.getMessage());
      result.setError(ex);
    }
    return result;
  }

  /**
   * The Class CopyResult.
   */
  private static class CopyResult extends ResultBase implements Result, Downloadable {

    /** The input. */
    private final String _input;

    /** The output. */
    private final String _output;

    /**
     * Instantiates a new copy result.
     *
     * @param model the model
     * @param data the data
     * @param input the input
     * @param output the output
     */
    private CopyResult(Model model, PackageData data, String input, String output) {
      super(model, data);
      this._input = input;
      this._output = output;
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
      xml.attribute("name", "Copy");
      xml.attribute("id", data().id());
      xml.attribute("model", model().name());
      xml.attribute("status", status().toString().toLowerCase());
      xml.attribute("time", Long.toString(time()));
      xml.attribute("downloadable", String.valueOf(isDownloadable()));
      xml.attribute("path", data().getPath(downloadPath()));

      if (this._input != null) {
        xml.attribute("input", this._input);
      }
      if (this._output != null) {
        xml.attribute("output", this._output);
      }

      // Print the details of any error
      if (error() != null) {
        OXErrors.toXML(error(), xml, true);
      }
      xml.closeElement();// result
    }

    /**
     * Download path.
     *
     * @return the file
     */
    @Override
    public File downloadPath() {
      File outputFile = data().getFile(this._output);
      return outputFile;
    }

    /**
     * Checks if is downloadable.
     *
     * @return true, if is downloadable
     */
    /* (non-Javadoc)
     * @see org.pageseeder.ox.tool.ResultBase#isDownloadable()
     */
    @Override
    public boolean isDownloadable() {
      return true;
    }
  }

}
