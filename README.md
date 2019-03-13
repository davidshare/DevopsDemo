# DevopsDemo
A simple bash script to deploy a react project to an AWS instance

## How to deploy
* Create an AWS free tier account
* Create an AWS instance using the free tier resources and download your keypair file
* SSH into the AWS instance you created and clone this repository in the root directory
* Copy your keypair file into the root directory of the repository
* Get a domain name (you can get a free one from www.freenom.com)
* Using the .env.sample file, specify your environment variables in a .env file - make sure to include your domain name and react app repository
* Reserve an elastic ip address on AWS
* Configure route 53 using your domain name and the IP address you reserved
* On your domain name accout, configure your DNS setting with the dns addresses provided by route 53
* Switch to the root directory of the project and run the following command: "bash main.sh"
* On your browser, type your domain name to access your app

