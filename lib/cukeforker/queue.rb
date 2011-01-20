module CukeForker
  class Queue
    class Error < StandardError; end

    attr_reader :max

    def initialize(max)
      @max = max
      @items = []
    end

    def add(obj)
      raise Error, "queue is full" if full?
      @items << obj
    end
    alias_method :<<, :add

    def remove(obj)
      @items.delete obj
    end

    def size
      @items.size
    end

    def empty?
      size == 0
    end

    def full?
      size == max
    end

  end # Queue
end # CukeForker
