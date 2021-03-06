require 'net/http' if RUBY_VERSION < '2'
require 'active_support/core_ext/object/to_query'

class HasOffersV3
  class Client

    attr_accessor :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def request(http_method, target, method, params)
      data = build_request_params(method, params)

      target_uri = "#{base_uri}/#{target}.json"

      if http_method == :post
        uri               = URI.parse(target_uri)
        http              = new_http(uri)
        raw_request       = Net::HTTP::Post.new(uri.request_uri)
        raw_request.body  = query_string data
      else # assume get
        uri               = URI.parse("#{target_uri}?#{query_string(data)}")
        http              = new_http(uri)
        raw_request       = Net::HTTP::Get.new(uri.request_uri)
      end

      logger.log_request(raw_request, uri)

      http_response = execute_request(http, raw_request)

      logger.log_response(http_response)

      Response.new(http_response, @configuration.json_driver)
    end

    def execute_request(net_http, raw_request)
      net_http.request raw_request
    end

    def build_request_params(method, params)
      params['Method'] = method
      {
        NetworkId: configuration.network_id,
        NetworkToken: configuration.api_key,
        api_key: configuration.api_key
      }.merge(params)
    end

    def query_string(data_hash)
      # Rails to_params adds an extra open close brackets to multi-dimensional array parameters which
      # hasoffers doesn't like, so the gsub here takes care of that.
      data_hash.to_param.gsub(/\[\]\[/,'[')
    end

    def new_http(uri)
      args = [uri.host, uri.port]
      args += [configuration.proxy_host, configuration.proxy_port] if configuration.proxy_host
      http = Net::HTTP.new(*args)
      http.use_ssl = true if uri.scheme == 'https'
      http.read_timeout = configuration.read_timeout
      http
    end

    def base_uri
      configuration.base_uri
    end

    private

    def logger
      configuration.http_logger
    end

  end
end
