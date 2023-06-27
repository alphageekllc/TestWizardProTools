require 'pathname'
require 'open-uri'

class SFREST
    class << self
      attr_accessor :username, :client_rest, :token, :sf_instance_data
      API_VERSION = 56.0
      AUTH_URL = 'https://login.salesforce.com' # OR https://test.salesforce.com

      def get_private_key_path
        ENV['SECRET_KEY_LOCATION']
      end

      def get_token_jwt(username, consumer_key)
        timestamp = (DateTime.now + Rational(2 * 60, 86_400)).strftime('%Q')
        jwt_header =
          {
            'alg' => 'RS256',
            'typ' => 'JWT'
          }
        jwt_claim =
          {
            'iss' => consumer_key,
            'sub' => username,
            'aud' => AUTH_URL,
            'exp' => timestamp
          }

        jwt_part1 = Base64.urlsafe_encode64(jwt_header.to_s)
        jwt_part2 = Base64.urlsafe_encode64(jwt_claim.to_s)
        key = OpenSSL::PKey::RSA.new(File.read(get_private_key_path))
        digest = OpenSSL::Digest.new('SHA256')
        jwt_signature = key.sign(digest, jwt_part1 + '.' + jwt_part2)
        jwt_signature = Base64.urlsafe_encode64(jwt_signature)
        jwt_assertion = jwt_part1+"."+jwt_part2+"."+jwt_signature

        headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
        body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=#{jwt_assertion}"
        uri = URI(AUTH_URL + '/services/oauth2/token')
        req = Net::HTTP::Post.new(uri, headers)
        req.body = body
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(req) }
        unless response.code == '200'
          ap response.body
          ap JSON.parse(response.body)
          ap response.class
          raise "failed to successfully retreive jwt token for user: '#{username}'. error_description = '#{JSON.parse(response.body)['error_description']}'. "
        end
        response_data = JSON.parse(response.body)

        puts "/services/oauth2/token response.code = #{response.code} : instance_url: #{response_data['instance_url']}".yellow
        @token = response_data['access_token']
        @sf_instance_data = response_data
        @sf_user = username
        @username = username
        @client_rest = response
        response['username'] = username
        response
      end

      def startTestByName(testName)
        payload = { 'testName' => testName }
        endpoint = '/services/apexrest/TWP/startTestByName/'
        net_post(endpoint, '', payload.to_json)
      end
      def startTestByTags(tags)
        payload = { 'tags' => tags }
        endpoint = '/services/apexrest/TWP/startTestByTags/'
        net_post(endpoint, '', payload.to_json)
      end
      def getTestStatus(testId)
        payload = { 'testId' => testId }
        endpoint = '/services/apexrest/TWP/getTestStatus/'
        net_post(endpoint, '', payload.to_json)
      end
      def getTestSuiteStatus(testId)
        payload = { 'testId' => testId }
        endpoint = '/services/apexrest/TWP/getTestSuiteStatus/'
        net_post(endpoint, '', payload.to_json)
      end

      def upload_local_test_file(file_path)
        upload_response = nil
        if !@token.nil?

          file_name = Pathname.new(file_path).basename
          file_data = File.read(file_path)

          puts 'File Contents:'.blue
          puts file_data

          # Base64 encode the file data
          b64_data = Base64.encode64(file_data)

          # create a ContentVersion object
          content_version = {
            'Title' => file_name,
            'PathOnClient' => file_path,
            'VersionData' => b64_data
          }

          endpoint        = "/services/data/v#{API_VERSION}/sobjects/ContentVersion"
          response        = net_post(endpoint, '', content_version.to_json)
          upload_response = JSON.parse(response.body)

          # if successful, the response will contain the new file's ID
          if upload_response.key?('id')
            puts "File uploaded successfully, ID: #{upload_response['id']}"
          else
            puts "Failed to upload file: #{upload_response['errors']}"
          end

        else
          puts "Failed to authenticate: #{auth_response['error_description']}"
        end
        upload_response
      end

      def upload_github_test_file(file_path)
        upload_response = nil
        if !@token.nil?

          # download file
          uri = URI(file_path)
          file_data = Net::HTTP.get(uri)
          file_name = File.basename(uri.path)

          puts 'File Contents:'.blue
          puts file_data

          # Base64 encode the file data
          b64_data = Base64.encode64(file_data)

          # create a ContentVersion object
          content_version = {
            'Title' => file_name,
            'PathOnClient' => file_path,
            'VersionData' => b64_data
          }

          endpoint        = "/services/data/v#{API_VERSION}/sobjects/ContentVersion"
          response        = net_post(endpoint, '', content_version.to_json)
          upload_response = JSON.parse(response.body)

          # if successful, the response will contain the new file's ID
          if upload_response.key?('id')
            puts "File uploaded successfully, ID: #{upload_response['id']}"
          else
            puts "Failed to upload file: #{upload_response['errors']}"
          end

        else
          puts "Failed to authenticate: #{auth_response['error_description']}"
        end
        upload_response
      end

      def list_organization_limits
        response = net_get("/services/data/v#{API_VERSION}/limits/", '', '', 360)
        JSON.parse(response.body) unless response.body.nil?
      end

      def list_available_resources
        response = net_get("/services/data/v#{API_VERSION}/", '', '', 360)
        JSON.parse(response.body) unless response.body.nil?
      end

      def list_objects
        response = net_get("/services/data/v#{API_VERSION}/sobjects/", '', '', 360)
        JSON.parse(response.body) unless response.body.nil?
      end

      def execute_apex(apex_body, max_retry_count = 4)
        success = false
        response_data = {}
        retry_count = 0
        while retry_count < max_retry_count
          begin
            uri = "/services/data/v#{API_VERSION}/tooling/executeAnonymous/?anonymousBody=#{CGI.escape(apex_body)}"
            STDOUT.puts "uri length: #{uri.size}" if uri.size > 16_000
            raise "uri size too long: expected < 16000 actual = #{uri.size}" if uri.size > 16_000

            response = net_get(uri, '', '', 360)
            ap response if response.class != Net::HTTPOK
            raise TestError, "Failed to successfully execute REST apex code: '#{apex_body}'. " if response.class != Net::HTTPOK

            response_data = JSON.parse(response.body)
            ap "response body: '#{response.body}' - #{response.class}" if response_data.nil?
            raise TestError, "Response is null: '#{response}' - '#{response.body}'" if response_data.nil?

            success = true
            break
          rescue RuntimeError => e
            STDOUT.puts "RuntimeError : #{e.class} - '#{e}' - thread size: #{ENV['THREAD_SIZE']}".blue
            raise e
          rescue StandardError => e
            retry_count += 1
            sleep 2
            STDOUT.puts "exception = #{e.class} - '#{e}' - #{response.class} - #{response} - retrying SFREST.execute_apex #{retry_count} ...  ".yellow
          end
        end
        raise TestFailed, "Failed to execute apex = '#{apex_body}'. " if success != true

        response_data
      end

      def describe(object)
        response = net_get("/services/data/v#{API_VERSION}/sobjects/#{object}/describe", '', '', 360)
        response = JSON.parse(response.body) unless response.body.nil?
        response
      end

      def net_patch(uri, headers, payload = '', timeout = 60)
        headers = { 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' } if headers.empty?
        uri = URI("#{@sf_instance_data['instance_url']}#{uri}") if uri.instance_of?(String)
        req = Net::HTTP::Patch.new(uri, headers)
        req.body = payload
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https', read_timeout: timeout, write_timeout: timeout) { |http| http.request(req) }
      end

      def net_put(uri, headers, payload = '', timeout = 60)
        headers = { 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' } if headers.empty?
        uri = URI("#{@sf_instance_data['instance_url']}#{uri}") if uri.instance_of?(String)
        req = Net::HTTP::Put.new(uri, headers)
        req.body = payload
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https', read_timeout: timeout) { |http| http.request(req) }
      end

      def update(sobject, id, data_table, max_retry_count = 4, msg = '')
        data = {}
        if data_table.instance_of?(Array)
          data_table.each do |d|
            data[d[0]] = d[1]
          end
        end
        data = data_table if data_table.instance_of?(Hash)
        response = nil
        success  = false
        retry_count = 0
        while retry_count < max_retry_count
          begin
            response = net_patch("/services/data/v#{API_VERSION}/sobjects/#{sobject}/#{id}", '', data.to_json, 360)
            ap response.body if response.class != Net::HTTPNoContent
            raise TestError, "Failed to successfully execute REST update: '#{response.class}' #{msg}. " if response.class != Net::HTTPNoContent

            success = true
            break
          rescue StandardError => e
            retry_count += 1
            sleep 2
            STDOUT.puts "exception = #{e.class} - '#{e}' - #{response.class} - #{response} - retrying SFREST.update #{retry_count} ...  ".yellow
          end
        end
        raise TestFailed, "Failed to execute SFREST update. Id: #{id} -  #{msg} " if success != true

        response = JSON.parse(response.body) unless response.body.nil?
        response
      end

      def net_get(uri, headers, payload = '', timeout = 360)
        headers   = { 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json' } if headers.empty?
        uri       = URI("#{@sf_instance_data['instance_url']}#{uri}") if uri.instance_of?(String)
        req       = Net::HTTP::Get.new(uri, headers)
        req.body  = payload
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https', read_timeout: timeout, write_timeout: timeout) { |http| http.request(req) }
      end

      def net_post(uri, headers, payload = '', timeout = 360)
        headers = { 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' } if headers.empty?
        uri = URI("#{@sf_instance_data['instance_url']}#{uri}") if uri.instance_of?(String)
        req = Net::HTTP::Post.new(uri, headers)
        req.body = payload
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https', read_timeout: timeout, write_timeout: timeout) { |http| http.request(req) }
      end

      def net_delete(uri, headers, timeout = 360)
        headers   = { 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json' } if headers.empty?
        uri       = URI("#{@sf_instance_data['instance_url']}#{uri}") if uri.instance_of?(String)
        req = Net::HTTP::Delete.new(uri, headers)
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https', read_timeout: timeout, write_timeout: timeout) { |http| http.request(req) }
      end

      def net_post_raw(url, headers, payload = '', timeout = 360)
        uri = URI(url)
        req = Net::HTTP::Post.new(uri, headers)
        req.body = payload
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https', read_timeout: timeout, write_timeout: timeout) { |http| http.request(req) }
      end

      def net_get_raw(uri, headers, payload = '', timeout = 360)
        headers = { 'Authorization' => "Bearer #{@token}" } if headers.empty?
        uri = URI(uri) if uri.instance_of?(String)
        req = Net::HTTP::Get.new(uri, headers)
        req.body = payload
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https', read_timeout: timeout, write_timeout: timeout) { |http| http.request(req) }
      end

      def read_all_objects
        sobjects_endpoint = "/services/data/v#{API_VERSION}/sobjects/"
        net_get(sobjects_endpoint, '', '')
      end

      def describe_sobject(sobject)
        net_get("/services/data/v#{API_VERSION}/sobjects/#{sobject}/describe/", '', '')
      end

    end
  end

