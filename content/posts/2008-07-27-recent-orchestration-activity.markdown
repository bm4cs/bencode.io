---
layout: post
title: "Recent Orchestration Activity"
date: "2008-07-27 21:07:48"
comments: false
categories: BizTalk
---

Here is a simple TSQL query for the BizTalk tracking database, to summarise the orchestration instantiation  head-count for a given host. Your mileage with this query may vary depending on how frequently your tracking data archive job is scheduled for (i.e. this query might not have much data to work with if the data has just been archived and purged).

    SELECT
      [Service/Name],
      COUNT(*)
    FROM 
      dbo.dtav_ServiceFacts sf
    WHERE 
      [Service/Type] = 'Orchestration' AND
      [ServiceInstance/Host] = 'FooHost'
    GROUP BY  [Service/Name]
    ORDER BY 2 DESC
