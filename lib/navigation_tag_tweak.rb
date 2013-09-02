module NavigationTagTweak
  include Radiant::Taggable
  
  desc %{
    Renders a list of links specified in the @paths@ attribute according to three
    states:

    * @normal@ specifies the normal state for the link
    * @here@ specifies the state of the link when the path matches the current
       page's PATH
    * @selected@ specifies the state of the link when the current page matches
       is a child of the specified path
    # @if_last@ renders its contents within a @normal@, @here@ or
      @selected@ tag if the item is the last in the navigation elements
    # @if_first@ renders its contents within a @normal@, @here@ or
      @selected@ tag if the item is the first in the navigation elements

    The @between@ tag specifies what should be inserted in between each of the links.

    *Usage:*

    <pre><code><r:navigation paths="[Title: path | Title: path | ...]">
      <r:normal><a href="<r:path />"><r:title /></a></r:normal>
      <r:here><strong><r:title /></strong></r:here>
      <r:selected><strong><a href="<r:path />"><r:title /></a></strong></r:selected>
      <r:between> | </r:between>
    </r:navigation>
    </code></pre>
  }
  tag 'navigation' do |tag|
    hash = tag.locals.navigation = {}
    tag.expand
    raise TagError.new("`navigation' tag must include a `normal' tag") unless hash.has_key? :normal
    result = []
    pairs = (tag.attr['paths']||hash[:paths].call).to_s.split('|').map do |pair|
      parts = pair.split(':')
      value = parts.pop
      key = parts.join(':')
      [key.strip, value.strip]
    end
    pairs.each_with_index do |(title, path), i|
      compare_path = remove_trailing_slash(path)
      page_path = remove_trailing_slash(self.path)
      hash[:title] = title
      hash[:path] = path
      tag.locals.first_child = i == 0
      tag.locals.last_child = i == pairs.length - 1
      case page_path
      when compare_path
        result << (hash[:here] || hash[:selected] || hash[:normal]).call
      when Regexp.compile( '^' + Regexp.quote(path))
        result << (hash[:selected] || hash[:normal]).call
      else
        result << hash[:normal].call
      end
    end
    between = hash.has_key?(:between) ? hash[:between].call : ' '
    result.reject { |i| i.blank? }.join(between)
  end
  [:normal, :here, :selected, :between, :paths].each do |symbol|
    tag "navigation:#{symbol}" do |tag|
      hash = tag.locals.navigation
      hash[symbol] = tag.block
    end
  end
end