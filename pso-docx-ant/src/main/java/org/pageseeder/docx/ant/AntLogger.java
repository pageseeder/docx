/*
 * Copyright (c) 1999-2012 weborganic systems pty. ltd.
 */
package org.pageseeder.docx.ant;

import org.apache.tools.ant.BuildEvent;
import org.apache.tools.ant.BuildListener;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.slf4j.Logger;
import org.slf4j.Marker;

/**
 * A Logger implementation for ANT.
 *
 * <p>Delegates the actual logging to the {@link BuildListener}s configured on the ant {@link Project}.
 *
 * @see #setProject(Project)
 *
 * @author Christophe Lauret
 */
public class AntLogger implements Logger {

  private final static Object[] EMPTY_ARGS = new Object[] {};
  /**
   * The default project when run directly from ANT.
   */
  private static Project defaultproject;

  /**
   * Name of this logger.
   */
  private final String _name;

  /**
   * Underlying ANT project.
   */
  private final Project _project;

  /**
   * @param name The name of this
   */
  public AntLogger(String name) {
    this._name = name;
    this._project = defaultproject;
  }

  /**
   * @param name    The name of the task
   * @param project The project the ANT task is part of.
   */
  private AntLogger(String name, Project project) {
    this._name = name;
    this._project = project;
  }

  /**
   * Set up the project here before executing code your ant {@link Task}s.
   *
   * @param project The ant {@link Project} containing the {@link BuildListener}s the {@link Logger}s should delegate to
   */
  public static void setProject(Project project) {
    AntLogger.defaultproject = project;
  }

  /**
   * Create a new instance of a logger for an ANT task.
   *
   * <p>Simply use this factory methods to pass to other objects in the API.
   *
   * @param task The ANT to run.
   */
  public static Logger newInstance(Task task) {
    return new AntLogger(task.getTaskName(), task.getProject());
  }

  // SLF4J Logger methods
  // ---------------------------------------------------------------------------------------------


  public String getName() {
    return this._name;
  }

  @Override
  public boolean isDebugEnabled() {
    return true;
  }

  @Override
  public boolean isDebugEnabled(Marker marker) {
    return true;
  }

  @Override
  public void debug(String msg) {
    log(msg, Project.MSG_DEBUG, null);
  }

  @Override
  public void debug(String format, Object arg) {
    log(format, Project.MSG_DEBUG, null, arg);
  }

  @Override
  public void debug(String format, Object... argArray) {
    log(format, Project.MSG_DEBUG, null, argArray);
  }

  @Override
  public void debug(String msg, Throwable t) {
    log(msg, Project.MSG_DEBUG, t);
  }

  @Override
  public void debug(Marker marker, String format, Object arg) {
    log(format, Project.MSG_DEBUG, null, arg);
  }

  @Override
  public void debug(Marker marker, String format, Object arg1, Object arg2) {
    log(format, Project.MSG_DEBUG, null, arg1, arg2);
  }

  @Override
  public void debug(Marker marker, String format, Object... arguments) {
    log(format, Project.MSG_DEBUG, null, arguments);
  }

  @Override
  public void debug(Marker marker, String msg) {
    log(msg, Project.MSG_DEBUG, null, EMPTY_ARGS);
  }

  @Override
  public void debug(Marker marker, String msg, Throwable t) {
    log(msg, Project.MSG_DEBUG, t, EMPTY_ARGS);
  }

  @Override
  public void debug(String format, Object arg1, Object arg2) {
    log(format, Project.MSG_DEBUG, null, arg1, arg2);
  }

  @Override
  public boolean isInfoEnabled() {
    return true;
  }

  @Override
  public boolean isInfoEnabled(Marker marker) {
    return true;
  }

  @Override
  public void info(String msg) {
    log(msg, Project.MSG_INFO, null);
  }

  @Override
  public void info(String format, Object arg) {
    log(format, Project.MSG_INFO, null, arg);
  }

  @Override
  public void info(String format, Object... argArray) {
    log(format, Project.MSG_INFO, null, argArray);
  }

  @Override
  public void info(Marker marker, String format, Object arg) {
    log(format, Project.MSG_INFO, null, arg);
  }

  @Override
  public void info(String msg, Throwable t) {
    log(msg, Project.MSG_INFO, t);
  }

  @Override
  public void info(Marker marker, String format, Object arg1, Object arg2) {
    log(format, Project.MSG_INFO, null, arg1, arg2);
  }

  @Override
  public void info(Marker marker, String format, Object... arguments) {
    log(format, Project.MSG_INFO, null, arguments);
  }

  @Override
  public void info(Marker marker, String msg) {
    log(msg, Project.MSG_INFO, null, EMPTY_ARGS);
  }

  @Override
  public void info(Marker marker, String msg, Throwable t) {
    log(msg, Project.MSG_INFO, t, EMPTY_ARGS);
  }

  @Override
  public void info(String format, Object arg1, Object arg2) {
    log(format, Project.MSG_INFO, null, arg1, arg2);
  }

  @Override
  public boolean isWarnEnabled() {
    return true;
  }

  @Override
  public boolean isWarnEnabled(Marker marker) {
    return true;
  }

  @Override
  public void warn(String msg) {
    log(msg, Project.MSG_WARN, null);
  }

  @Override
  public void warn(String format, Object arg) {
    log(format, Project.MSG_WARN, null, arg);
  }

  @Override
  public void warn(String format, Object... argArray) {
    log(format, Project.MSG_WARN, null, argArray);
  }

  @Override
  public void warn(String msg, Throwable t) {
    log(msg, Project.MSG_WARN, t);
  }

  @Override
  public void warn(Marker marker, String format, Object arg) {
    log(format, Project.MSG_WARN, null, arg);
  }

  @Override
  public void warn(Marker marker, String format, Object arg1, Object arg2) {
    log(format, Project.MSG_WARN, null, arg1, arg2);
  }

  @Override
  public void warn(Marker marker, String format, Object... arguments) {
    log(format, Project.MSG_WARN, null, arguments);
  }

  @Override
  public void warn(Marker marker, String msg) {
    log(msg, Project.MSG_WARN, null, EMPTY_ARGS);
  }

  @Override
  public void warn(Marker marker, String msg, Throwable t) {
    log(msg, Project.MSG_WARN, t, EMPTY_ARGS);
  }

  @Override
  public void warn(String format, Object arg1, Object arg2) {
    log(format, Project.MSG_WARN, null, arg1, arg2);
  }

  @Override
  public boolean isErrorEnabled() {
    return true;
  }

  @Override
  public boolean isErrorEnabled(Marker marker) {
    return true;
  }

  @Override
  public void error(String msg) {
    log(msg, Project.MSG_ERR, null);
  }

  @Override
  public void error(String format, Object arg) {
    log(format, Project.MSG_ERR, null, arg);
  }

  @Override
  public void error(String format, Object... argArray) {
    log(format, Project.MSG_ERR, null, argArray);
  }

  @Override
  public void error(String msg, Throwable t) {
    log(msg, Project.MSG_ERR, t);
  }

  @Override
  public void error(Marker marker, String format, Object arg) {
    log(format, Project.MSG_ERR, null, arg);
  }

  @Override
  public void error(Marker marker, String format, Object arg1, Object arg2) {
    log(format, Project.MSG_ERR, null, arg1, arg2);
  }

  @Override
  public void error(Marker marker, String format, Object... arguments) {
    log(format, Project.MSG_ERR, null, arguments);
  }

  @Override
  public void error(Marker marker, String msg) {
    log(msg, Project.MSG_ERR, null, EMPTY_ARGS);
  }

  @Override
  public void error(Marker marker, String msg, Throwable t) {
    log(msg, Project.MSG_ERR, t, EMPTY_ARGS);
  }

  @Override
  public void error(String format, Object arg1, Object arg2) {
    log(format, Project.MSG_ERR, null, arg1, arg2);
  }

  @Override
  public boolean isTraceEnabled() {
    return true;
  }

  @Override
  public boolean isTraceEnabled(Marker marker) {
    return true;
  }

  @Override
  public void trace(String msg) {
    log(msg, Project.MSG_VERBOSE, null);
  }

  @Override
  public void trace(String format, Object arg) {
    log(format, Project.MSG_VERBOSE, null, arg);
  }

  @Override
  public void trace(String format, Object... argArray) {
    log(format, Project.MSG_VERBOSE, null, argArray);
  }

  @Override
  public void trace(String msg, Throwable t) {
    log(msg, Project.MSG_VERBOSE, t);
  }

  @Override
  public void trace(Marker marker, String format, Object arg) {
    log(format, Project.MSG_VERBOSE, null, arg);
  }

  @Override
  public void trace(Marker marker, String format, Object arg1, Object arg2) {
    log(format, Project.MSG_VERBOSE, null, arg1, arg2);
  }

  @Override
  public void trace(Marker marker, String format, Object... arguments) {
    log(format, Project.MSG_VERBOSE, null, arguments);
  }

  @Override
  public void trace(Marker marker, String msg) {
    log(msg, Project.MSG_VERBOSE, null, EMPTY_ARGS);
  }

  @Override
  public void trace(Marker marker, String msg, Throwable t) {
    log(msg, Project.MSG_VERBOSE, t, EMPTY_ARGS);
  }

  @Override
  public void trace(String format, Object arg1, Object arg2) {
    log(format, Project.MSG_VERBOSE, null, arg1, arg2);
  }


  // private helpers
  // ---------------------------------------------------------------------------------------------

  /**
   * Actually logs the message using the appropriate priority and all possible arguments.
   *
   * @param message   The message (unformatted)
   * @param priority  The ANT priority level
   * @param exception The exception
   * @param args      Additional arguments useful for the message.
   */
  private void log(String message, int priority, Throwable exception, Object... args) {
    if (this._project == null) { return; }
    BuildEvent buildEvent = new SLF4JBuildEvent(this._project, message, priority, exception, args);
    for (Object buildListener : this._project.getBuildListeners()) {
      ((BuildListener) buildListener).messageLogged(buildEvent);
    }
  }

  /**
   * An adaptor for an ANT build event.
   *
   * @author Christophe Lauret
   * @version 10 October 2012
   */
  private static class SLF4JBuildEvent extends BuildEvent {

    /** As per requirements for Serializable */
    private static final long serialVersionUID = -5900281352326256031L;

    /** ANT priority level */
    private final int priority;

    /** Unformatted message */
    private final String format;

    /** Additional arguments */
    private final Object[] args;

    /** Formatted message */
    private String message;

    /**
     * Create a new build event.
     *
     * @param project   The ANT project
     * @param format    The unformatted message
     * @param priority  The ANT priority level
     * @param exception The exception
     * @param args      Additional arguments for message.
     */
    public SLF4JBuildEvent(Project project, String format, int priority, Throwable exception, Object[] args) {
      super(project);
      if (exception != null) {
        setException(exception);
      }
      this.priority = priority;
      this.format = format;
      this.args = args;
    }


    @Override
    public String getMessage() {
      if (this.message == null) {
        this.message = format(this.format, this.args);
      }
      return this.message;
    }


    @Override
    public int getPriority() {
      return this.priority;
    }
  }

  /**
   * Formats the message with an array of objects.
   *
   * @param format The message format.
   * @param oArray The array of objects that may be used in the message.
   *
   * @return The formatted message.
   */
  private static String format(String format, Object... oArray) {
    StringBuilder message = new StringBuilder();
    int from = 0;
    int to = -1;
    // Iterate over the object to know how they should be inserted
    for (Object o : oArray) {
      to = format.indexOf("{}", from);
      if (to >= 0) {
        message.append(format.substring(from, to));
        message.append(o);
        from = to + 2;
      } else {
        break;
      }
    }
    // Appends whatever remains.
    message.append(format.substring(from));
    return message.toString();
  }

}
