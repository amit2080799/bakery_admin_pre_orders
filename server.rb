require 'socket'
require 'yaml'
require './file_reader'
require './url_parser'
require 'cgi'
require 'digest'

configurations = YAML.load_file('config/config.yaml')

class Server
  attr_accessor :response, :socket, :request, :session, :params

  def initialize(port)
    @response = "HTTP/1.1 200 OK \r\n Content-Type: text/plain \r\n\r\n"
    @socket = TCPServer.new port
    @session = nil
    @params = {}
  end

  def serve
    while self.session = socket.accept
      self.request = session.gets
      puts "\n \n Request: \n \n #{request} \n \n"
      path = request.split(' ')[1]
      if path == '/'
        html_contents = read_html_contents('views/index.html')
      elsif path == '/login'
        self.params = parse_params
        puts params['password']
        encryped_password = Digest::SHA256.hexdigest(params['password'])
        puts encryped_password
      end

      session.puts "#{response} #{html_contents}"
      session.close
    end
  end

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
end

port = configurations['server'].first['port']
server = Server.new(port).serve
