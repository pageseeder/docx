/*
 * Copyright (c) 1999-2016 Allette systems pty. ltd.
 */
package org.pageseeder.docx.ox.inspector;

import java.io.File;
import java.util.List;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.pageseeder.docx.ox.inspector.DOCXInspector;
import org.pageseeder.ox.api.PackageInspector;
import org.pageseeder.ox.core.InspectorService;
import org.pageseeder.ox.core.PackageData;

/**
 * @author Ciber Cai
 * @since 20 Jun 2016
 */
public class TestDOCXInspector {

  private DOCXInspector inspector = null;

  @Before
  public void init() {
    this.inspector = new DOCXInspector();
  }

  @Test
  public void test_object() {
    Assert.assertNotNull(this.inspector);
    Assert.assertEquals("docx-inspector", this.inspector.getName());
    Assert.assertFalse(this.inspector.supportsMediaType(null));
    Assert.assertFalse(this.inspector.supportsMediaType(""));
    Assert.assertTrue(this.inspector.supportsMediaType("application/vnd.openxmlformats-officedocument.wordprocessingml.document"));
    Assert.assertFalse(this.inspector.supportsMediaType("application/msword"));
  }

  @Test
  public void test_inspect() {

    File file = new File("src/test/resources/models/m1/Sample.docx");
    PackageData pack = PackageData.newPackageData("test", file);
    this.inspector.inspect(pack);

    Assert.assertTrue(pack.getProperties().size() > 0);
    Assert.assertTrue(!pack.getProperty("dc.creator").isEmpty());
    //Assert.assertTrue(!pack.getProperty("dc.title").isEmpty());
    Assert.assertTrue(!pack.getProperty("xp.paragraph").isEmpty());
    Assert.assertTrue(!pack.getProperty("xp.template").isEmpty());

  }

  @Test
  public void test_load_inspector() {
    InspectorService service = InspectorService.getInstance();
    List<PackageInspector> inspectors = service.getInspectors("application/vnd.openxmlformats-officedocument.wordprocessingml.document");
    Assert.assertNotNull(inspectors);
    Assert.assertTrue(inspectors.size() > 0);

    // TODO check the inspector has loaded.
    // Assert.assertThat(PackageInspector.class, Matchers.hasItem(DOCXInspector.class));

  }

}
