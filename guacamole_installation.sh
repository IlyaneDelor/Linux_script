#Update 
apt update

#Install Guacamole on Debian 10
apt install -y build-essential libcairo2-dev libturbojpeg0 libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev libssl-dev libvorbis-dev libwebp-dev libpulse-dev

#Install FreeRDP libraries enable support for RDP via Guacamole
echo "deb http://deb.debian.org/debian buster-backports main" > /etc/apt/sources.list.d/backports.list

apt update
apt-get install freerdp2-dev

apt update



# Install a specifiy version of Guacamole
VER=1.3.0
wget https://downloads.apache.org/guacamole/$VER/source/guacamole-server-$VER.tar.gz
tar xzf guacamole-server-$VER.tar.gz
cd guacamole-server-$VER

# Run "configure" script to check if everything is good
./configure --with-init-dir=/etc/init.d --enable-allow-freerdp-snapshots | tee guacamole_server.log

# Compile and install Guacamole Server
make
make install

# Create the necessary links and cache to the most recent shared libraries found in the guacamole server directory.
ldconfig

# Running Guacamole-Server
systemctl daemon-reload
systemctl start guacd
systemctl enable guacd

systemctl status guacd | tee guacamole_statut.log

# Install Tomcat Servlet to connect to guacamole server via the web browser
apt install tomcat9 tomcat9-admin tomcat9-common tomcat9-user -y

systemctl status tomcat9.service | tee tomcat_statut.log

# Allow external access to the serverlet
ss -altnp | grep 80
ufw allow 8080/tcp

# Install Guacamole Client
mkdir /etc/guacamole

# Download Guacamole-client
VER=1.3.0
wget https://downloads.apache.org/guacamole/$VER/binary/guacamole-$VER.war -O /etc/guacamole/guacamole.war
ln -s /etc/guacamole/guacamole.war /var/lib/tomcat9/webapps/

systemctl restart tomcat9
systemctl restart guacd

# Configure Apache Guacamole
mkdir /etc/guacamole/{extensions,lib}
echo "GUACAMOLE_HOME=/etc/guacamole" >> /etc/default/tomcat9
touch /etc/guacamole/guacamole.properties
echo "guacd-hostname: localhost" >> /etc/guacamole/guacamole.properties
echo "user-mapping: /etc/guacamole/user-mapping.xml" >> /etc/guacamole/guacamole.properties
echo "auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider" >> /etc/guacamole/guacamole.properties
ln -s /etc/guacamole /usr/share/tomcat9/.guacamole

#echo -n "Ilyane93*/" | openssl md5


echo "<user-mapping>
        
    <!-- Per-user authentication and config information -->

    <!-- A user using md5 to hash the password
         guacadmin user and its md5 hashed password below is used to 
             login to Guacamole Web UI-->
    <authorize 
            username="guacadmin"
            password="8d973ed89f465ec5dcd2caa7c1365f20"
            encoding="md5">

        <!-- First authorized Remote connection -->
        <connection name="Ubuntu 20.04 Server SSH">
            <protocol>ssh</protocol>
            <param name="hostname">192.168.57.3</param>
            <param name="port">22</param>
        </connection>

        <!-- Second authorized remote connection -->
        <connection name="Windows 7 RDP">
            <protocol>rdp</protocol>
            <param name="hostname">192.168.56.103</param>
            <param name="port">3389</param>
            <param name="username">Ilyane</param>
            <param name="ignore-cert">true</param>
        </connection>

    </authorize>

</user-mapping>" >> /etc/guacamole/user-mapping.xml


#Restart Tomcat 

systemctl restart tomcat9 guacd






















