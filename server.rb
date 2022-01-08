require 'socket'
require 'yaml'
require './file_reader'

configurations = YAML.load_file('config/config.yaml')

class Server
  attr_accessor :response, :socket

  def initialize(port)
    @response = "HTTP/1.1 200 OK \r\n Content-Type: text/plain \r\n\r\n"
    @socket = TCPServer.new port
  end

  def serve
    while session = socket.accept
      request = session.gets
      html_contents = read_html_contents

      session.puts "#{response} #{html_contents}"
      session.close
    end
  end

  def read_html_contents
    file = FileReader.new('views/index.html')
    html_contents = file.open.read
    file.close
    html_contents
  end
end

port = configurations['server'].first['port']
server = Server.new(port).serve
