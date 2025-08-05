/*
 * Copyright (c) 1999-2016 Allette systems pty. ltd.
 */
package org.pageseeder.docx.ox.inspector;

import java.io.File;
import java.util.List;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
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

  @BeforeEach
  public void init() {
    this.inspector = new DOCXInspector();
  }

  @Test
  public void test_object() {
    Assertions.assertNotNull(this.inspector);
    Assertions.assertEquals("docx-inspector", this.inspector.getName());
    Assertions.assertFalse(this.inspector.supportsMediaType(null));
    Assertions.assertFalse(this.inspector.supportsMediaType(""));
    Assertions.assertTrue(this.inspector.supportsMediaType("application/vnd.openxmlformats-officedocument.wordprocessingml.document"));
    Assertions.assertTrue(this.inspector.supportsMediaType("docx"));
    Assertions.assertFalse(this.inspector.supportsMediaType("application/msword"));
  }

  @Test
  public void test_inspect() {

    File file = new File("src/test/resources/models/m1/Sample.docx");
    PackageData pack = PackageData.newPackageData("test", file);
    this.inspector.inspect(pack);

    Assertions.assertTrue(pack.getProperties().size() > 0);
    Assertions.assertTrue(!pack.getProperty("dc.creator").isEmpty());
    //Assertions.assertTrue(!pack.getProperty("dc.title").isEmpty());
    Assertions.assertTrue(!pack.getProperty("xp.paragraph").isEmpty());
    Assertions.assertTrue(!pack.getProperty("xp.template").isEmpty());

  }

  @Test
  public void test_load_inspector() {
    InspectorService service = InspectorService.getInstance();
    List<PackageInspector> inspectors = service.getInspectors("application/vnd.openxmlformats-officedocument.wordprocessingml.document");
    Assertions.assertNotNull(inspectors);
    Assertions.assertTrue(inspectors.size() > 0);

    // TODO check the inspector has loaded.
    // Assertions.assertThat(PackageInspector.class, Matchers.hasItem(DOCXInspector.class));

  }

}
