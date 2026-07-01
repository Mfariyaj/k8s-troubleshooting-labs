import java.util.*;
import java.net.*;
import com.sun.net.httpserver.*;
import java.io.*;

public class App {
    // Simulate memory-intensive application
    private static List<byte[]> memoryHog = new ArrayList<>();
    
    public static void main(String[] args) throws Exception {
        System.out.println("Starting Java application with -Xmx512m...");
        System.out.println("JVM Max Memory: " + Runtime.getRuntime().maxMemory() / 1024 / 1024 + "MB");
        System.out.println("JVM Total Memory: " + Runtime.getRuntime().totalMemory() / 1024 / 1024 + "MB");
        
        // Start HTTP server
        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);
        server.createContext("/", exchange -> {
            String response = "{\"status\":\"running\",\"memory_used_mb\":" + 
                (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()) / 1024 / 1024 + "}";
            exchange.sendResponseHeaders(200, response.length());
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        });
        server.createContext("/health", exchange -> {
            String response = "{\"status\":\"healthy\"}";
            exchange.sendResponseHeaders(200, response.length());
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        });
        server.start();
        System.out.println("HTTP server started on port 8080");
        
        // Simulate gradual memory usage (like a real app loading data)
        System.out.println("Loading application data into memory...");
        for (int i = 0; i < 50; i++) {
            // Allocate 10MB chunks
            memoryHog.add(new byte[10 * 1024 * 1024]);
            System.out.println("Allocated " + (i + 1) * 10 + "MB of data...");
            Thread.sleep(500);
        }
        
        System.out.println("Application fully loaded. Waiting for requests...");
        Thread.currentThread().join();
    }
}
