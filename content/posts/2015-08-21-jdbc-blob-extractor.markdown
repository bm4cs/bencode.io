---
layout: post
title: "JDBC blob extractor"
date: "2015-08-21 21:59:33"
comments: false
categories: [Java]
---

I was dealing with an application that stores image binary data in DB2. DB2 tooling (e.g. IBM Data Studio) didn't seem to offer a convenient way of extracting images out of the box. I wasn't suprised. It turns out dragging them out via JDBC was the path of least resistance.

Ensure that you give your JDBC driver enough hints about the heavy nature of the result set that is coming back. For DB2 `ResultSet.TYPE_FORWARD_ONLY` and `ResultSet.CONCUR_READ_ONLY` worked well.

{% highlight java %}
package stoopid;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Blob;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class BlobDumper {

  private Connection getConnection(String connectionString, String user, String password) {

    try {
      Class.forName("com.ibm.db2.jcc.DB2Driver");
      Properties properties = new Properties();
      properties.put("user", user);
      properties.put("password", password);
      return DriverManager.getConnection(connectionString, properties);
    }
    catch (ClassNotFoundException e) {
      e.printStackTrace();
    }
    catch (SQLException e) {
      e.printStackTrace();
    }

    return null;
  }


  public void queryBlobAndSaveToFile(String connectionString, String user, String password, String pk, String sqlQuery, String destinationFile) {

    Connection connection = null;
    InputStream inputStream = null;
    OutputStream outputStream = null;

    try {
      connection = this.getConnection(connectionString, user, password);
      PreparedStatement statement = connection.prepareStatement(
          sqlQuery,
          ResultSet.TYPE_FORWARD_ONLY,
          ResultSet.CONCUR_READ_ONLY); //important for blobs

      statement.setString(1, pk);
      ResultSet resultSet = statement.executeQuery();

      int count = 1;

      while (resultSet.next()) {
        Blob blob = resultSet.getBlob(1);

        if (blob == null) {
          continue;
        }

        inputStream = blob.getBinaryStream();
        outputStream = new FileOutputStream(String.format(destinationFile, pk, count++));
        byte[] buffer = new byte[4096];
        int length = 0;

        while ((length = inputStream.read(buffer)) != -1) {
          outputStream.write(buffer, 0, length);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    } catch (IOException e) {
      e.printStackTrace();
    }
    finally {
      if (inputStream != null) {
        try {
          inputStream.close();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }

      if (outputStream != null) {
        try {
          outputStream.close();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }

      if (connection != null) {
        try {
          connection.close();
        } catch (SQLException e) {
          e.printStackTrace();
        }
      }
    }
  }
}
{% endhighlight %}

A Windows batch script to drive the program:

{% highlight batch %}
SET dbcon=jdbc:db2://127.0.0.1:50000/testdb
SET dbusr=TEH_USER_NAME
SET dbpwd=TEH_PASSWORD
SET pk=dd7ecdbc-44b2-40a8-941b-823b5824362c

@rem Examples:
java -jar blobdump.jar %dbcon% %dbusr% %dbpwd% %pk% "select PHOTO from HR.PEOPLE where PERSON_ID = ?" "c:\\blob\\photo_%%s_%%d.jpg"
java -jar blobdump.jar %dbcon% %dbusr% %dbpwd% %pk% "select SCAN from HR.PEOPLE_DOCUMENT_SCANS where PERSON_ID = ?" "c:\\blob\\scan_%%s_%%d.jpg"
...
{% endhighlight %}

