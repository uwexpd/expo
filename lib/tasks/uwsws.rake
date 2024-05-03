require 'net/http'
require 'net/https'
require 'uri'
require 'openssl'

desc "Run UW SWS connection"
task :uwsws => :environment do	

	uri = URI.parse('https://ws.api.uw.edu/student/v5/person?student_system_key=1111558')

	# Create an SSL context and set the desired SSL/TLS version
	ssl_context = OpenSSL::SSL::SSLContext.new
	ssl_context.ssl_version = :TLSv1_2 # Set the desired version here

	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true	
	http.ssl_context = ssl_context if http.respond_to?(:ssl_context=)

	http.cert = OpenSSL::X509::Certificate.new(File.read("#{Rails.root}/config/certs/expo.uaa.washington.edu.ic.crt"))
	http.key = OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/config/certs/expo.uw.edu.key"))
	
	http.ca_file = "#{Rails.root}/config/certs/uwca.pem"
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE #VERIFY_NONE

	request = Net::HTTP::Get.new(uri.path)

  response = http.request(request)
  puts "HTTP Status Code: #{response.code}"
  puts "Response Body: #{response.body}"

end

task :tls_version => :environment do	
	require 'socket'

	# Create an SSL context
	context = OpenSSL::SSL::SSLContext.new

	# Establish a connection to a server (e.g., www.example.com)
	socket = TCPSocket.new('ws.api.uw.edu', 443)

	# Wrap the socket with SSL/TLS
	ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, context)
	ssl_socket.connect
	
	# Inspect SSL/TLS context
	puts "SSL/TLS Context Information:"
	ssl_socket.context.instance_variables.each do |ivar|
  value = ssl_socket.context.instance_variable_get(ivar)
  	puts "#{ivar}: #{value.inspect}"
	end

	# Close the connection
	ssl_socket.close

end

# How to Check the TLS Version in OS
# openssl s_client -connect ws.api.uw.edu:443 -tls1
# openssl ciphers -v | awk '{print $2}' | sort | uniq
# SSLv3
# openssl ciphers -vTLSv1.2


# Chech what openssl RVM ruby use:
# ruby -ropenssl -e "puts OpenSSL::OPENSSL_VERSION"
# OpenSSL 1.0.2k  26 Jan 2017 => EXPOVM server
# OpenSSL 1.0.2r  26 Feb 2019 => /usr/bin/openssl (LibreSSL 2.2.7)
# OpenSSL 1.0.2t  10 Sep 2019 => brew link openssl@1.0 in MAC

# Use curl to test
#curl --cert /Users/joshlin/Sites/expo/config/certs/expo.uaa.washington.edu.ic.crt --key /Users/joshlin/Sites/expo/config/certs/expo.uw.edu.key https://ws.api.uw.edu/student/v5/person?student_system_key=1111558

#=> Successfully get the search result


#  Use Faraday but still get 421
# 	require 'faraday'
# 	require 'faraday/request/multipart'
# 	require 'faraday/request/url_encoded'
# 	require 'faraday/response/raise_error'

# 	uri = 'https://ws.api.uw.edu/student/v5/person?student_system_key=1111558'
#   cert_path = "#{Rails.root}/config/certs/expo.uaa.washington.edu.ic.crt"
#   key_path = "#{Rails.root}/config/certs/expo.uw.edu.key"

#   connection = Faraday.new(:url => uri) do |faraday|
#     faraday.request :multipart
#     faraday.request :url_encoded
#     faraday.adapter Faraday.default_adapter
#     faraday.ssl do |ssl|
#       ssl.cert = OpenSSL::X509::Certificate.new(File.read(cert_path))
#       ssl.key = OpenSSL::PKey::RSA.new(File.read(key_path))
#       # Uncomment the next line if you want to disable SSL verification entirely (not recommended in production)
#       ssl.verify_mode = OpenSSL::SSL::VERIFY_NONE
#     end
#   end

#   response = connection.get

#   puts "HTTP Status Code: #{response.status}"
#   puts "Response Body: #{response.body}"

# How to switch OpenSSL version on Mac using Homebrew? => https://gist.github.com/zulhfreelancer/4a609f65dfc396e395e5d5713fb3dd0f
# UAAs-iMac:bin joshlin$ ls -al /usr/local/Cellar/openssl*
# /usr/local/Cellar/openssl@1.0:
# total 0
# drwxr-xr-x   3 joshlin  admin   102 May 11  2021 .
# drwxrwxr-x  94 joshlin  admin  3196 May 12  2021 ..
# drwxr-xr-x  12 joshlin  admin   408 May 11  2021 1.0.2t

# /usr/local/Cellar/openssl@1.1:
# total 0
# drwxr-xr-x   3 joshlin  staff   102 Mar 11 14:46 .
# drwxrwxr-x  94 joshlin  admin  3196 May 12  2021 ..
# drwxr-xr-x  13 joshlin  staff   442 May  3  2021 1.1.1k
# $ brew unlink openssl@1.1
# $ brew link openssl@1.0
# echo 'export PATH="/usr/local/opt/openssl@1.0/bin:$PATH"' >> /Users/joshlin/.bash_profile
# source ~/.bash_profile
# openssl version: OpenSSL 1.0.2t  10 Sep 2019

