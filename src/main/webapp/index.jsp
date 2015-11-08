<%@page import="com.emkatsom.logcat.*"%>
<%@page language="java" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>LogCat</title>
    </head>
    <body>
        <h1>LogCat</h1>
        <h2></h2>
        <form action="./view.jsp">
            .../tasks/
            <input name="id" required="required" type="text" placeholder="id"/>
            /getdata
            <select name="type">
                <option value="<%=Globals.raw_data%>" selected><%=Globals.raw_data%></option>
                <option value="<%=Globals.orientation_data%>"><%=Globals.orientation_data%></option>
                <option value="<%=Globals.location_data%>"><%=Globals.location_data%></option>
            </select>
            <!--
            <br>
            <input name="download" type="checkbox"><label>Download</label>
            <br>
            <input name="delete" type="checkbox"><label>Delete</label>
            <br>
            <br>
            -->
            <input type="submit" value="OK">
        </form>
    </body>
</html>
