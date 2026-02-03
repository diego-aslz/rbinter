# frozen_string_literal: true

require "faraday"
require "faraday/net_http"
require "json"
require "openssl"

module Rbinter
  class Client
    BASE_URL = "https://cdpj.partners.bancointer.com.br"
    SANDBOX_URL = "https://cdpj.partners.bancointer.com.br" # Same host, usually different credentials or account?
    # Actually Inter has a sandbox: https://cdpj-sandbox.partners.bancointer.com.br 
    # But let's verify. I'll stick to the passed BASE_URL or default to prod.
    
    attr_reader :access_token, :token_expires_at

    def initialize
      @config = Rbinter.configuration
      validate_config!
    end

    def create_boleto(boleto_params)
      ensure_authenticated!

      response = connection.post("/cobranca/v2/boletos") do |req|
        req.headers["Authorization"] = "Bearer #{@access_token}"
        req.headers["Content-Type"] = "application/json"
        req.body = boleto_params.to_json
      end

      handle_response(response)
    end

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |conn|
        conn.adapter :net_http
        
        # SSL Config
        conn.ssl.client_cert = load_cert(@config.certificate)
        conn.ssl.client_key = load_key(@config.private_key)
        conn.ssl.verify = true
      end
    end

    def ensure_authenticated!
      return if @access_token && !token_expired?

      authenticate!
    end

    def authenticate!
      response = connection.post("/oauth/v2/token") do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = URI.encode_www_form({
          client_id: @config.client_id,
          client_secret: @config.client_secret,
          scope: "boleto-cobranca.read boleto-cobranca.write",
          grant_type: "client_credentials"
        })
      end

      data = handle_response(response)
      @access_token = data["access_token"]
      @token_expires_at = Time.now + data["expires_in"].to_i
    end

    def token_expired?
      return true unless @token_expires_at
      Time.now >= @token_expires_at - 60 # Buffer
    end

    def handle_response(response)
      case response.status
      when 200..299
        JSON.parse(response.body)
      when 401
        raise Rbinter::AuthenticationError, "Unauthorized: #{response.body}"
      else
        raise Rbinter::ApiError, "API Error #{response.status}: #{response.body}"
      end
    end

    def validate_config!
      raise Rbinter::Error, "Configuration missing" unless @config
      raise Rbinter::Error, "Client ID missing" unless @config.client_id
      raise Rbinter::Error, "Client Secret missing" unless @config.client_secret
      raise Rbinter::Error, "Certificate missing" unless @config.certificate
      raise Rbinter::Error, "Private Key missing" unless @config.private_key
    end

    def load_cert(cert)
      return cert if cert.is_a?(OpenSSL::X509::Certificate)
      OpenSSL::X509::Certificate.new(File.exist?(cert) ? File.read(cert) : cert)
    rescue
      raise Rbinter::Error, "Invalid Certificate"
    end

    def load_key(key)
      return key if key.is_a?(OpenSSL::PKey::RSA)
      OpenSSL::PKey::RSA.new(File.exist?(key) ? File.read(key) : key)
    rescue
      raise Rbinter::Error, "Invalid Private Key"
    end
  end
end
