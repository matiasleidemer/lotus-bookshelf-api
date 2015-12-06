module Bookshelf
  module API
    class Repository
      def initialize
        @connection = Redis.new(url: ENV['REDIS_URL'])
      end

      def clear
        @connection.flushall
      end

      def create(collection, *records)
        records = Array(records).flatten

        counter = "_#{ collection }:id"
        @connection.setnx(counter, 0)

        Array(records).each do |record|
          id = @connection.incr(counter)
          @connection.mapped_hmset("#{ collection }:#{ id }", record.merge(id: id))
        end
      end

      def all(collection)
        @connection.keys("#{ collection }:*").each_with_object([]) do |key, result|
          result << @connection.hgetall(key)
        end
      end
    end
  end
end
