class SearchesController < ApplicationController
  before_filter :authenticate_user!

  def new
  end

=begin
  def search
    @search = Item.search do
      fulltext params[:search]
      paginate page: 1, per_page: 10
    end
    @results = @search.results
    render 'new'
  end
=end

  def search
    search_term,city = params[:search], (params[:city] || 'Bangalore')
    @results = []
    [Place,Locality,Cuisine,Item].each do |category|
      @results += category.custom_search search_term,city: city
    end
    render json: @results
  end

  def places
    lat,lon,radius,area,city = params[:lat].to_i, params[:lon].to_i,params[:radius].to_i,params[:area],params[:city]
    @places = Place.new_custom_search(lat, lon, radius: radius, area: area, city: city).results

    respond_to do |format|
      format.html { render 'places', :layout => false }
      format.json { render json: @places }
    end
  end

end