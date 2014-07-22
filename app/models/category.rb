class Category < ActiveRecord::Base
  belongs_to :place

  has_many :items

  validates_presence_of :name

  after_initialize do |category|
    category.position ||= 0
  end

  def total_item_cold_votes
    items.inject(0) {|sum,item| sum += item.cold_votes}
  end
end
