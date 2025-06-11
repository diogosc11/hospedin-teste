class Api::V1::ProductsController < ApplicationController
    def index
        @products = Product.all
        
        @products = @products.active if params[:active] == 'true'
        @products = @products.where(active: false) if params[:active] == 'false'
            
        render json: @products
    end
end
