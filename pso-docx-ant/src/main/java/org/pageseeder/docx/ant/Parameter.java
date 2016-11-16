/*
 * Copyright (c) 1999-2012 weborganic systems pty. ltd.
 */
package org.pageseeder.docx.ant;


/**
 * Used to store a Parameter value.
 *
 * <p>The parameter value is specified for this task in form of the following nested element:
 * <pre>{@code
 *   <param name="cell" value="D2"/>
 *   <param name="title" value="My Document"/>
 * }</pre>
 *
 * @author Jean-Baptiste Reure
 * @author Christophe Lauret
 */
public final class Parameter {

  /**
   * The name of the parameter.
   */
  private String name = null;

  /**
   * The value of the parameter.
   */
  private String value = null;

  public Parameter() {
    // do nothing
  }

  /**
   * Sets the name of the parameter.
   *
   * @param name The name of the parameter
   */
  public void setName(String name) {
    this.name = name;
  }

  /**
   * Sets the value of the parameter.
   *
   * @param value The value of the parameter
   */
  public void setValue(String value) {
    this.value = value;
  }

  /**
   * get the name of the parameter.
   *
   * @return the name of the parameter
   */
  public String getName() {
    return this.name;
  }

  /**
   * get the value of the parameter.
   *
   * @return the value of the parameter
   */
  public String getValue() {
    return this.value;
  }
}
