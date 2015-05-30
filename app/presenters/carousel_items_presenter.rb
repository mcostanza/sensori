class CarouselItemsPresenter

	attr_accessor :models, :background_image_ids

	UNIQUE_BACKGROUND_IMAGES = Dir.glob(File.join(Rails.root, "app/assets/images/carousel-bg-*.jpg")).size

	def initialize(models, background_image_ids = self.randomized_background_image_ids)
		@models = models
		@background_image_ids = background_image_ids
	end

	def randomized_background_image_ids
		(1..UNIQUE_BACKGROUND_IMAGES).sort_by { rand }
	end

	def carousel_items
		@models.each_with_index.map do |model, index|
			background_image_index = index % @background_image_ids.size
			background_image_id = @background_image_ids[background_image_index]
			CarouselItem.new(model, background_image_id)
		end
	end

	class CarouselItem
		attr_accessor :model, :background_image_id
		
		def initialize(model, background_image_id)
			@model = model
			@background_image_id = background_image_id
		end
	end
end