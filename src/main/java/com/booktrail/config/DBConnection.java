package com.booktrail.config;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Robust JDBC Connection Manager.
 * Connects to MySQL on localhost:3306.
 * If MySQL service is unreachable, automatically falls back to an embedded
 * MySQL-compatible database so development, testing, and presentation work seamlessly.
 */
public class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    private static String mysqlDriver;
    private static String mysqlUrl;
    private static String mysqlUser;
    private static String mysqlPassword;
    private static boolean fallbackEnabled = true;

    private static boolean usingMySql = false;
    private static boolean initialized = false;

    // Embedded fallback connection configuration
    private static final String FALLBACK_DRIVER = "org.h2.Driver";
    private static final String FALLBACK_URL = "jdbc:h2:./booktrail_db;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH";
    private static final String FALLBACK_USER = "sa";
    private static final String FALLBACK_PASSWORD = "";

    static {
        loadProperties();
        initDatabase();
    }

    private static void loadProperties() {
        try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties prop = new Properties();
            if (input != null) {
                prop.load(input);
                mysqlDriver = prop.getProperty("db.driver", "com.mysql.cj.jdbc.Driver");
                mysqlUrl = prop.getProperty("db.url", "jdbc:mysql://localhost:3306/booktrail_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC");
                mysqlUser = prop.getProperty("db.user", "root");
                mysqlPassword = prop.getProperty("db.password", "root");
                fallbackEnabled = Boolean.parseBoolean(prop.getProperty("db.fallback.enabled", "true"));
            } else {
                mysqlDriver = "com.mysql.cj.jdbc.Driver";
                mysqlUrl = "jdbc:mysql://localhost:3306/booktrail_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
                mysqlUser = "root";
                mysqlPassword = "root";
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to load db.properties, using defaults.", e);
        }
    }

    private static synchronized void initDatabase() {
        if (initialized) return;

        // Try MySQL first
        try {
            Class.forName(mysqlDriver);
            ensureMySqlDatabaseExists();
            try (Connection conn = DriverManager.getConnection(mysqlUrl, mysqlUser, mysqlPassword)) {
                LOGGER.info(">>> [BookTrail] Successfully connected to MySQL at: " + mysqlUrl);
                usingMySql = true;
                ensureSchemaInitialized(conn);
                initialized = true;
                return;
            }
        } catch (Exception e) {
            LOGGER.warning(">>> [BookTrail] Could not connect to MySQL (" + e.getMessage() + ").");
        }

        // Fallback to embedded engine if MySQL is offline
        if (fallbackEnabled) {
            try {
                Class.forName(FALLBACK_DRIVER);
                try (Connection conn = DriverManager.getConnection(FALLBACK_URL, FALLBACK_USER, FALLBACK_PASSWORD)) {
                    LOGGER.info(">>> [BookTrail] Initialized embedded fallback database engine (MySQL-compatible mode).");
                    usingMySql = false;
                    ensureSchemaInitialized(conn);
                    initialized = true;
                    return;
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, ">>> [BookTrail] Critical: Failed to initialize embedded fallback database.", e);
            }
        }

        LOGGER.severe(">>> [BookTrail] No database connection could be established.");
    }

    private static void ensureMySqlDatabaseExists() {
        if (mysqlUrl == null || !mysqlUrl.contains("mysql")) return;
        try {
            // Build server-level URL without database name so we can create booktrail_db if it does not exist
            String serverUrl = mysqlUrl;
            int slashIdx = serverUrl.indexOf("3306/");
            if (slashIdx != -1) {
                int qIdx = serverUrl.indexOf("?", slashIdx);
                String params = (qIdx != -1) ? serverUrl.substring(qIdx) : "";
                serverUrl = serverUrl.substring(0, slashIdx + 5) + params;
            }
            try (Connection conn = DriverManager.getConnection(serverUrl, mysqlUser, mysqlPassword);
                 Statement stmt = conn.createStatement()) {
                stmt.executeUpdate("CREATE DATABASE IF NOT EXISTS booktrail_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
                LOGGER.info(">>> [BookTrail] Verified or created MySQL database 'booktrail_db'.");
            }
        } catch (Exception e) {
            LOGGER.fine(">>> [BookTrail] Pre-check notice for MySQL database: " + e.getMessage());
        }
    }

    private static void ensureSchemaInitialized(Connection conn) {
        try {
            boolean tablesExist = false;
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM books")) {
                if (rs.next()) {
                    tablesExist = rs.getInt(1) > 0;
                }
            } catch (SQLException ignored) {}

            if (!tablesExist) {
                LOGGER.info(">>> [BookTrail] Executing schema.sql to initialize tables and sample seed data...");
                executeSqlScript(conn, "schema.sql");
                LOGGER.info(">>> [BookTrail] Database schema and seeds successfully populated!");
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, ">>> [BookTrail] Notice during schema check: " + e.getMessage());
        }
    }

    private static void executeSqlScript(Connection conn, String scriptPath) {
        try (InputStream in = DBConnection.class.getClassLoader().getResourceAsStream(scriptPath)) {
            if (in == null) {
                LOGGER.warning("SQL script " + scriptPath + " not found on classpath.");
                return;
            }
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
                 Statement stmt = conn.createStatement()) {

                StringBuilder currentStatement = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    line = line.trim();
                    if (line.isEmpty() || line.startsWith("--") || line.startsWith("//")) {
                        continue;
                    }
                    if (line.contains("--")) {
                        line = line.substring(0, line.indexOf("--")).trim();
                    }
                    currentStatement.append(" ").append(line);
                    if (line.endsWith(";")) {
                        String sql = currentStatement.toString().trim();
                        if (sql.endsWith(";")) {
                            sql = sql.substring(0, sql.length() - 1);
                        }
                        try {
                            stmt.execute(sql);
                        } catch (SQLException sqle) {
                            LOGGER.warning("SQL statement notice: [" + sql + "] -> " + sqle.getMessage());
                        }
                        currentStatement.setLength(0);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error while running SQL script " + scriptPath, e);
        }
    }

    public static Connection getConnection() throws SQLException {
        if (!initialized) {
            initDatabase();
        }
        if (usingMySql) {
            return DriverManager.getConnection(mysqlUrl, mysqlUser, mysqlPassword);
        } else {
            return DriverManager.getConnection(FALLBACK_URL, FALLBACK_USER, FALLBACK_PASSWORD);
        }
    }

    public static boolean isUsingMySql() {
        return usingMySql;
    }
}
