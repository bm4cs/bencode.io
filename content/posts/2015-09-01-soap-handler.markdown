---
layout: post
title: "JAX-WS SOAP Logger"
date: "2015-09-01 09:56:33"
comments: false
categories: [Java]
---

Hot tip, logging helps understand how a piece of software works, long after it has left the cosy confines of the debugger.

Logging SOAP message bodies can be really handy, when the thing that is interacting with your software is out of your control (i.e. a vendor or trading partner). And if you're using web services, the likehood of this is high.

Running JAX-WS web services in our servlet container, needed a quick and easy way to acheive this. Welcome to the wonderful world of [SOAPHandler's](https://docs.oracle.com/javase/7/docs/api/javax/xml/ws/handler/soap/SOAPHandler.html).

> SOAPHandler provides access to the SOAP message for either an RPC request or response. The `javax.xml.soap.SOAPMessage` specifies the standard Java API for the representation of a SOAP 1.1 message with attachments.

Below showcases a simple SOAP message logger, which performs the actual logging grunt work on a background task using the `@Asyncronous` annotation.

### SOAPLoggingHandler.java

The actual SOAP handler. Its a rather clean and simple API to use.

{% highlight java %}
package net.bencode.handlers;

//imports omitted

public class SOAPLoggingHandler implements SOAPHandler<SOAPMessageContext> {
  
  private static final Logger logger = LoggerFactory.getLogger(SOAPLoggingHandler.class);
  
//  @EJB
//  private ISoapLoggerService soapLoggerService;
  
  private SoapLoggerService getSoapLoggerService() {
    Context context;
    
    try {
      context = new InitialContext();
      return (SoapLoggerService)context.lookup("java:module/SoapLoggerServiceImpl");
    } catch (NamingException e) {
      logger.error(e.getMessage());
    }
    
    return null;
  }
  

  public Set<QName> getHeaders() {
    return null;
  }

  public boolean handleMessage(SOAPMessageContext soapMessageContext) {
    SOAPMessage soapMessage = soapMessageContext.getMessage();
    Boolean outboundProperty = (Boolean)soapMessageContext.get(MessageContext.MESSAGE_OUTBOUND_PROPERTY);
    this.getSoapLoggerService().log(soapMessage, outboundProperty);
    return true;
  }

  public boolean handleFault(SOAPMessageContext soapMessageContext) {
    SOAPMessage soapMessage = soapMessageContext.getMessage();
    Boolean outboundProperty = (Boolean)soapMessageContext.get(MessageContext.MESSAGE_OUTBOUND_PROPERTY);
    this.getSoapLoggerService().log(soapMessage, outboundProperty);
    return true;
  }

  public void close(MessageContext messageContext) {
  }
}
{% endhighlight %}


### SoapLoggerService.java

The interface of the logging EJB.

{% highlight java %}
package net.bencode.service.async;

public interface SoapLoggerService {
  public abstract void log(SOAPMessage soapMessage, Boolean isOutbound);
}
{% endhighlight %}


### SoapLoggerServiceImpl.java

Asynchronous EJB for SOAP logging grunt work; buffering, parsing, database persistence. This guy consults a configuration service to determine if it's disabled, and if not if it should filter based on the SOAP action. Note: The configuration service code not included.

{% highlight java %}
package net.bencode.service.async;

//imports omitted

@Stateless
@Asynchronous
public class SoapLoggerServiceImpl implements SoapLoggerService {

  private final static Logger logger = LoggerFactory.getLogger(SoapLoggerServiceImpl.class);

  @Inject
  private XmlSoapDAO xmlSoapDAO;
  
  @EJB
  private ConfigurationService configurationService;
  
  @Override
  public void log(SOAPMessage soapMessage, Boolean isOutbound) {
    try {
      if (!this.isEnabled()) {
        return;
      }
      
      String soapAction = this.querySoapAction(soapMessage);
      
      if (this.shouldExclude(soapAction)) {
        return;
      }
      
      String messageContents = this.getMessageBody(soapMessage);
      String customerId = this.queryDocument(soapMessage, "//*[local-name()='customer_id']/text()");
      SoapLogDTO soapLog = new SoapLogDTO(customerId, soapAction, messageContents);
      xmlSoapDAO.insert(soapLog);
    }
    catch (Exception exception) {
      logger.warn("SoapLoggerService unhandled exception: " + exception.getMessage());
    }
  }

  private boolean isEnabled() {
    try {
      String configValue = configurationService.getValue(ConfigConstants.SOAPLOGGING_ENABLED);
      
      if (configValue == null || configValue.equalsIgnoreCase("OFF")) {
        return false;
      }
      
      if (configValue.equalsIgnoreCase("ON")) {
        return true;
      }
    }
    catch (Exception exception) {
      return false;
    }
    
    return false;
  }

  private boolean shouldExclude(String soapAction) {
    try {
      if (soapAction == null || soapAction.trim().isEmpty()) {
        return false;
      }
      
      String configValue = configurationService.getValue(ConfigConstants.SOAPLOG_EXCLUDE_FILTER);
      
      if (configValue == null || configValue.trim().isEmpty()) {
        return false;
      }
      
      String[] parts = configValue.split(",");
      
      if (parts == null || parts.length == 0) {
        return false;
      }
      
      for (String part : parts) {
        if (soapAction.equalsIgnoreCase(part)) {
          return true;
        }
      }
    }
    catch (Exception exception) {
      return false;
    }
    return false;
  }

  private String getMessageBody(SOAPMessage message) {
    try {
      StringWriter writer = new StringWriter();
      StreamResult result = new StreamResult(writer);
      TransformerFactory transformerFactory = TransformerFactory.newInstance();
      Transformer transformer = transformerFactory.newTransformer();
      transformer.transform(message.getSOAPPart().getContent(), result);
      return writer.getBuffer().toString();
    } catch (Exception exception) {
      logger.info("Problem reading SOAP message. " + exception.getMessage());
    }
    return "";
  }

  private String queryDocument(SOAPMessage message, String xpathQuery) {
    try {
      XPath xpath = XPathFactory.newInstance().newXPath();
      return xpath.evaluate(xpathQuery, message.getSOAPBody());
    } catch (Exception exception) {
      logger.info("Failed to evaluate XPath query. " + exception.getMessage());
    }

    return "";
  }

  private String querySoapAction(SOAPMessage message) {
    String operationName = "";

    try {
      SOAPEnvelope soapEnvelope = message.getSOAPPart().getEnvelope();
      SOAPBody soapBody = soapEnvelope.getBody();
      
      int nodeListLength = soapBody.getChildNodes().getLength();
      
      for (int i = 0; i < nodeListLength; i++) {
        
        if (soapBody.getChildNodes().item(i) != null) {
          if (soapBody.getChildNodes().item(i).getLocalName() != null
            && !soapBody.getChildNodes().item(i).getLocalName().trim().isEmpty()) {
            operationName = soapBody.getChildNodes().item(i).getLocalName();
          }
        }
      }
    } catch (SOAPException soapException) {
      logger.info("Problem parsing SOAP Action: " + soapException.getMessage());
    }

    return operationName;
  }
}
{% endhighlight %}


### XmlSoapDAO.java

{% highlight java %}
package net.bencode.dao;

public interface XmlSoapDAO {
  public abstract void insert(SoapLogDTO soapLog);
}
{% endhighlight %}


### XmlSoapDAOImpl.java

{% highlight java %}
package net.bencode.dao;

public class XmlSoapDAOImpl extends AbstractDAO implements XmlSoapDAO {

  @Override
  public void insert(SoapLogDTO soapLog) {
    String sql = "insert into LOGGING.SOAP(SOAP_ACTION, UID, MESSAGE, XML_SOAP_ID) values (?, ?, ?, ?)";
    
    String xmlSoapId = getUniqueId();
    List<Object> params = new ArrayList<Object>();
    params.add(soapLog.getSoapAction());
    params.add(soapLog.getCustomerId());
    params.add(soapLog.getMessage());
    params.add(xmlSoapId);
    
    this.executeInsert(sql, params);
  }
}
{% endhighlight %}


### SoapLogDTO.java

{% highlight java %}
package net.bencode.dto.logging;

public class SoapLogDTO {

  private String customerId;
  
  private String soapAction;
  
  private String message;

  public SoapLogDTO(String customerId, String soapAction, String message) {
    this.customerId = customerId;
    this.soapAction = soapAction;
    this.message = message;
  }

  public String getCustomerId() {
    return customerId;
  }

  public void setCustomerId(String customerId) {
    this.customerId = customerId;
  }

  public String getSoapAction() {
    return soapAction;
  }

  public void setSoapAction(String soapAction) {
    this.soapAction = soapAction;
  }

  public String getMessage() {
    return message;
  }

  public void setMessage(String message) {
    this.message = message;
  }
}
{% endhighlight %}
