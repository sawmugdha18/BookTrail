package com.booktrail.server;

import com.booktrail.filter.AuthFilter;
import com.booktrail.servlet.AdminServlet;
import com.booktrail.servlet.AuthServlet;
import com.booktrail.servlet.BookServlet;
import com.booktrail.servlet.CommunityServlet;
import com.booktrail.servlet.DiscoverServlet;
import com.booktrail.servlet.ProfileServlet;
import com.booktrail.servlet.RoomServlet;
import com.booktrail.servlet.ShelfServlet;
import org.apache.catalina.Context;
import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;
import org.apache.jasper.servlet.JasperInitializer;
import org.apache.tomcat.util.descriptor.web.FilterDef;
import org.apache.tomcat.util.descriptor.web.FilterMap;

import java.io.File;

/**
 * Embedded Apache Tomcat 10 launcher for 1-click execution.
 * Configures pure Jakarta Servlets, JSP engine, and routing cleanly.
 */
public class TomcatServer {

    public static void main(String[] args) {
        try {
            int port = 8080;
            String portEnv = System.getenv("PORT");
            if (portEnv != null && !portEnv.trim().isEmpty()) {
                try {
                    port = Integer.parseInt(portEnv.trim());
                } catch (NumberFormatException ignored) {}
            }

            Tomcat tomcat = new Tomcat();
            tomcat.setPort(port);
            tomcat.getConnector(); // Initialize default HTTP connector

            File baseDir = new File("target/tomcat");
            if (!baseDir.exists()) {
                baseDir.mkdirs();
            }
            tomcat.setBaseDir(baseDir.getAbsolutePath());

            File webappDir = new File("src/main/webapp");
            if (!webappDir.exists()) {
                webappDir.mkdirs();
            }

            // Mount /booktrail context
            Context ctx = tomcat.addContext("/booktrail", webappDir.getAbsolutePath());
            configureContext(tomcat, ctx);

            // Mount root / context
            Context rootCtx = tomcat.addContext("", webappDir.getAbsolutePath());
            configureContext(tomcat, rootCtx);

            System.out.println("==================================================================");
            System.out.println(">>> [BookTrail] Apache Tomcat 10 Server Initialized Successfully!");
            System.out.println(">>> Access BookTrail at: http://localhost:" + port + "/booktrail/discover");
            System.out.println(">>> Or root URL:        http://localhost:" + port + "/discover");
            System.out.println("==================================================================");

            tomcat.start();
            tomcat.getServer().await();
        } catch (Throwable t) {
            t.printStackTrace();
            System.exit(1);
        }
    }

    private static void configureContext(Tomcat tomcat, Context ctx) {
        ClassLoader classLoader = TomcatServer.class.getClassLoader();
        ctx.setParentClassLoader(classLoader);

        File additionWebInfClasses = new File("target/classes");
        WebResourceRoot resources = new StandardRoot(ctx);
        resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes",
                additionWebInfClasses.getAbsolutePath(), "/"));
        ctx.setResources(resources);

        // Standard Tomcat webapp defaults (DefaultServlet, JspServlet)
        tomcat.initWebappDefaults(ctx);

        // Initialize Jasper for JSP & JSTL taglib parsing
        ctx.addServletContainerInitializer(new JasperInitializer(), null);

        // Application Servlets
        ctx.addServletMappingDecoded("/static/*", "default");

        Tomcat.addServlet(ctx, "DiscoverServlet", new DiscoverServlet());
        ctx.addServletMappingDecoded("/discover", "DiscoverServlet");
        ctx.addServletMappingDecoded("/books", "DiscoverServlet");

        Tomcat.addServlet(ctx, "BookServlet", new BookServlet());
        ctx.addServletMappingDecoded("/book", "BookServlet");

        Tomcat.addServlet(ctx, "AuthServlet", new AuthServlet());
        ctx.addServletMappingDecoded("/login", "AuthServlet");
        ctx.addServletMappingDecoded("/register", "AuthServlet");
        ctx.addServletMappingDecoded("/logout", "AuthServlet");

        Tomcat.addServlet(ctx, "ShelfServlet", new ShelfServlet());
        ctx.addServletMappingDecoded("/shelf", "ShelfServlet");
        ctx.addServletMappingDecoded("/shelf/add", "ShelfServlet");
        ctx.addServletMappingDecoded("/shelf/update", "ShelfServlet");
        ctx.addServletMappingDecoded("/shelf/remove", "ShelfServlet");

        Tomcat.addServlet(ctx, "CommunityServlet", new CommunityServlet());
        ctx.addServletMappingDecoded("/community", "CommunityServlet");

        Tomcat.addServlet(ctx, "RoomServlet", new RoomServlet());
        ctx.addServletMappingDecoded("/room", "RoomServlet");
        ctx.addServletMappingDecoded("/post/create", "RoomServlet");
        ctx.addServletMappingDecoded("/post/delete", "RoomServlet");
        ctx.addServletMappingDecoded("/comment/create", "RoomServlet");
        ctx.addServletMappingDecoded("/comment/delete", "RoomServlet");

        Tomcat.addServlet(ctx, "ProfileServlet", new ProfileServlet());
        ctx.addServletMappingDecoded("/profile", "ProfileServlet");
        ctx.addServletMappingDecoded("/review/save", "ProfileServlet");
        ctx.addServletMappingDecoded("/review/delete", "ProfileServlet");
        ctx.addServletMappingDecoded("/profile/bio", "ProfileServlet");

        Tomcat.addServlet(ctx, "AdminServlet", new AdminServlet());
        ctx.addServletMappingDecoded("/admin", "AdminServlet");
        ctx.addServletMappingDecoded("/admin/book/add", "AdminServlet");
        ctx.addServletMappingDecoded("/admin/book/delete", "AdminServlet");
        ctx.addServletMappingDecoded("/admin/room/add", "AdminServlet");

        // AuthFilter instance
        FilterDef authFilterDef = new FilterDef();
        authFilterDef.setFilterName("AuthFilter");
        authFilterDef.setFilterClass(AuthFilter.class.getName());
        authFilterDef.setFilter(new AuthFilter());
        ctx.addFilterDef(authFilterDef);

        FilterMap authFilterMap = new FilterMap();
        authFilterMap.setFilterName("AuthFilter");
        authFilterMap.addURLPatternDecoded("/*");
        ctx.addFilterMap(authFilterMap);
    }
}
