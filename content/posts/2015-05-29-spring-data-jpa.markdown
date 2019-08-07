---
layout: post
title: "Spring Data JPA Fun"
date: "2015-05-29 17:03:05"
comments: false
categories: [Java]
---

Maven dependencies:

    <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
      <version>5.1.21</version>
    </dependency>
    <dependency>
      <groupId>org.hibernate</groupId>
      <artifactId>hibernate-entitymanager</artifactId>
      <version>4.1.9.Final</version>
    </dependency>
    <dependency>
      <groupId>javax.transaction</groupId>
      <artifactId>jta</artifactId>
      <version>1.1</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-jdbc</artifactId>
      <version>3.2.0.RELEASE</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-orm</artifactId>
      <version>3.2.0.RELEASE</version>
    </dependency>



## Entity Manager Factory

Used to bootstrap JPA and also Hibernate inside our application. The `LocalContainerEntityManagerFactoryBean` which is packaged in the `spring-orm.jar`, references the defined persistence unit.


    <bean id="entityManagerFactory" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
        <property name="persistenceUnitName" value="punit" />
        <property name="dataSource" ref="dataSource" />
        <property name="jpaVendorAdapter">
            <bean class="org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter">
                <property name="showSql" value="true" />
            </bean>
        </property>
        <property name="jpaPropertyMap">
            <map>
                <entry key="hibernate.dialect" value="org.hibernate.dialect.MySQL5InnoDBDialect" />
                <entry key="hibernate.hbm2ddl.auto" value="none" />
                <entry key="hibernate.format_sql" value="true" />
            </map>
        </property>
    </bean>



## Transaction Manager

The `JpaTransactionManager` (packaged within `spring-tx.jar`) which sucks in a reference to the entityManagerFactory, is responsible for taking care of transactions within the JPA layer.


## JPA Annotations

*   `@Entity` - flags an object as a persistable thing
*   `@Table` - useful for describing more db related concerns such as schema name, and so on.
*   `@Id` - flags a member variable as a simple primary key
*   `@GeneratedValue` - compliments the `@Id` annotation. Four options, IDENTITY, AUTO, SEQUENCE and TABLE. The TABLE option be tied in with the @TableGenerator annotation.
*   `@Column` - like @Table, provides way to control how fields are manifested as physical db columns, such as its name, nullability, uniqueness, and so on.
*   `@PersistenceContext` - relates to a specific persistence unit. This guy will inject the entity manager into the running application.
*   `@Service` - for business logic, or the entry point to lots of business logic such as a facade.
*   `@Repository` - a place where database interaction occurs.
*   `@Transactional` - self explanitory, it takes care of transactions. Actually its quite awesome, and rids boilerplate type begin/commit/rollback cruft.

    import javax.persistence.Entity;
    import javax.persistence.GeneratedValue;
    import javax.persistence.Id;
    import javax.persistence.Table;
    
    @Entity
    @Table(name="goals")
    public class Goal {
    
        @Id
        @GeneratedValue
        private Long id;
        ...


Here's a simple repository pattern, that makes use of JPA's EntityManager. Note the `flush` command here is essential, to force the EntityManager to commit here and now.

    package net.bencode.repository;
    
    import net.bencode.model.Protein;
    import org.springframework.stereotype.Repository;
    import javax.persistence.EntityManager;
    import javax.persistence.PersistenceContext;
    
    @Repository("proteinRepository")
    public class ProteinRepository implements IProteinRepository {
    
        @PersistenceContext
        private EntityManager entityManager;
    
        @Override
        public Goal save(Goal goal) {
            entityManager.persist(goal);
            entityManager.flush();
            return goal;
        }
    }


The above repository alone will fail, due to the absence of a transaction. If you are invoking your repository from a service layer, that is a great place to do so using the `@Transactional` annotation, for example:

    package net.bencode.service;
    
    import net.bencode.model.Goal;
    import net.bencode.repository.ProteinRepository;
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.stereotype.Service;
    import org.springframework.transaction.annotation.Transactional;
    
    @Service("proteinService")
    public class ProteinService implements IProteinService {
    
        @Autowired
        private ProteinRepository proteinRepository;
    
        @Override
        @Transactional
        public Protein save(Protein protein) {
            return proteinRepository.save(protein);
        }
    }


## Joining things

*    `@OneToOne`
*    `@OneToMany` - one of the things I am in, can contain many other things.
*    `@ManyToOne` - the thing I am in, belongs to something.
*    `@ManyToMany`

### Protein.java
    @OneToMany(mappedBy="protein", cascade=CascadeType.ALL, fetch=FetchType.LAZY) //FetchType.EAGER
    private List<Store> stores = new ArrayList<Store>();
    
### Store.java
    @ManyToOne
    private Protein protein;



## JPQL (Java Persistence Query Language)

A query language that focuses on objects.

**Traditional SQL**

    select * from supplements

**JPQL**

    Query query = entityManager.createQuery("Select s from Supplement s")


## LazyInitializationException

A common issue when using FetchType.LAZY in the context of a web application, is that the lifecycle of a JPA context/session is that of a single HTTP request/response cycle.

org.hibernate.LazyInitializationException: failed to lazily initialize a collection of role:  net.bencode.model.HaloSkull, could not initialize proxy - no Session
  org.hibernate.collection.internal.AbstractPersistentCollection.throwLazyInitializationException(AbstractPersistentCollection.java:566)
  org.hibernate.collection.internal.AbstractPersistentCollection.withTemporarySessionIfNeeded(AbstractPersistentCollection.java:186)
  org.hibernate.collection.internal.AbstractPersistentCollection.initialize(AbstractPersistentCollection.java:545)
  org.hibernate.collection.internal.AbstractPersistentCollection.read(AbstractPersistentCollection.java:124)
  org.hibernate.collection.internal.PersistentBag.iterator(PersistentBag.java:266)
  org.apache.taglibs.standard.tag.common.core.ForEachSupport.toForEachIterator(ForEachSupport.java:348)
  org.apache.taglibs.standard.tag.common.core.ForEachSupport.supportedTypeForEachIterator(ForEachSupport.java:224)
  org.apache.taglibs.standard.tag.common.core.ForEachSupport.prepare(ForEachSupport.java:155)
  javax.servlet.jsp.jstl.core.LoopTagSupport.doStartTag(LoopTagSupport.java:256)
  org.apache.jsp.WEB_002dINF.jsp.getGoals_jsp._jspx_meth_c_005fforEach_005f1(getGoals_jsp.java:172)
  org.apache.jsp.WEB_002dINF.jsp.getGoals_jsp._jspx_meth_c_005fforEach_005f0(getGoals_jsp.java:132)
  org.apache.jsp.WEB_002dINF.jsp.getGoals_jsp._jspService(getGoals_jsp.java:81)
  org.apache.jasper.runtime.HttpJspBase.service(HttpJspBase.java:70)
  javax.servlet.http.HttpServlet.service(HttpServlet.java:728)

The `OpenEntityManagerInViewFilter` prevents the JPA transactional session from being closed, as a result of the request/response cycle. To use it simply register the filter in your `web.xml`:

    <filter>
        <filter-name>SpringOpenEntityManagerInViewFilter</filter-name>
        <filter-class>org.springframework.orm.jpa.support.OpenEntityManagerInViewFilter</filter-class>
    </filter>

    <filter-mapping>
        <filter-name>SpringOpenEntityManagerInViewFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>


## Spring Data JPA

Spring Data JPA is a wrapper for JPA, that eliminates a large amount of boilerplate data access layer code that plain JPA requires. It also is very extensible, catering for more complex scenarios. Take for example the `save` implementation on a repository class:

    public HaloSkull save(HaloSkull skull) {
      if (skull.getId() == null) {
        entityManager.persist(skull);
        entityManager.flush();
      }
      else {
        skull = entityManager.merge(skull);
      }
      return skull;
    }

First up, dependencies. Hack your `pom.xml` and add a new dependency. Note the transisitive dependency on `spring-aop` is incompatible with Spring MVC, and should be excluded if consumed in the context of an MVC application.

    <dependency>
      <groupId>org.springframework.data</groupId>
      <artifactId>spring-data-jpa<artifactId/>
      <version>1.3.0.RELEASE</version>
      <exclusions>
        <groupId>org.springframework</groupId>
        <artifactId>spring-aop<artifactId/>
      </exclusions>
    </dependency>

Edit your `jpaContext.xml` and register the Spring Data JPA repositories element:

    <jpa:repositories base-package="net.bencode.repository" />


Then for the real magic, when it comes to cleaning up repostiories implementations. Repository concrete classes can more or less be dumped. Interfaces become the implementations.

    @Repository("haloRepository")
    public interface HaloRepository extends JpaRepository<Halo, long> { }

That's it. No handcoded repository implementation classes required (unless specific customisations are needed).
