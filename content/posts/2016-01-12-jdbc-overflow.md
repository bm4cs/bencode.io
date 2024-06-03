---
layout: post
title: "Java Prepared Statement Overflow"
date: "2016-01-12 21:12:10"
comments: false
categories:
- java
tags:
- java
---

On the hunt for an sporadic `DB2 SQL Error -805`, I took a dive into some logs. It had been rearing its ugly head for weeks now, and starting to impact our business area. The call stack pointed straight to the bad patch of code, the Java EE solution contains a programmatic `TimerService`, responsible for shuffling data from one database to other; a rudimentary replication solution in other words. The specific source database in this case happened to be DB2 running on AIX. No big deal. Except that the code has proven to be flakey under load. That is, the code was transferring ~500,000 records daily, but was choking for ~100,000 records, the lions share of the load and failures seemed to pertain to BLOB data.

As usual a stackoverflow [post](http://stackoverflow.com/questions/21526209/db2-sqlcode-805-sqlstate-51002-sqlerrmc-nullid-syslh203-0x5359534c564c3031) was all over it.

Make sure you take a look into your JVM's `SystemError.log`, its a treasure chest of useful facts. Here's a summarised version of what I had:

```
[12/01/16 13:05:27:242 EST] 000000a4 SystemErr     R ***** Out of Package Error Occurred (2016-01-12 13:05:27.238) *****

Exception stack trace:
com.ibm.db2.jcc.am.SqlException: DB2 SQL Error: SQLCODE=-805, SQLSTATE=51002, SQLERRMC=NULLID.SYSLN30A 0X5359534C564C3031, DRIVER=4.16.53
    com.ibm.db2.jcc.am.fd.a(fd.java:744)
    com.ibm.db2.jcc.am.fd.a(fd.java:60)
    com.ibm.db2.jcc.am.fd.a(fd.java:127)
    com.ibm.db2.jcc.am.to.c(to.java:2771)
    com.ibm.db2.jcc.t4.ab.p(ab.java:936)
    com.ibm.db2.jcc.t4.ab.h(ab.java:144)
    com.ibm.db2.jcc.t4.ab.b(ab.java:41)
    com.ibm.db2.jcc.t4.o.a(o.java:32)
    com.ibm.db2.jcc.t4.tb.i(tb.java:145)
    com.ibm.db2.jcc.am.to.kb(to.java:2161)
    com.ibm.db2.jcc.am.to.a(to.java:3258)
    com.ibm.db2.jcc.am.to.a(to.java:697)
    com.ibm.db2.jcc.am.to.executeQuery(to.java:676)
    com.ibm.ws.rsadapter.jdbc.WSJdbcStatement.pmiExecuteQuery(WSJdbcStatement.java:1728)
    com.ibm.ws.rsadapter.jdbc.WSJdbcStatement.executeQuery(WSJdbcStatement.java:1019)
    net.bencode.dao.ReplicationDAOImpl.querySourceRecords(ReplicationDAOImpl.java:625)
    sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:95)
    sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:56)
    java.lang.reflect.Method.invoke(Method.java:620)
    com.ibm.ejs.container.EJSContainer.invokeProceed(EJSContainer.java:5730)
    com.ibm.ejs.container.interceptors.InvocationContextImpl.proceed(InvocationContextImpl.java:568)
    org.apache.webbeans.ejb.common.interceptor.OpenWebBeansEjbInterceptor.callInterceptorsAndDecorators(OpenWebBeansEjbInterceptor.java:526)
    org.apache.webbeans.ejb.common.interceptor.OpenWebBeansEjbInterceptor.callToOwbInterceptors(OpenWebBeansEjbInterceptor.java:200)
    sun.reflect.GeneratedMethodAccessor66.invoke(Unknown Source)
    sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:56)
    java.lang.reflect.Method.invoke(Method.java:620)
    com.ibm.ejs.container.interceptors.InterceptorProxy.invokeInterceptor(InterceptorProxy.java:227)
    com.ibm.ejs.container.interceptors.InvocationContextImpl.proceed(InvocationContextImpl.java:548)
    net.bencode.common.ServicePerformanceInterceptor.callLog(ServicePerformanceInterceptor.java:30)
    sun.reflect.GeneratedMethodAccessor65.invoke(Unknown Source)
    sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:56)
    java.lang.reflect.Method.invoke(Method.java:620)
    com.ibm.ejs.container.interceptors.InterceptorProxy.invokeInterceptor(InterceptorProxy.java:227)
    com.ibm.ejs.container.interceptors.InvocationContextImpl.proceed(InvocationContextImpl.java:548)
    org.apache.webbeans.ejb.WSEJBInterceptor.callToOwbInterceptors(WSEJBInterceptor.java:136)
    sun.reflect.GeneratedMethodAccessor62.invoke(Unknown Source)
    sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:56)
    java.lang.reflect.Method.invoke(Method.java:620)
    com.ibm.ejs.container.interceptors.InterceptorProxy.invokeInterceptor(InterceptorProxy.java:227)
    com.ibm.ejs.container.interceptors.InvocationContextImpl.proceed(InvocationContextImpl.java:548)
    com.ibm.ejs.container.interceptors.InvocationContextImpl.doAroundInvoke(InvocationContextImpl.java:229)
    com.ibm.ejs.container.EJSContainer.invoke(EJSContainer.java:5621)
    com.ibm.ejs.container.interceptors.InvocationContextImpl.doAroundInvoke(InvocationContextImpl.java:229)
    com.ibm.ejs.container.EJSContainer.invoke(EJSContainer.java:5621)
    net.bencode.service.ReplicationServiceImpl.replicate(ReplicationServiceImpl.java:112)
    sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:95)
    sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:56)
    java.lang.reflect.Method.invoke(Method.java:620)
    com.ibm.ejs.container.EJSContainer.invokeProceed(EJSContainer.java:5730)
    com.ibm.ejs.container.interceptors.InvocationContextImpl.proceed(InvocationContextImpl.java:568)
    org.apache.webbeans.ejb.common.interceptor.OpenWebBeansEjbInterceptor.callAroundTimeouts(OpenWebBeansEjbInterceptor.java:604)
    sun.reflect.GeneratedMethodAccessor64.invoke(Unknown Source)
    sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:56)
    java.lang.reflect.Method.invoke(Method.java:620)
    com.ibm.ejs.container.interceptors.InterceptorProxy.invokeInterceptor(InterceptorProxy.java:227)
    com.ibm.ejs.container.interceptors.InvocationContextImpl.proceed(InvocationContextImpl.java:548)
    org.apache.webbeans.ejb.WSEJBInterceptor.callToOwbInterceptors(WSEJBInterceptor.java:136)
    sun.reflect.GeneratedMethodAccessor62.invoke(Unknown Source)
    sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:56)
    java.lang.reflect.Method.invoke(Method.java:620)
    com.ibm.ejs.container.interceptors.InterceptorProxy.invokeInterceptor(InterceptorProxy.java:227)
    com.ibm.ejs.container.interceptors.InvocationContextImpl.proceed(InvocationContextImpl.java:548)
    com.ibm.ejs.container.interceptors.InvocationContextImpl.doAroundInvoke(InvocationContextImpl.java:229)
    com.ibm.ejs.container.EJSContainer.invoke(EJSContainer.java:5621)
    com.ibm.ejs.container.TimedObjectWrapper.invokeCallback(TimedObjectWrapper.java:114)
    com.ibm.ejs.container.TimerNpListener.doWork(TimerNpListener.java:293)
    com.ibm.ejs.container.TimerNpListener.doWorkWithRetries(TimerNpListener.java:171)
    com.ibm.ejs.container.TimerNpListener.fired(TimerNpListener.java:141)
    com.ibm.ws.asynchbeans.AlarmImpl.callListenerMethod(AlarmImpl.java:427)
    com.ibm.ws.asynchbeans.timer.GenericTimer.run(GenericTimer.java:228)
    com.ibm.ws.asynchbeans.J2EEContext$RunProxy.run(J2EEContext.java:266)
    java.security.AccessController.doPrivileged(AccessController.java:303)
    javax.security.auth.Subject.doAs(Subject.java:494)
    com.ibm.websphere.security.auth.WSSubject.doAs(WSSubject.java:132)
    com.ibm.websphere.security.auth.WSSubject.doAs(WSSubject.java:90)
    com.ibm.ws.asynchbeans.J2EEContext$DoAsProxy.run(J2EEContext.java:337)
    java.security.AccessController.doPrivileged(AccessController.java:333)
    com.ibm.ws.asynchbeans.J2EEContext.run(J2EEContext.java:1175)
    com.ibm.ws.asynchbeans.AlarmImpl.runListenerAsCJWork(AlarmImpl.java:249)
    com.ibm.ws.asynchbeans.am._Alarm.fireAlarm(_Alarm.java:340)
    com.ibm.ws.asynchbeans.am._Alarm.run(_Alarm.java:237)
    com.ibm.ws.util.ThreadPool$Worker.run(ThreadPool.java:1865)

Concurrently open statements:
1. SQL string:  SELECT * FROM FOO.TABLE_A WHERE ID=?
   Number of statements:  1006
2. SQL string:  SELECT * FROM BAR.TABLE_B WHERE ID=?
   Number of statements:  1005
3. SQL string:  SELECT * FROM BIP.TABLE_C WHERE ID=?
   Number of statements:  1004
4. SQL string:  SELECT COL_A FROM FOO.TABLE_A WHERE ID='C4358417-95F9-4C3D-B430-4692F50D69E2'
   Number of statements:  1
```

Not only do you get a fantastic call stack, the best part is the *concurrently open statements* report at the end. You can see the three culprit SQL queries responsible for flooding the `PreparedStatement` buffer. Closer inspection of the offending data access logic confirmed poor management (i.e. creation of new, without freeing them) of `PreparedStatement` instances within a humongous loop. Yuck. I suppose these junk JDBC `PreparedStatement` objects we're eventually flagged for garbage collection, the GC would occassionally scoop up some garbage and the code would continue to limp along, not making this an obvious runtime behaviour to track down.

**Bad code snippet:**

```java
PreparedStatement sourceStatement = null;
PreparedStatement targetStatement = null;
ResultSet resultSet = null;

try
{
  targetConnection.setAutoCommit(false);

  for (String tableName : tablesList) {
    sql = "select * from " + tableName + " where id=?";
    sourceStatement = localConnection.prepareStatement(sql);
    sourceStatement.setString(1, id);
    resultSet = sourceStatement.executeQuery();

    ResultSetMetaData resultSetMeta = rs.getMetaData();

    StringBuilder columnNames = new StringBuilder();
    StringBuilder bindVariables = new StringBuilder();

    for (int i = 1; i <= resultSetMeta.getColumnCount(); i++) {
      if (i > 1) {
        columnNames.append(", ");
        bindVariables.append(", ");
      }

      columnNames.append(resultSetMeta.getColumnName(i));
      bindVariables.append('?');
    }

    String insertSql = "INSERT INTO " + tableName + " (" + columnNames + ") VALUES (" + bindVariables + ")";
    targetStatement = targetConnection.prepareStatement(insertSql);

    while (rs.next()) {
      for (int j = 1; j <= resultSetMeta.getColumnCount(); j++) {
        targetStatement.setObject(j, rs.getObject(j));
      }
      targetStatement.executeUpdate();
    }
  }

  String completedSql = "INSERT INTO REPL.RECEIPT(UID) VALUES (?)";
  targetStatement = targetConnection.prepareStatement(completedSql);
  targetStatement.setString(1, id);
  targetStatement.executeUpdate();
  targetConnection.commit();
}
catch (Exception e) {
  rollback(targetConnection, e);
}
finally {
  try {
    resultSet.close();
    sourceStatement.close();
    targetStatement.close();
    sourceConnection.close();
    targetConnection.close();
  }
  catch (SqlException sqlException) {
    logger.error("puff");
  }
}
```

Note the new `PreparedStatements` are birthed within the `for` loop, but never decommissioned. In short, apply a good dose of caution when creating objects (especially JDBC) recursively or in the context of a loop. Also interesting to note, that the nightly FindBugs static analysis report (which we run on the CI server) didn't pick this up.

