#Update 
#Update 
apt update
apt install make 

#Install Guacamole on Debian 10
apt install -y build-essential libcairo2-dev libturbojpeg0 libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev libssl-dev libvorbis-dev libwebp-dev libpulse-dev

#Install FreeRDP libraries enable support for RDP via Guacamole

# Install a specifiy version of Guacamole
VER=1.3.0
wget https://downloads.apache.org/guacamole/$VER/source/guacamole-server-$VER.tar.gz
apt update
tar xzf guacamole-server-1.3.0.tar.gz

cd guacamole-server-1.3.0/


./configure --with-init-dir=/etc/init.d
make
make install

ldconfig

systemctl enable guacd

systemctl start guacd
systemctl status guacd

apt install tomcat9 tomcat9-admin tomcat9-common tomcat9-user -y


wget https://raw.githubusercontent.com/IlyaneDelor/Linux_script/main/bdd_guac.sql


mkdir /etc/guacamole
VER=1.3.0
wget https://downloads.apache.org/guacamole/$VER/binary/guacamole-$VER.war -O /etc/guacamole/guacamole.war
ln -s /etc/guacamole/guacamole.war /var/lib/tomcat9/webapps/


systemctl start tomcat
systemctl enable tomcat
systemctl restart guacd
systemctl status tomcat



mkdir /etc/guacamole/{extensions,lib}
echo "GUACAMOLE_HOME=/etc/guacamole"  /etc/default/tomcat9
apt install mariadb-server mariadb-client

mysql -h "localhost" -u "root" < bdd_guac.sql

ufw allow 8080/tcp
ufw reload


echo "<user-mapping>
    <authorize 
            username="guacadmin"
            password="guacadmin">

        <connection name="Ubuntu20.04-Focal-Fossa">
            <protocol>ssh</protocol>
            <param name="hostname">192.168.1.17</param>
            <param name="port">22</param>
            <param name="username">root</param>
        </connection>
        <connection name="Windows Server">
            <protocol>rdp</protocol>
            <param name="hostname">173.82.187.22</param>
            <param name="port">3389</param>
        </connection>
    </authorize>
</user-mapping>" >> /etc/guacamole/user-mapping.xml


wget http://apache.mirror.digionline.de/guacamole/1.3.0/binary/guacamole-auth-jdbc-1.3.0.tar.gz

tar vfx guacamole-auth-jdbc-1.3.0.tar.gz
cat guacamole-auth-jdbc-1.3.0/mysql/schema/*.sql |  mysql guacamole_db
cp guacamole-auth-jdbc-1.3.0/mysql/guacamole-auth-jdbc-mysql-1.3.0.jar /etc/guacamole/extensions/

wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.13.tar.gz
tar xvzf mysql-connector-java-8.0.13.tar.gz

cp mysql-connector-java-8.0.13/mysql-connector-java-8.0.13.jar /etc/guacamole/lib/

echo "# Hostname and Guacamole server port
guacd-hostname: localhost
guacd-port: 4822
# MySQL properties
mysql-hostname: localhost
mysql-port: 3306
mysql-database: guacamole_db
mysql-username: guacamole_user
mysql-password: password
" >> /etc/guacamole/guacamole.properties

ln -s /etc/guacamole /usr/share/tomcat9/.guacamole

systemctl restart tomcat9


systemctl restart guacd




















