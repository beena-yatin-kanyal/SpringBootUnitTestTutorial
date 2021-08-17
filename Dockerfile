# Pull the centos image from DockerHub repository to build our application as a base.
# The centos image will act as base image.
FROM centos

# Installing java to our image.
RUN yum install -y java

# Creating a temporary directory.
VOLUME /tmp

# Steps to run the spring boot application.
ADD ./target/demo-0.0.1-SNAPSHOT.jar myapp.jar
RUN sh -c 'touch /myapp.jar'
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/myapp.jar"]
