# frozen_string_literal: true

require_relative "rbinter/version"
require_relative "rbinter/client"

module Rbinter
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class ApiError < Error; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :client_id, :client_secret, :certificate, :private_key, :environment

    def initialize
      @environment = :production # or :sandbox
    end
  end
end
