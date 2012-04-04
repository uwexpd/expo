require 'net/https'

module REST
	class Connection
		def initialize(base_url, args = {})
			@base_url = base_url
			@username = args[:username]
			@password = args[:password]
			@debug_output_sink = $stderr if args[:debug_mode]
		end

		def request_get(resource, args = nil)
			request(resource, "get", args)
		end

		def request_post(resource, args = nil)
			request(resource, "post", args)
		end

		def request(resource, method = "get", args = nil)
			url = URI.join(@base_url, resource)

			if args
				# TODO: What about keys without value?
				url.query = args.map { |k,v| "%s=%s" % [URI.encode(k), URI.encode(v)] }.join("&")
			end

			case method
			when "get"
				req = Net::HTTP::Get.new(url.request_uri)
			when "post"
				req = Net::HTTP::Post.new(url.request_uri)
			end

			if @username and @password
				req.basic_auth(@username, @password)
			end

			http = Net::HTTP.new(url.host, url.port)
			http.use_ssl = (url.port == 443)
			http.set_debug_output @debug_output_sink if @debug_output_sink

			res = http.start() { |conn| conn.request(req) }
			res.body
		end
	end
end

class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end