class LineItemsController < ApplicationController
  include CurrentCart
  skip_before_action :authorize, only: :create
  before_action :set_cart, only: [:create, :destroy]
  before_action :set_line_item, only: [:show, :edit, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_line_item
  # GET /line_items
  # GET /line_items.json
  def index
    @line_items = LineItem.all
  end

  # GET /line_items/1
  # GET /line_items/1.json
  def show
  end

  # GET /line_items/new
  def new
    @line_item = LineItem.new
  end

  # GET /line_items/1/edit
  def edit
  end

  # POST /line_items
  # POST /line_items.json
  def create
    product = Product.find(params[:product_id])
    @line_item = @cart.add_product(product.id)
    session[:counter] = 0 # Reset the counter to 0 whenever the user adds something to the cart
    respond_to do |format|
      if @line_item.save
        format.html { redirect_to store_url }
        format.js { @current_item = @line_item }
        format.json { render action: 'show', status: :created, location: @line_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /line_items/1
  # PATCH/PUT /line_items/1.json
  def update
    respond_to do |format|
      if @line_item.update(line_item_params)
        format.html { redirect_to @line_item, notice: 'Line item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /line_items/1
  # DELETE /line_items/1.json
  def destroy
    @line_item = @cart.remove_product(@line_item.product_id)
    #@line_item = Cart.find(@line_item.cart_id).remove_product(@line_item.product_id)

    if (@line_item) #&& (@line_item.cart_id == session[:cart_id]))
      if (@line_item.quantity == 0) 
        @line_item.destroy
      else
        @line_item.save
      end
    end

    #cart = @line_item.cart
    #@line_item.destroy if @line_item.cart_id == session[:cart_id]

    respond_to do |format|
      format.html { redirect_to store_url, notice: 'Your item has been deleted' }
      format.js { @current_item = @line_item }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line_item
      @line_item = LineItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def line_item_params
      params.require(:line_item).permit(:product_id)
    end

    def invalid_line_item
      logger.error "Attempt to access invalid line item #{params[:id]}"
      redirect_to store_url, notice: 'Invalid line item'
    end
end
