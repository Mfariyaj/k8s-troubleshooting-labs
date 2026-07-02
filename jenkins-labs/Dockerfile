# Jenkins with ALL plugins pre-installed for troubleshooting labs
# Build: docker build -t jenkins-labs .
# Run:   docker run -d -p 8080:8080 -p 50000:50000 --name jenkins-labs jenkins-labs
#
# This image skips the setup wizard and has all plugins ready.
# Default credentials: admin / admin

FROM jenkins/jenkins:lts

# Skip setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Install all plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Create admin user via Groovy init script
COPY init-scripts/create-admin.groovy /usr/share/jenkins/ref/init.groovy.d/

USER root
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
USER jenkins
