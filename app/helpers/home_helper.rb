module HomeHelper
  def carousel_link(item)
    item.respond_to?(:link) ? item.link : item
  end

  def carousel_link_options(item)
    return {} unless item.respond_to?(:link)
    item.link.to_s.match(/sensoricollective\.com/i) ? { } : { target: '_blank' }
  end
end
