module RequestStore
  class Railtie < ::Rails::Railtie
    initializer "request_store.insert_middleware" do |app|
      if ActionDispatch.const_defined? :RequestId
        app.config.middleware.insert_after ActionDispatch::RequestId, RequestStore::Middleware
      else
        app.config.middleware.insert_after Rack::MethodOverride, RequestStore::Middleware
      end

      if ActiveSupport.const_defined?(:Reloader) && ActiveSupport::Reloader.respond_to?(:to_complete)
        ActiveSupport::Reloader.to_complete do
          RequestStore.clear!
        end
      elsif ActionDispatch.const_defined?(:Reloader) && ActionDispatch::Reloader.respond_to?(:to_cleanup)
        ActionDispatch::Reloader.to_cleanup do
          RequestStore.clear!
        end
      end
    rescue FrozenError
      # This can happen when running RSpec + Rails 6.1 - see
      # https://github.com/bugsnag/bugsnag-ruby/commit/a530de77e65379b987f2ff68c96e21969a059767
    end
  end
end
