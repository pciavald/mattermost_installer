USER="mmuser"
PASS="password"
IP="127.0.0.1"
PORT="8065"
LOGIN=`whoami`
VERSION="3.3.0"

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y postgresql postgresql-contrib

sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addressess = '*'/" /etc/postgresql/9.3/main/postgresql.conf
sudo sed -i "/^# IPv4 local connections:/a host all all $IP/32 md5" /etc/postgresql/9.3/main/pg_hba.conf
sudo /etc/init.d/postgresql reload
echo "\
CREATE DATABASE mattermost;
CREATE USER $USER WITH PASSWORD '$PASS';
GRANT ALL PRIVILEGES ON DATABASE mattermost to $USER;" | sudo -u postgres psql
#sudo -u postgres psql --host=$IP --dbname=mattermost --username=$USER --password

sudo mkdir -p /mattermost/data
sudo chown -R $LOGIN /mattermost

wget https://releases.mattermost.com/$VERSION/mattermost-team-$VERSION-linux-amd64.tar.gz
tar -xf mattermost-team-$VERSION-linux-amd64.tar.gz
sed -i 's/"DriverName": "mysql"/"DriverName": "postgres"/' mattermost/config/config.json
FINDDATASRC="mmuser:mostest@tcp(dockerhost:3306)\/mattermost_test?charset=utf8mb4,utf8"
DATASRC="postgres:\/\/$USER:$PASS@$IP:5432\/mattermost?sslmode=disable\&connect_timeout=10"
sed -i "s/$FINDDATASRC/$DATASRC/" mattermost/config/config.json
cd mattermost
./bin/platform &
firefox localhost:8065 &
