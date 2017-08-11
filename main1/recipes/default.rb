#
# Cookbook:: main1
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

bash "installstuff" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    apt-get update
    apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs
    EOH
end


bash "rbenvandstuff" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    exec $SHELL
    rbenv install 2.4.0
    rbenv global 2.4.0
    gem install bundler
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    apt-get install -y nodejs
    EOH
end


bash "mostlymysql" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    gem install rails -v 5.1.1
    rbenv rehash
    debconf-set-selections <<< 'mysql-server mysql-server/root_password password p'
    debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password p'
    apt-get install -y mysql-server
    EOH
end


bash "mysqlcllib" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    apt-get install -y mysql-client libmysqlclient-dev
    EOH
end


bash "railsappandstuff" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    mkdir ~/rails_apps
    cd ~/rails_apps
    git clone https://github.com/AnvarSh1/simple_ruby_login.git
    cd simple_ruby_login
    bundle install
    rake db:create
    rake db:migrate
    rails s
    echo "done!"
    EOH
end
