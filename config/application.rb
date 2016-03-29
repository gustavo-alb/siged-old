# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'
ActiveSupport::Deprecation.silenced = true


# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default,Rails.env) if defined?(Bundler)
module Siged20
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Brasilia'
    config.active_record.default_timezone = 'Brasilia'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = [:'pt-BR']
    config.i18n.default_locale = :'pt-BR'
    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    config.assets.enabled = true
    config.active_record.whitelist_attributes = false


    config.generators do |g|
      g.stylesheets false
    end
  end
  #require "#{Rails.root}/lib/find_or_create_by.rb"
  class String
    def rtrim(char)
      dump.rtrim!(char)
    end

    def rtrim!(char)
      gsub!(/#{Regexp.escape(char)}+$/, '')
    end

    def ltrim(char)
      dump.ltrim!(char)
    end

    def ltrim!(char)
      gsub!(/^#{Regexp.escape(char)}+/, '')
    end

  end
  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    error_style = ""
    if html_tag =~ /<(input|textarea|select)[^>]+class=/
      first_whitespace = html_tag =~ /\s/
      html_tag[first_whitespace] = " class='#{error_style}' "
      html_tag+="<br/><font color=red><small><b>Erro:</b> #{instance.method_name.capitalize} #{instance.error_message} </small></font>".html_safe
    elsif html_tag =~ /<(input|textarea|select)/
      first_whitespace = html_tag =~ /\s/
      html_tag[first_whitespace] = " class='#{error_style}' "
      html_tag+="<br/><font color=red><small><b>Erro:</b> #{instance.method_name.capitalize} #{instance.error_message} </small></font>".html_safe
    end
    html_tag
  end



end
