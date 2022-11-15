/*
 * Copyright (c) 1999-2012 weborganic systems pty. ltd.
 */
package org.pageseeder.docx.util;

import org.pageseeder.docx.DOCXException;
import org.slf4j.Logger;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.*;
import java.net.URL;
import java.util.Hashtable;
import java.util.Map;
import java.util.Map.Entry;


/**
 * A utility class for common XSLT functions.
 *
 * @author Christophe Lauret
 * @version 0.6
 */
public final class XSLT {

  /**
   * Maps XSLT templates to their URL as a string for easy retrieval.
   */
  private static final Map<String, Templates> CACHE = new Hashtable<>();

  /** Utility class. */
  private XSLT() {
  }

  /**
   * Returns the XSLT templates at the specified URL.
   *
   * <p>Templates are cached internally.
   *
   * @param url A URL to a template.
   *
   * @return the corresponding XSLT templates object or <code>null</code> if the URL was <code>null</code>.
   *
   * @throws DOCXException If XSLT templates could not be loaded from the specified URL.
   */
  public static Templates getTemplates(URL url) {
    if (url == null) return null;
    Templates templates = CACHE.get(url.toString());
    if (templates == null) {
      templates = toTemplates(url);
      CACHE.put(url.toString(), templates);
    }
    return templates;
  }

  /**
   * Return the XSLT templates from the given style.
   *
   * <p>This method will first try to load the resource using the class loader used for this class.
   *
   * <p>Use this class to load XSLT from the system.
   *
   * @param resource The path to a resource.
   *
   * @return the corresponding XSLT templates object;
   *         or <code>null</code> if the resource could not be found.
   *
   * @throws DOCXException If the loading fails.
   */
  public static Templates getTemplatesFromResource(String resource) {
    ClassLoader loader = XSLT.class.getClassLoader();
    URL url = loader.getResource(resource);
    if (url == null)
      throw new DOCXException("Unable to find templates at "+resource);
    return getTemplates(url);
  }

  /**
   * Utility function to transforms the specified XML source and returns the results as XML.
   *
   * Problems will be reported in the logs, the output will simply produce results as a comment.
   *
   * @param source     The Source XML data.
   * @param result     The Result XHTML data.
   * @param templates  The XSLT templates to use.
   * @param parameters Parameters to transmit to the transformer for use by the stylesheet (optional)
   * @param logger     The error logger (optional)
   *
   * @throws DOCXException For XSLT Transformation errors or XSLT configuration errors
   */
  public static void transform(File source, File result, Templates templates,
                               Map<String, String> parameters, Logger logger) {
    try (InputStream in = new FileInputStream(source);
         OutputStream out = new FileOutputStream(result)) {
      // Prepare the input & output
      Source src = new StreamSource(new BufferedInputStream(in), source.toURI().toString());
      Result res = new StreamResult(new BufferedOutputStream(out));

      // Transform
      transform(src, res, templates, parameters, logger);

    } catch (IOException ex) {
      throw new DOCXException(ex);
    }
  }

  /**
   * Utility function to transforms the specified XML source and returns the results as XML.
   *
   * Problems will be reported in the logs, the output will simply produce results as a comment.
   *
   * @param source     The Source XML data.
   * @param result     The Result data.
   * @param templates  The XSLT templates to use.
   * @param parameters Parameters to transmit to the transformer for use by the stylesheet (optional)
   * @param logger     The error logger (optional)
   *
   * @throws DOCXException For XSLT Transformation errors or XSLT configuration errors
   */
  public static void transform(Source source, Result result, Templates templates,
                               Map<String, String> parameters, Logger logger) {
    try {
      // Create a transformer from the templates
      Transformer transformer = templates.newTransformer();

      // Set error listener
      if (logger != null) {
        transformer.setErrorListener(new XSLTErrorListener(logger));
      }

      // Transmit the properties to the transformer
      if (parameters != null) {

        for (Entry<String, String> e : parameters.entrySet()) {
          transformer.setParameter(e.getKey(), e.getValue());
        }
      }
      // Transform
      transformer.transform(source, result);

    } catch (TransformerException ex) {
      throw new DOCXException("Unable to transform ", ex);
    }
  }

  // private helpers
  // ----------------------------------------------------------------------------------------------

  /**
   * Return the XSLT templates from the given style.
   *
   * @param stylepath The path to the XSLT style sheet
   *
   * @return the corresponding XSLT templates object
   *
   * @throws DOCXException If the loading fails.
   */
  private static Templates toTemplates(File stylepath) throws DOCXException {
    // load the templates from the source file
    Source source = new StreamSource(stylepath);
    TransformerFactory factory = TransformerFactory.newInstance();
    // TODO Ant listening
//    factory.setErrorListener(listener);
    try {
      return factory.newTemplates(source);
    } catch (TransformerConfigurationException ex) {
      throw new DOCXException("Unable to load XSLT templates", ex);
    }
  }

  /**
   * Return the XSLT templates from the given style.
   *
   * @param url A URL to a template.
   *
   * @return the corresponding XSLT templates object or <code>null</code> if the URL was <code>null</code>.
   *
   * @throws DOCXException If XSLT templates could not be loaded from the specified URL.
   */
  private static Templates toTemplates(URL url) {
    if (url == null) return null;
    // load the templates from the source URL
    Templates templates;
    try (InputStream in = url.openStream()) {
      Source source = new StreamSource(in);
      source.setSystemId(url.toString());
      TransformerFactory factory = TransformerFactory.newInstance();
      templates = factory.newTemplates(source);
    } catch (TransformerConfigurationException ex) {
      throw new DOCXException("Transformer exception while trying to load XSLT templates"+ url.toString(), ex);
    } catch (IOException ex) {
      throw new DOCXException("IO error while trying to load XSLT templates"+ url.toString(), ex);
    }
    return templates;
  }

  /**
   * An XSLT error listener .
   *
   * @author Philip Rutherford
   */
  private static class XSLTErrorListener implements ErrorListener {

    /**
     * For logging errors
     */
    private final Logger log;

    /**
     * Creates a new XSLT error listener wrapping the specified listener.
     */
    XSLTErrorListener(Logger log) {
      this.log = log;
    }

    @Override
    public void fatalError(TransformerException exception) throws TransformerException {
      this.log.error("Transformer fatal error: {}", exception.getMessageAndLocation());
    }

    @Override
    public void warning(TransformerException exception) throws TransformerException {
      this.log.warn("Transformer warning: {}", exception.getMessageAndLocation());
    }

    @Override
    public void error(TransformerException exception) throws TransformerException {
      this.log.error("Transformer error: {}", exception.getMessageAndLocation());
    }
  }

}
