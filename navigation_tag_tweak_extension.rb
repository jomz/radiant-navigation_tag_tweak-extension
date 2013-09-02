require "radiant-navigation_tag_tweak-extension"

class NavigationTagTweakExtension < Radiant::Extension
  version     RadiantNavigationTagTweakExtension::VERSION
  description RadiantNavigationTagTweakExtension::DESCRIPTION
  url         RadiantNavigationTagTweakExtension::URL

  # See your config/routes.rb file in this extension to define custom routes

  extension_config do |config|
    # config is the Radiant.configuration object
  end

  def activate
    Page.send :include, NavigationTagTweak
  end
end
