package org.pageseeder.docx.ant;

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.net.URISyntaxException;
import java.net.URL;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Source;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;

import org.hamcrest.BaseMatcher;
import org.hamcrest.Description;
import org.hamcrest.Matcher;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xmlunit.builder.Input;
import org.xmlunit.matchers.EvaluateXPathMatcher;
import org.xmlunit.matchers.HasXPathMatcher;
import org.xmlunit.validation.Languages;
import org.xmlunit.validation.ValidationProblem;
import org.xmlunit.validation.ValidationResult;
import org.xmlunit.validation.Validator;
import org.xmlunit.xpath.JAXPXPathEngine;

/**
 * Utility class providing static methods for common XML operations.
 */
public final class XML {

  /**
   * Generate the DOM Source instance from the response content.
   *
   * @param xml The response from PageSeeder
   *
   * @return The corresponding DOM source
   */
  public static DOMSource toDOMSource(String xml) {
    return toDOMSource(new StringReader(xml));
  }

  /**
   * Generate the DOM Source instance from the response content.
   *
   * @param xml The response from PageSeeder
   *
   * @return The corresponding DOM source
   */
  public static Node toNode(String xml) {
    return toNode(new StringReader(xml));
  }

  /**
   * Generate the DOM Source instance from the specified reader
   *
   * @param reader The reader to parse as DOM
   *
   * @return The corresponding DOM source
   */
  public static DOMSource toDOMSource(Reader reader) {
    return new DOMSource(toNode(reader));
  }

  /**
   * Generate the DOM Source instance from the specified reader
   *
   * @param reader The reader to parse as DOM
   *
   * @return The corresponding DOM source
   */
  public static Node toNode(Reader reader) {
    try {
      DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
      DocumentBuilder builder = factory.newDocumentBuilder();
      return builder.parse(new InputSource(reader));
    } catch (ParserConfigurationException | SAXException | IOException ex) {
      throw new IllegalStateException("Unable to generate DOM Source", ex);
    }
  }

  public static Source getSchema(String spec) {
    try {
      String pathToSchema = "/org/pageseeder/docx/schema/"+spec.replace(':', '/');
      URL url = XML.class.getResource(pathToSchema);
      StreamSource schema = new StreamSource(url.openStream());
      schema.setSystemId(url.toURI().toString());
      return schema;
    } catch (URISyntaxException | IOException ex) {
      throw new IllegalStateException("Unable to open schema source", ex);
    }
  }


  public static Validator getValidator(String spec) {
    Source schema = getSchema(spec);
    Validator v = Validator.forLanguage(Languages.W3C_XML_SCHEMA_NS_URI);
    v.setSchemaSource(schema);
    return v;
  }


  public static Validates validates(String spec){
    Source schema = getSchema(spec);
    return new Validates(schema);
  }

  public static Validates validates(Source schema){
    return new Validates(schema);
  }


  public static HasXPathMatcher hasXPath(String xPath) {
    return new HasXPathMatcher(xPath);
  }

  public static EvaluateXPathMatcher hasXPath(String xPath, Matcher<String> valueMatcher) {
    return new EvaluateXPathMatcher(xPath, valueMatcher);
  }

  public static String evaluateXPath(String xml, String xpath) {
    Source s = Input.fromString(xml).build();
    return new JAXPXPathEngine().evaluate(xpath, s);
  }





  // Matches for assertThat
  // --------------------------------------------------------------------------

  public static class Validates extends BaseMatcher<Object> {
    private final Source _schema;

    private Iterable<ValidationProblem> problems;

    public Validates(Source schema) {
      this._schema = schema;
    }

    @Override
    public boolean matches(Object object) {
      Validator v = Validator.forLanguage(Languages.W3C_XML_SCHEMA_NS_URI);
      v.setSchemaSource(this._schema);
      Source s = Input.from(object).build();
      ValidationResult result = v.validateInstance(s);
      this.problems = result.getProblems();
      return result.isValid();
    }

    @Override
    public void describeTo(Description description){
      description.appendText("validates schema=").appendText(this._schema.getSystemId());
    }

    @Override
    public void describeMismatch(Object item, Description description) {
      description.appendText("found the following validation problems:\n");
      for (ValidationProblem p : this.problems) {
        description.appendText(p.getType().toString());
        if (p.getLine() != -1) {
          description.appendText(":").appendText(Integer.toString(p.getLine()));
          if (p.getColumn() != -1) {
            description.appendText(":").appendText(Integer.toString(p.getColumn()));
          }
        }
        description.appendText(":").appendText(p.getMessage());
      }
    }

  }

}
