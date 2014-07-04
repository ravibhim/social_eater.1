class Admin::PlacesController < Admin::MainController

  before_action :set_place, only: [:show, :notes, :edit, :update, :destroy]
  

  def index
    @places = Place.all
  end

  def show
    @item = Item.new
  end

  def new
    @place = Place.new
  end

  def notes
    if request.post?
      save_uncategorized_items
      redirect_to [:admin,@place], notice: 'Uncategorized items added'
    end
  end

  # GET /places/1/edit
  def edit
  end

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(place_params)

    respond_to do |format|
      if @place.save
        format.html { redirect_to [:admin,:places], notice: 'Place was successfully created.' }
        format.json { render action: 'show', status: :created, location: @place }
      else
        format.html { render action: 'new' }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    respond_to do |format|
      if @place.update(place_params)
        format.html { redirect_to [:admin,@place], notice: 'Place was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place.destroy
    respond_to do |format|
      format.html { redirect_to [:admin,:places], notice: 'Place was destroyed successfully' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_place
      @place = Place.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def place_params
      params.require(:place).permit(:name)
    end

    def save_uncategorized_items
      (0..99).each do |index|
       if params["item_#{index}"].present?
        Item.create!(
          :place => @place,
          :name => params["item_#{index}"], 
          :cold_votes => params["count_#{index}"]
          )
       end
      end
    end
end
