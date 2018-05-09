module Api::V1
  class CityHallsController < ApplicationController 
    include Authenticable

    before_action :set_city_hall, only: [:show, :update, :destroy]

    # GET /city_halls
    def index
      @city_halls = policy_scope(CityHall.filter(params[:q], params[:page],
        Professional.get_permission(current_user[1])))


      if @city_halls.nil?
        render json: {
          errors: ["You don't have the permission to view city halls."]
        }, status: 403
        return
      else
        response = Hash.new
        response[:num_entries] = @city_halls.total_count
        response[:entries] = @city_halls.index_response

        render json: response.to_json
        return
      end
    end


    # GET /city_halls/1
    def show
      if @city_hall.nil?
        render json: {
          errors: ["City hall #{params[:id]} does not exist."]
        }, status: 404
      else
        begin
          authorize @city_hall, :show?
        rescue
          render json: {
            errors: ["You don't have the permission to view this city hall."]
          }, status: 403
          return
        end

        render json: @city_hall.complete_info_response
      end
    end


    # POST /city_halls
    def create
      @city_hall = CityHall.new(city_hall_params)

      begin
        authorize @city_hall, :create?
      rescue
        render json: {
          errors: ["You don't have the permission to create city halls."]
        }, status: 403
        return
      end

      if @city_hall.save
        render json: @city_hall.complete_info_response, status: :created
      else
        render json: @city_hall.errors, status: :unprocessable_entity
      end
    end


    # PATCH/PUT /city_halls/1
    def update
      if @city_hall.nil?
        render json: {
          errors: ["City hall #{params[:id]} does not exist."]
        }, status: 404
      else
        begin
          authorize @city_hall, :update?
        rescue
          render json: {
            errors: ["You don't have the permission to create city halls."]
          }, status: 403
          return
        end

        if @city_hall.update(city_hall_params)
          render json: @city_hall.complete_info_response
        else
          render json: @city_hall.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /city_halls/1
    #def destroy
    #  if @city_hall.nil?
    #    render json: {
    #      errors: ["City hall #{params[:id]} does not exist."]
    #    }, status: 404
    #  else
    #    @city_hall.active = false
    #    @city_hall.save!
    #  end
    #end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_city_hall
      begin
        @city_hall = CityHall.find(params[:id])
      rescue
        @city_hall = nil
      end
    end


    # Only allow a trusted parameter "white list" through.
    def city_hall_params
      params.require(:city_hall).permit(
        :address_number,
        :address_complement, 
        :block_text, 
        :citizen_access, 
        :citizen_register, 
        :cep, 
        :description, 
        :email, 
        :name, 
        :neighborhood, 
        :phone1, 
        :phone2, 
        :schedule_period, 
        :show_professional, 
        :support_email, 
        :url
      )
    end
  end
end
