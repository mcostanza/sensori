module HomeHelper
  def cover_image
    @cover_image_ids ||= (1..8).to_a
    cover_image_id = @cover_image_ids.sample
    @cover_image_ids.delete(cover_image_id)
    "carousel-bg-#{cover_image_id}.jpg"
  end

  def carousel_link(item)
    item.respond_to?(:link) ? item.link : item
  end

  def carousel_link_options(item)
    return {} unless item.respond_to?(:link)
    item.link.to_s.match(/sensoricollective\.com/i) ? { } : { :target => '_blank' }
  end
end
