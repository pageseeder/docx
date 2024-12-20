/*
 * Copyright (c) 1999-2016 Allette systems pty. ltd.
 */
package org.pageseeder.docx.ox.inspector.step;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.pageseeder.docx.ox.step.PSMLToDOCX;
import org.pageseeder.ox.OXConfig;
import org.pageseeder.ox.api.Result;
import org.pageseeder.ox.core.Model;
import org.pageseeder.ox.core.PackageData;
import org.pageseeder.ox.core.StepInfoImpl;

/**
 * @author Ciber Cai
 * @since 20 Jun 2016
 */
public class TestPSMLToDOCX {
  private final File file = new File("src/test/resources/models/m1/Sample.psml");

  @Before
  public void init() {
    File modelDir = new File("src/test/resources/models");
    OXConfig config = OXConfig.get();
    config.setModelsDirectory(modelDir);
  }

  @Test(expected = NullPointerException.class)
  public void testEmpty() {
    String output = "output/empty";
    String modelName = "psml-to-docx";
    PackageData data = PackageData.newPackageData(modelName, this.file);

    process(data, null, output, modelName, "to-psml", null);
  }

  @Test
  public void testProcess() {
    String output = "test.docx";
    String modelName = "m1";
    PackageData data = PackageData.newPackageData(modelName, this.file);
    Map <String, String> parameters = new HashMap<String, String>();
    parameters.put("config", "word-export-config.xml");
    parameters.put("dotx", "template.docx");
    Result result = process(data, null, output, modelName, "to-psml", parameters);


    Assert.assertNotNull(result);
    Assert.assertEquals("OK", result.status().name());



    File psml = data.getFile(output);
    Assert.assertTrue(psml.exists());
    Assert.assertTrue(psml.length() > 1);
  }

  protected Result process (String modelName, String stepName){
    return process(null, null, null, modelName, stepName, null);
  }

  protected Result process (PackageData data, String input, String output, String modelName, String stepName,
      Map<String, String> parameters){
    PSMLToDOCX step = new PSMLToDOCX();

    Model model = new Model(modelName);
    if (data == null) {
      data = PackageData.newPackageData(modelName, this.file);
    }
    if (input == null) {
      input = data.getPath(data.getOriginal());
    }

    // use input as output if output is null
    if (output == null) {
      output = input;
    }

    if (parameters == null) {
      parameters = new HashMap<String, String>();
    }

    // step info
    StepInfoImpl info = new StepInfoImpl(data.id(), stepName, input, output, parameters);
    // process the step
    return step.process(model, data, info);
  }
}
