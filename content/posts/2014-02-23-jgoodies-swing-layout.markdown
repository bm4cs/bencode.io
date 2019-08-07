---
layout: post
title: "Neat and tidy Swing with JGoodies FormLayout"
date: "2014-02-24 20:30:05"
comments: false
categories:
- dev
tags:
- java
---

When its comes to laying out slightly complex forms in AWT or Swing, using the [baked-in layout managers](http://docs.oracle.com/javase/tutorial/uiswing/layout/visual.html#grid) (BoxLayout, FlowLayout, GridLayout) can feel frustrating.

Thankfully I stumbled across the [JGoodies FormLayout](http://www.jgoodies.com/freeware/libraries/forms/) layout manager whilst working on some Swing applications using IntelliJ IDEA 13. IDEA has an integrated visual GUI builder, that makes it really quick and easy to mock up FormLayout controlled layouts, but for the most precise level of control I found handcrafting to be very clean and simple.

The JGoodies library is covered under a BSD License, permitting binary redistibution. In essence grid specifications are passed into the FormLayout constructor, by first defining the columns, followed by the rows. The component sizes min, pref, default are used to set column and row sizes that reflect the minimum or preferred sizes of the contained components. If you specify a column size as min sized, FormLayout will ask all components in that column for their minimum width and chooses the largest width as the column width.

The idea is work backward from a mockup, like so:

![Form layout mockup](/images/jgoodies_mockup.jpg)

Source: http://manual.openestate.org/extern/forms-1.2.1/images/quickstart-grid-specs.jpg


Here's a sample snippet, that defines a 13 by 7 grid.

    // 1. Create the layout
    FormLayout layout = new FormLayout(
      "right:pref, 3dlu, pref:grow, 7dlu, right:pref, 3dlu, pref:grow", // 7 columns
      "p, 3dlu, p, 3dlu, p, 9dlu, p, 3dlu, p, 3dlu, p, 9dlu, p"); // 13 rows

Using some simple naming conventions, such as `pref` or shorthand version `p` for preferred width/height, or `3dlu` meaning 3 dialog units (concept borrowed from Microsoft interface specification many moons ago), or if needed you can decorate terms with justifications (e.g. `right`, `left`, `middle`, etc), and growable column widths with `grow`.

The default size aims to give a column the width of the largest preferred width. If container space is scarce, it shrinks the column down to the largest minimum width.

    // 1. Create the layout
    FormLayout layout = new FormLayout(
      "right:pref, 3dlu, pref:grow, 7dlu, right:pref, 3dlu, pref:grow", // 7 columns
      "p, 3dlu, p, 3dlu, p, 9dlu, p, 3dlu, p, 3dlu, p, 9dlu, p"); // 13 rows

    // 2. Specify column and row groups
    layout.setColumnGroups(new int[][] { {1, 5}, {3, 7} });

    // 3. Create and configure builder
    PanelBuilder builder = new PanelBuilder(layout);
    builder.setDefaultDialogBorder();

    // 4. Add components
    CellConstraints cc = new CellConstraints();
    builder.addSeparator("General", cc.xyw(1,  1, 7));
    builder.addLabel("Company", cc.xy(1, 3));
    builder.add(new JTextField(), cc.xyw(3, 3, 5));
    builder.addLabel("Contact", cc.xy(1, 5));
    builder.add(new JTextField(), cc.xyw(3, 5, 5));
    builder.addSeparator("Propeller", cc.xyw(1, 7, 7));
    builder.addLabel("PTI [kW]", cc.xy(1, 9));
    builder.add(new JTextField(), cc.xy(3, 9));
    builder.addLabel("Power [kW]", cc.xy(5, 9));
    builder.add(new JTextField(), cc.xy(7, 9));
    builder.addLabel("R [mm]", cc.xy(1, 11));
    builder.add(new JTextField(), cc.xy(3, 11));
    builder.addLabel("D [mm]", cc.xy(5, 11));
    builder.add(new JTextField(), cc.xy(7, 11));
    builder.add(ButtonBarFactory.buildCenteredBar(new JButton("Ignite"), new JButton("Explode")), cc.xyw(1, 13, builder.getColumnCount()));

    JPanel goodiesPanel = builder.getPanel();
    goodiesPanel.setPreferredSize(new Dimension(400, 250));
    goodiesForm.getContentPane().add(goodiesPanel);

On such a high from the FormLayout, I took the opportunitity to explore the [JGoodies Looks](http://www.jgoodies.com/freeware/libraries/looks/) library, which provides a more cross platform consistent look & feel, and utilities for doing so. One JAR include and a single line of code later, pow:

    UIManager.setLookAndFeel(new Plastic3DLookAndFeel());

Here's some renders on an Windows XP machine (I still have to use XP sometimes...fml), and my Debian GNU/Linux machine.

![FormLayout and Plastic3D on Windows XP](/images/jgoodies_win.png)

![FormLayout and Plastic3D on GTK](/images/jgoodies_gnu.png)


For my own future reference, buildable IDEA project including JGoodies dependencies is here [https://github.com/benjaminify/GoodiesFormDemo](https://github.com/benjaminify/GoodiesFormDemo) 
