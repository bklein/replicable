module Replicable
  class Railtie < Rails::Railtie
    initializer "replicable.initialize" do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, Replicable
      end
    end
  end
end
