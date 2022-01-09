class UrlParser
  attr_reader :session

  def initialize(session)
    @session = session
  end

  def parse
    headers = {}
    while line = session.gets.split(' ', 2)              # Collect HTTP headers
      break if line[0] == ""                            # Blank line means no more headers
      headers[line[0].chop] = line[1].strip             # Hash headers by type
    end
    data = session.read(headers["Content-Length"].to_i)  # Read the POST data as specified in the header
    CGI.unescape(data)
  end
end
