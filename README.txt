Installing Drupal 8 with Composer and deploying with Capistrano

This guide will walk you through installing Drupal with Composer, and deploying the install to a remote server using Capistrano

First of all create an empty repo and clone it on your local machine.
For this example we will be using a repo hosting on BitBucket but it should be more or less the same for any service.

cd project_directory
git init
git remote add origin https://EpiphronLtd@bitbucket.org/Company/reponame.git

 Next download composer.phar to your project directory

curl -sS https://getcomposer.org/installer | php

Use composer to install Drupal

php composer.phar create-project drupal-composer/drupal-project:8.x-dev

Move the project files out of the created' installer directory and remove it

mv drupal-project/* .
rm -r drupal-project

Configure your silverstripe install by visiting /core/install.php

If its not installed, install Capistrano and Capdrupal

gem install capistrano
gem install capdrupal

Setup Capistrano within your project directory

cap install

Setup your Capistrano config files

Set config/deploy.rb

lock '3.2.1'
set :application, 'myapp'
set :repo_url, 'git@bitbucket.org:Company/repo'
set :user, "www-data"
set :group, "www-data"
set :runner_group, "www-data"
set :domain, "http://sitedomain"
set :deploy_to, "/var/www"
set :linked_files, %w{web/sites/default/settings.php}
set :app_path, "drupal"
set :shared_children, ['drupal/sites/default/files']
set :shared_files, ['drupal/sites/default/settings.php'] 
set :download_drush, true
set :scm, "git"
set :branch, "master"
namespace :deploy do
after :finishing, 'drupal:composer:update'
after :finishing, 'drupal:server:chowndir'
end

Set config/deploy/staging.rb (Replace with your project/server details)

role :web, %w{root@server}
server 'server', user: 'serveruser', roles: %w{web}

Set lib/capistrano/tasks/silverstripe.rake (Indent as needed)

namespace :drupal do
namespace :composer do
desc 'Run Composer update'
task :update do
on roles(:web) do
within release_path do
execute :php, "-d allow_url_fopen=on composer.phar update"
end
end
end
end
namespace :server do
desc 'Run Chown dir'
task :chowndir do
on roles(:web) do
within fetch(:root_dir) do
execute :chown, "-R www-data:www-data /var/www"
end
end
end
end
end

Push changes to repo

git add *
git commit -m "First commit"
git push origin master

Make sure you have set up ssh key access to your staging server

ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub | ssh root@stagingserveraddress 'cat >> ~/.ssh/authorized_keys'

You will also need to add the the public key from both your development machine and your staging server, to your repo.
Refer to your repository host on how to do this.

Run a cold deploy to setup the file structure

cap staging deploy

 This will fail almost instantly citing a missing shared file. Log into your staging server and create the missing files, filling out the details as particular to your hosting environment.

ssh root@stagingserveraddress
cd /var/www

nano shared/web/sites/default/settings.php
You simply need to create this file as it will be filled in later

Once you have updated the shared files, run the deploy script again from your development machine

cap staging deploy
