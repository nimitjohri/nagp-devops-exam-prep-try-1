FROM tomcat:alpine
MAINTAINER Nimit Johri
COPY target/devopssampleapplication.war /usr/local/tomcat/webapps/nimitjohri.war
EXPOSE 8080
CMD ["catalina.sh", "run"]