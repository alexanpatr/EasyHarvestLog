<%@page import="com.emkatsom.logcat.*"%>

<%@page import="java.io.*"%>
<%@page import="java.util.*"%>

<%@page import="com.google.gson.*"%>

<%@page import="org.apache.http.client.methods.HttpGet"%>
<%@page import="org.apache.http.client.HttpClient"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.impl.client.DefaultHttpClient"%>

<%@page language="java" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <style>
            *{ padding: 0px; margin: 0px; -webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing: border-box; }
            body, html { height: 100%; width: 100%; }

            ol {
                padding: 10px 100px 10px 35px;
            }

            #data {

            }

            #map {
                width: 100%;
                height: 100%;
            }
        </style>
        <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
        <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
        <%
            String TAG = "LogCat: ";

            String id = request.getParameter("id");
            String download = request.getParameter("download");
            String delete = request.getParameter("delete");
            String type = request.getParameter("type");
        %>
        <title>View - <%=id%> - LogCat</title>
        <script type="text/javascript">
            $(document).ready(function () {
                refresh();
            });
            function refresh() {
                setTimeout(function () {
                    var id = getRequestParameter('id');
                    var type = getRequestParameter('type');
                    try {
                        $('#content').load('view.jsp?id=' + id + '&type=' + type + ' #content', update());
//                        alert(id + " and " + type);
                    }
                    catch (err) {
                        $('#content').load('view.jsp?id=' + id + '&type=' + type + ' #content');
                    }
                    refresh();
                }, 3000);
            }
            function getRequestParameter(sParam) {
                var sPageURL = window.location.search.substring(1);
                var sURLVariables = sPageURL.split('&');
                for (var i = 0; i < sURLVariables.length; i++) {
                    var sParameterName = sURLVariables[i].split('=');
                    if (sParameterName[0] == sParam) {
                        return sParameterName[1];
                    }
                }
            }
        </script>
    </head>
    <body>

        <!--
        <form id="form" action="./index.jsp">
            <input type="submit" value="BACK">
        </form>
        -->

        <div id="content">
            <%
                String html = "";
                String dataUrl = Globals.server_url + "/" + id + "/getdata";

                HttpClient httpClient = new DefaultHttpClient();
                HttpResponse httpResponse = null;

                List<Object> data = new ArrayList<Object>();

                InputStream in = null;
                try {
                    HttpGet httpGet = new HttpGet(dataUrl);
                    httpResponse = httpClient.execute(httpGet);
                    in = httpResponse.getEntity().getContent();
                } catch (Exception e) {
                    System.out.println(TAG + e.getMessage());
                    html = "<ol>" + "Oops!" + "" + "</ol>";
                    out.println(html);
                }

                /**/
//		FileOutputStream outputStream = new FileOutputStream(new File(Globals.db_path + "/" + id + ".dat"));
//		int read = 0;
//		byte[] bytes = new byte[1024];
//		while ((read = in.read(bytes)) != -1) {
//			outputStream.write(bytes, 0, read);
//		}
//                outputStream.close();
                /**/

                ObjectInputStream ois;

                try {
//                    ois = new ObjectInputStream(new FileInputStream(Globals.db_path + "/" + id + ".dat"));

                    ois = new ObjectInputStream(in);
                    data = (List<Object>) ois.readObject();

                    ois.close();
                    in.close();
                    
//                    new File(Globals.db_path + "/" + id + ".dat").delete();
                    
                } catch (Exception e) {
                    System.out.println(TAG + e.getMessage());
//                    html = "<ol>" + "Empty." + "" + "</ol>";
                    out.println(html);
                }

                if (Globals.raw_data.equals(type)) {
                    html = "<ol>";
                    for (Object o : data) {
                        Map m = (Map) o;

                        html += "<li>"
                                + new Date((Long) m.get("timestamp") / 1000000L).toString() + ""
                                + " task[" + m.get("task") + "]"
                                + "@" + m.get("device") + ":"
                                + " " + m.get("sensor") + ""
                                + "" + Arrays.toString((double[]) m.get("values")) + ""
                                + "</li>";
                    }
                    if (data.isEmpty()) {
                        html += "Empty.";
                    }
                    html += "</ol>";
                    out.println(html);
                } else if (Globals.orientation_data.equals(type)) {
                    html = "<ol>";
                    for (Object o : data) {
                        Map m = (Map) o;

                        double[] values = (double[]) m.get("values");
                        double x = values[0];
                        double y = values[1];
                        double z = values[2];

                        html += "<li>"
                                //+ m.get("timestamp") + ""
                                + new Date(Long.valueOf(m.get("timestamp").toString()) / 1000000L).toString() + ""
                                + " task[" + m.get("task") + "]"
                                + "@" + m.get("device") + ":";

                        if (x > 9 && y > 0 && y < 1 && z > 0 && z < 1) {
                            html += " LEFT";
                        } else if (x < -9 && y > 0 && y < 1 && z > 0 && z < 1) {
                            html += " RIGHT";
                        } else if (z > 9.5) {
                            html += " UP";
                        } else if (z < -9.5) {
                            html += " DOWN";
                        }

                        html += "</li>";
                    }
                    if (data.isEmpty()) {
                        html += "Empty.";
                    }
                    html += "</ol>";
                    out.println(html);
                } else if (Globals.location_data.equals(type)) {
                    List<Object[]> list = new ArrayList<Object[]>();

                    for (Object o : data) {
                        Map m = (Map) o;

                        double[] loc = (double[]) m.get("values");
                        Object[] info = {
                            "<div style=\"text-align: center;\";>"
                            + new Date(Long.valueOf(m.get("timestamp").toString()) / 1000000L).toString() + "<br>"
                            + " task[" + m.get("task") + "]" + "@" + m.get("device") + "<br>"
                            + "" + Arrays.toString((double[]) m.get("values"))
                            + "</div>",
                            loc[0],
                            loc[1]
                        };

                        list.add(info);

                    }

                    Gson gson = new Gson();

                    out.print("<div id=\"data\" hidden>" + gson.toJson(list) + "</div>");
            %>
        </div>

        <div id="map"></div>

        <script type="text/javascript">

            var map;

            init();

            var infowindow = new google.maps.InfoWindow();

            var latlngbounds = new google.maps.LatLngBounds();

            var loc_len = 0;

            update();

            function update() {
                var data = document.getElementById('data').innerHTML;
                var locations = JSON.parse(data);

                var marker, i;
                for (i = 0; i < locations.length; i++) {
                    marker = new google.maps.Marker({
                        position: new google.maps.LatLng(locations[i][1], locations[i][2]),
                        map: map
                    });

                    google.maps.event.addListener(marker, 'click', (function (marker, i) {
                        return function () {
                            infowindow.setContent(locations[i][0]);
                            infowindow.open(map, marker);
                        }
                    })(marker, i));

                    latlngbounds.extend(marker.position);
                }

                if (loc_len !== locations.length) {

                    map.fitBounds(latlngbounds);
                    loc_len = locations.length;

                    if (loc_len === 0) {
                        init();
                    }
                }
            }

            function init() {
                map = new google.maps.Map(document.getElementById('map'), {
                    zoom: 2,
                    center: {lat: 0, lng: 0}
                });
            }


        </script>

        <%
            }

            if ("off".equals(download)
                    && "off".equals(delete)) {
            } else if ("on".equals(download)
                    && "off".equals(delete)) {
            } else if ("on".equals(download)
                    && "on".equals(delete)) {
            } else {
            }
        %>

    </body>
</html>
