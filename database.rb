require 'mysql2'
require 'pry'

class Database
  attr_reader :db_name, :host, :username, :password

  def initialize
    YAML.load_file('config/database.yml')['development'].each do |config|
      @db_name = config['database'] if config['database']
      @host = config['host'] if config['host']
      @username = config['user'] if config['user']
      @password = config['password'] if config['password']
    end
  end

  def connect
    Mysql2::Client.new(
      :host => host,
      :username => username,
      :password => password,
      :database => db_name
    )
  end
end
