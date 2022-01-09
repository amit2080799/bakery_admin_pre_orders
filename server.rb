require 'socket'
require 'yaml'
require './file_reader'
require './url_parser'
require './database'
require 'cgi'
require 'digest'

configurations = YAML.load_file('config/config.yml')

class Server
  attr_accessor :response, :socket, :request, :session, :params, :db_conn

  def initialize(port)
    @socket = TCPServer.new port
    @session = nil
    @params = {}
    @db_conn = Database.new.connect
  end

  def serve
    while self.session = socket.accept
      begin
        self.response = "HTTP/1.1 200 OK \r\n Content-Type: text/plain \r\n\r\n"
        self.request = session.gets
        puts "\n \n Request: \n \n #{request} \n \n"
        path = request.split(' ')[1]
        if path == '/'
          html_contents = read_html_contents('views/index.html')
        elsif path == '/login'
          self.params = parse_params
          encryped_password = encrypt_password
          query = "Select * from users where email='#{params['username']}' and password='#{encryped_password}'"
          puts query
          result = db_conn.query(query).each(:as => :array)
          html_contents += "<p> Login Successful </p>" if result.size > 0
        end

        session.puts "#{response} #{html_contents}"
        session.close
      rescue => e
        puts "Exception: #{e}"
      end
    end
  end

  private

  def read_html_contents(file_path)
    file = FileReader.new(file_path)
    html_contents = file.open.read
    file.close
    html_contents
  end

  def parse_params
    params = {}
    parsed_qs = UrlParser.new(session).parse
    parsed_qs.split('&').each { |qe| params[qe.split('=').first] = qe.split('=')[1] }
    params
  end

  def encrypt_password
    Digest::SHA256.hexdigest(params['password'])
  end
end

port = configurations['server'].first['port']
server = Server.new(port).serve
