class HttpartyService
  def initialize(url:, headers: {}, timeout: 10)
    @url = url
    @headers = headers
    @timeout = timeout
  end

  def get
    HTTParty.get(@url, headers: @headers, timeout: @timeout)
  rescue Exception => e
    puts "Error: #{e}"
    return { error: e }
  end
end
