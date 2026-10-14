package com.example.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(urlPatterns = {"/hello", "/health"})
public class HelloServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if ("/health".equals(request.getServletPath())) {
            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().println("OK");
            return;
        }
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<!doctype html><html><meta charset='UTF-8'><body>.."
            + "<h1>Hello CI/CD</h1><p>Windows Jenkins → Linux Tomcat deployment succeeded.</p>"
            + "</body></html>");
    }
}
