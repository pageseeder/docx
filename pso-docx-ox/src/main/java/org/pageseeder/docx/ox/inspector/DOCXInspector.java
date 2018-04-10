package org.pageseeder.docx.ox.inspector;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.pageseeder.ox.api.PackageInspector;
import org.pageseeder.ox.core.PackageData;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * A inspector for docx.
 *
 * @author Christophe Lauret
 * @author Ciber Cai
 * @version 13 November 2013
 */
public class DOCXInspector implements PackageInspector {

  /**  the logger. */
  private final static Logger LOGGER = LoggerFactory.getLogger(DOCXInspector.class);

  /**
   * Gets the name.
   *
   * @return the name
   */
  @Override
  public String getName() {
    return "docx-inspector";
  }

  /**
   * Supports media type.
   *
   * @param mediatype the mediatype
   * @return true, if successful
   */
  @Override
  public boolean supportsMediaType(String mediatype) {
    /* 
     * In linux environment is quite impossible to get the media type, then most of the times on this environment the ox
     * core will send the extension. 
     */
    return "application/vnd.openxmlformats-officedocument.wordprocessingml.document".equals(mediatype) || "docx".equalsIgnoreCase(mediatype);
  }

  /**
   * Inspect.
   *
   * @param pack the pack
   */
  @Override
  public void inspect(PackageData pack) {

    File docx = pack.findByExtension(".docx");
    if (docx != null && docx.exists() && docx.length() > 0) {
      try {
        // Make sure we unpack the DOCX
        pack.unpack();
        parse(pack, "unpacked/docProps/core.xml");
        parse(pack, "unpacked/docProps/app.xml");
      } catch (IOException ex) {
        LOGGER.warn("Cannot inspect docx. {}", ex);
      }
    }
  }

  /**
   * Parses the.
   *
   * @param pack the pack
   * @param path the path
   */
  private static final void parse(PackageData pack, String path) {
    File file = pack.getFile(path);
    if (!file.exists()) { return; }
    try {
      // Get the SAX Parser
      SAXParserFactory factory = SAXParserFactory.newInstance();
      factory.setNamespaceAware(true);
      factory.setValidating(false);
      SAXParser parser = factory.newSAXParser();

      // Set stream
      InputStream input = new FileInputStream(file);
      InputSource is = new InputSource(input);
      is.setEncoding("UTF-8");

      // Parse
      parser.parse(is, new DocPropsHandler(pack));
    } catch (Exception ex) {
      LOGGER.error("Cannot prase file {}", file, ex);
    }
  }

  /**
   * The Class DocPropsHandler.
   */
  private static class DocPropsHandler extends DefaultHandler {

    /** The Constant NS_CP. */
    private final static String NS_CP = "http://schemas.openxmlformats.org/package/2006/metadata/core-properties";

    /** The Constant NS_DC. */
    private final static String NS_DC = "http://purl.org/dc/elements/1.1/";

    /** The Constant NS_DCTERMS. */
    private final static String NS_DCTERMS = "http://purl.org/dc/terms/";

    /** The Constant NS_XP. */
    private final static String NS_XP = "http://schemas.openxmlformats.org/officeDocument/2006/extended-properties";

    /** The Constant ELEMENTS. */
    private static final List<CapturedElement> ELEMENTS = new ArrayList<CapturedElement>();

    static {
      // In core.xml
      ELEMENTS.add(new CapturedElement(NS_DC, "title", "dc.title"));
      ELEMENTS.add(new CapturedElement(NS_DC, "subject", "dc.subject"));
      ELEMENTS.add(new CapturedElement(NS_DC, "creator", "dc.creator"));
      ELEMENTS.add(new CapturedElement(NS_CP, "keywords", "cp.keywords"));
      ELEMENTS.add(new CapturedElement(NS_CP, "lastModifiedBy", "cp.lastModifiedBy"));
      ELEMENTS.add(new CapturedElement(NS_CP, "revision", "cp.revision"));
      ELEMENTS.add(new CapturedElement(NS_DCTERMS, "created", "dcterms.created"));
      ELEMENTS.add(new CapturedElement(NS_DCTERMS, "modified", "dcterms.modified"));
      // In app.xml
      ELEMENTS.add(new CapturedElement(NS_XP, "Template", "xp.template"));
      ELEMENTS.add(new CapturedElement(NS_XP, "TotalTime", "xp.totaltime"));
      ELEMENTS.add(new CapturedElement(NS_XP, "Pages", "xp.pages"));
      ELEMENTS.add(new CapturedElement(NS_XP, "Words", "xp.words"));
      ELEMENTS.add(new CapturedElement(NS_XP, "Characters", "xp.characters"));
      ELEMENTS.add(new CapturedElement(NS_XP, "Application", "xp.application"));
      ELEMENTS.add(new CapturedElement(NS_XP, "Lines", "xp.lines"));
      ELEMENTS.add(new CapturedElement(NS_XP, "Paragraphs", "xp.paragraph"));
      ELEMENTS.add(new CapturedElement(NS_XP, "Company", "xp.company"));
      ELEMENTS.add(new CapturedElement(NS_XP, "SharedDoc", "xp.shareddoc"));
      ELEMENTS.add(new CapturedElement(NS_XP, "Application", "xp.application"));
      ELEMENTS.add(new CapturedElement(NS_XP, "AppVersion", "xp.appversion"));
    }

    /** The pack. */
    private final PackageData _pack;

    /** The current. */
    private CapturedElement current = null;

    /** The buffer. */
    private final StringBuffer buffer = new StringBuffer();

    /**
     * Instantiates a new doc props handler.
     *
     * @param pack the pack
     */
    public DocPropsHandler(PackageData pack) {
      this._pack = pack;
    }

    /* (non-Javadoc)
     * @see org.xml.sax.helpers.DefaultHandler#startElement(java.lang.String, java.lang.String, java.lang.String, org.xml.sax.Attributes)
     */
    @Override
    public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
      if (this.current == null) {
        for (CapturedElement element : ELEMENTS) {
          if (element.match(uri, localName)) {
            this.current = element;
          }
        }
      }
    }

    /* (non-Javadoc)
     * @see org.xml.sax.helpers.DefaultHandler#endElement(java.lang.String, java.lang.String, java.lang.String)
     */
    @Override
    public void endElement(String uri, String localName, String qName) throws SAXException {
      if (this.current != null) {
        String property = this.current.property();
        String value = this.buffer.toString();
        this._pack.setProperty(property, value);
        // reset
        this.buffer.setLength(0);
        this.current = null;
      }
    }

    /* (non-Javadoc)
     * @see org.xml.sax.helpers.DefaultHandler#characters(char[], int, int)
     */
    @Override
    public void characters(char[] ch, int start, int length) throws SAXException {
      if (this.current != null) {
        this.buffer.append(ch, start, length);
      }
    }

  }

  /**
   * The Class CapturedElement.
   */
  private static final class CapturedElement {

    /** The uri. */
    private final String uri;
    
    /** The name. */
    private final String name;
    
    /** The property. */
    private final String property;

    /**
     * Instantiates a new captured element.
     *
     * @param uri the uri
     * @param name the name
     * @param property the property
     */
    public CapturedElement(String uri, String name, String property) {
      this.uri = uri;
      this.name = name;
      this.property = property;
    }

    /**
     * Match.
     *
     * @param uri the uri
     * @param name the name
     * @return true, if successful
     */
    public boolean match(String uri, String name) {
      return this.uri.equals(uri) && this.name.equals(name);
    }

    /**
     * Property.
     *
     * @return the string
     */
    public String property() {
      return this.property;
    }

  }

}
