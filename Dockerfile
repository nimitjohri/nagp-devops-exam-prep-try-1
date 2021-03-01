FROM tomcat:alpine
MAINTAINER Nimit Johri
COPY target/devopssampleapplication.war /usr/local/tomcat/webapps/nimitjohri.war
RUN wget -O /usr/local/tomcat/webapps/nimitjohri.war http://192.168.1.7:8081/artifactory/nagp-devops-exam-try-1/com/example/nagp-devops-exam-try-1/0.0.1-SNAPSHOT/nagp-devops-exam-try-1-0.0.1-SNAPSHOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]