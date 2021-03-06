class Place < ActiveRecord::Base

  include TextSearchable

  mount_uploader :image, ImageUploader

  attr_accessor :distance

  has_many :items
  has_many :categories, :order => "position ASC"
  has_and_belongs_to_many :cuisines
  belongs_to :locality

  CUISINES = CUISINE_TO_CATEGORIES.keys

  serialize :old_cuisines, Array
  validates_presence_of :name, :locality_id, :latitude, :longitude, :short_address

  after_initialize do |place|
    place.veg = false unless place.veg
  end

  after_create :populate_categories_and_tags
  #geocoded_by :short_address   # can also be an IP address
  #after_validation :geocode

  scope :enabled, where(:disabled => false)

  searchable do
    text :name, boost: 5
    text :short_address
    string :city
    string :locality_name
    latlon(:location) { Sunspot::Util::Coordinates.new(latitude, longitude) }
    integer :cuisine_ids, multiple: true
  end

  # Use like so: Place.search { with(:location).in_radius(17.3916,78.4658,1)}

  def self.sorted
    order('name asc')
  end

  def populate_categories_and_tags
    categories = []

    self.cuisines.each do |cuisine|
      categories =  CUISINE_TO_CATEGORIES[cuisine.name]
      categories.each_with_index do |(category, tags), index|
        Category.create(:place => self, :name => category, :tags => (tags || []).join(","), :position => index*5)
      end
    end
  end

  def tags
    categories.collect(&:tags_list).compact.flatten.uniq
  end

  def ordered_items
    categorized_items = items.select { |i| i.category.present? }
    ret = categorized_items.group_by(&:category_id).sort_by { |cat, items| Category.find(cat).position }
    ret.each do |cat_id, items|
      items.sort! { |a, b| b.total_votes <=> a.total_votes }
    end
    ret
  end

  def populated_categories
    categories.find(ordered_items.collect { |e| e.first })
  end

  def top n
    items.sort { |a, b| b.total_votes <=> a.total_votes }[0..n-1]
  end

  def winner_list
    winner_list = []

    ordered_items.each do |cat_id, items|
      winner_list << [cat_id, [items.first]]
    end

    winner_list
  end

  def set_default_category
    cat = Category.find_or_create_by(name: 'Uncategorized', place_id: id)
    cat.update_attribute(:position, 50)
    cat
  end

  def kind
    self.class.name
  end

  def self.custom_search query, extra={}
    city = extra[:city]
    search = Place.search do
      fulltext query
      with(:city, city)
      paginate(:page => 1, :per_page => 3)
    end
    search.results || []
  end

  def self.new_custom_search(lat, lon, extra={})
    extra ||= {}
    city = extra[:city]
    radius = extra[:radius] || 5
    locality = extra[:locality]
    cuisine_id = extra[:cuisine_id]

    search do
      with(:location).in_radius(lat, lon, radius) if (lat && lon && radius)
      with(:city, city) if city.present?
      with(:locality_name, locality.area_name) if locality.present?
      with(:cuisine_ids, [cuisine_id]) if cuisine_id.present?
      #paginate(:page=>1,:per_page=>6)
    end
  end

  def city
    locality.city
  end

  def locality_name
    locality.area_name
  end

  def url
    place_path id
  end

  def distance_from latlon
    Geocoder::Calculations.distance_between(latlon, [latitude, longitude], {units: :km})
  end

  def cuisines_list
    cuisines.collect { |c| c.name.upcase }.join(', ')
  end

end
