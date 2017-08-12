# Simple Ruby Login installer.
### Chef cookbook consisting of one recipe, that installs [simple_ruby_login](https://github.com/AnvarSh1/simple_ruby_login), all its dependencies, and launches web server. 

*At first, I planned to use separate cookbooks and recipes for separate installations and operations - but that became unnecessary complex, and while using bash script resource can be seen as "cheating" - it is in fact easier and quicker method for this particular purposes. While code itself is pretty much self-explanatory, let's look through separate script parts to see what each of them does:*

Main reason of separating the whole script in several blocks is because bash stops executing the rest of the script after `apt-get install -y` - so, starting next, seperate script solves this issue.

This lines at the start of each block descripe script executing user and directory:
```
user "root"
cwd "/tmp"
```


This block installs all main dependencies for Ruby (after `apt-get update` of course):

```
bash "installstuff" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    apt-get update
    apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs
    EOH
end
```


Here, we install rbenv, bundler and prepare to rails installation:

```
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
```

Now, let's install rails, after that we install mysql server with pre-defined root db password:

```
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
```

Install rest of mysql:

```
bash "mysqlcllib" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    apt-get install -y mysql-client libmysqlclient-dev
    EOH
end
```


And finally we clone the rubby app, install all gem file dependencies, create and migrate databases and finally launch rails server:
```
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
    rails s &
    EOH
end
```

Web app is now accessible at http://localhost:3000 (or, of course, obviously, http://yourwebsitenameoripaddress:3000)
