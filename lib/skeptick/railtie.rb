module Skeptick
  class Railtie < Rails::Railtie
    initializer "skeptick.configure_rails_initialization" do
      Skeptick.logger  = Rails.logger
      Skeptick.cd_path = Rails.root
    end
  end
end
