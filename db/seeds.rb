wok = Place.create!(:name => 'SO')
category = Category.create!(:place => wok, :name => 'Soups', :position => 3)

Item.create!(:place => wok, :category => category, :name => 'Chicken Wok', :desc => 'Fusion of Chickend and Fried Rice', :price => 300, :cold_votes => 2)
