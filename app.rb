require 'json'
require 'redis'
require 'lotus/router'
require 'lotus/controller'

module Bookshelf
  module API
    require_relative 'repository'

    Lotus::Controller.configure do
      handle_exceptions ENV['RACK_ENV'] == 'production'

      default_request_format  :json
      default_response_format :json

      prepare do
        include Controllers::Authentication
        accept :json
      end
    end

    class Application
      def initialize
        @router = Lotus::Router.new(
          namespace: Bookshelf::API::Controllers,
          parsers: [:json],
          &Proc.new { eval(File.read('config/routes.rb')) }
        )
      end

      def call(env)
        @router.call(env)
      end
    end

    module Controllers
      module Authentication
        def self.included(action)
          action.class_eval do
            before :authenticate!
          end
        end

        private

        def authenticate!
          authenticated? or halt(401)
        end

        def authenticated?
          true
        end
      end

      require_relative './controllers/books'
    end
  end
end
