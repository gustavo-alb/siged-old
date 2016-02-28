  module ActiveSupport
    module Cache
      class Store
        def fetch(name, options = nil)
          if block_given?
            yield
          end
        end
      end
    end
  end