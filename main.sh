#!/usr/bin/env bash
# create environment variables
createEnv(){
	# add enviroment variables to OS
	source .env
}

# Ouput messages to terminal
output(){
	echo -e "$2 ################################ $1 ################################## $(tput sgr0)"
}

# Install node.js
installNode(){
	output "installing node.js" $GREEN
	sudo apt-get update
	curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
	sudo bash nodesource_setup.sh
	sudo apt-get install -y nodejs
	output "Node.js installed successfully" $GREEN
}

# Clone the repository
cloneRepository(){
	output "Checking if repository exists..." $GREEN
	if [ ! -d $REPOSITORY_FOLDER ]
		then
			output "Cloning repository..." $GREEN
			git clone -b $GIT_BRANCH $GIT_REPO
			output "Repository already exists..." $RED
			output "Removing repository..." $GREEN
			sudo rm -r $REPOSITORY_FOLDER
			output "Cloning repository..." $GREEN
			git clone -b $GIT_BRANCH $GIT_REPO
	fi
	output "Repository cloned successfully" $GREEN
}

# Setup the project
setupProject(){
	output "installing node modules" $GREEN
	cd $REPOSITORY_FOLDER
	sudo npm install -y
	sudo npm audit fix --force
	sudo npm run build
	output "successfully installed node modules" $GREEN
}

# Setup nginx
setupNginx(){
	output "installing nginx" $GREEN
	# Install nginx
	sudo apt-get install nginx -y

	output "setting up reverse proxy" $GREEN
	# Setup reverse proxy with nginx
	nginxScript="server {
    listen       80;
    server_name  $SITE "www.$SITE";

    location / {
      proxy_pass      http://127.0.0.1:8080;
    }
  }"

	# Remove the default nginx proxy script
	if [ -f $SITES_AVAILABLE/default ]; then
    sudo rm $SITES_AVAILABLE/default
	fi

	if [ -f $SITES_ENABLED/default ]; then
    sudo rm $SITES_ENABLED/default
	fi

	# Create an nginx reverse proxy script
	sudo echo ${nginxScript} >> ${SITES_AVAILABLE_CONFIG}

	# Create a symlink for the sites enabled and the sites available script
	sudo ln -s $SITES_AVAILABLE_CONFIG $SITES_ENABLED_CONFIG

	sudo service nginx restart

	output "successfully setup nginx" $GREEN
}

setupSSL(){
	output "installing and setting up SSL" $GREEN
	site=$SITE
	email=$EMAIL
	sudo apt-get update -y

	# Get and install the SSL certificate
	sudo apt-get install software-properties-common -y
	sudo add-apt-repository ppa:certbot/certbot -y
	sudo apt-get update -y
	sudo apt-get install python-certbot-nginx -y

	# Configure the ngix proxy file to use the SSL certificate
	sudo certbot --nginx -n --agree-tos --email $EMAIL --redirect --expand -d $SITE -d "www.$SITE"

	output "successfuly setup SSL" $GREEN
}

# Create a service to run the app in the backgroud using systemctl
createAppService(){
	output "Creating a service for the app..." $GREEN
	sudo bash -c "cat > /etc/systemd/system/selene.service <<EOF
		[Unit]
		Description=Selene ah Service - Service to start the app
		After=network.target

		[Service]
		ExecStart=/usr/bin/node /home/ubuntu/$REPOSITORY_FOLDER/server.js
		Restart=on-failure
		Type=simple
		User=ubuntu

		[Install]
		WantedBy=multi-user.target"
}

# start the app using the service that has been created
startAppService(){
	output "Starting the app service..." $GREEN
	sudo systemctl daemon-reload
  sudo systemctl start selene.service
  sudo systemctl enable selene.service
}


# Function to deploy the project
main(){
	createEnv
	setupNginx
	installNode
	cloneRepository
	setupProject
	setupSSL
	createAppService
	startAppService
	output "Project deployed" $GREEN
}

main
