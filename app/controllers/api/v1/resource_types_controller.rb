module Api::V1
  class ResourceTypesController < ApplicationController
    include Authenticable
    
    before_action :set_resource_type, only: [:show, :update, :destroy]

    # GET /resource_types
    def index
      citizen = current_user.first      
      
      professional = citizen.professional

      service_place = professional.professionals_service_places
      .find(params[:permission]).service_place  

      city_hall_id = service_place.city_hall_id

      permission = Professional.get_permission(params[:permission])

      if params[:permission] != "citizen"
        citizen = current_user.first
        
        professional = citizen.professional

        service_place = professional.professionals_service_places
        .find(params[:permission]).service_place  

        city_hall_id = service_place.city_hall_id

        if params[:permission] == "1"
          @resource_type = ResourceType.all.filter(params[:q], params[:page], permission)
        else
          @resource_type = ResourceType.where(city_hall_id: city_hall_id).filter(params[:q], params[:page], permission)
        end 
        
        authorize @resource_type, :index?    
        render json: @resource_type
      end
    end

    # GET /resource_types/1
    def show
      if @resource_type.nil?
        render json: {
          errors: ["Resource type #{params[:id]} does not exist."]
        }, status: 404
      else
        citizen = current_user.first
        city_hall = CityHall.where(city_id:citizen.city_id).first
        authorize @resource_type, :show?          
        if @resource_type.city_hall_id == city_hall.id or params[:permission] == "1"
          render json: @resource_type          
        end
      end
    end

    # POST /resource_types
    def create
      @resource_type = ResourceType.new(resource_type_params)
      @resource_type.active = true

      authorize @resource_type, :create?      
      if @resource_type.save
        render json: @resource_type, status: :created
      else
        render json: @resource_type.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /resource_types/1
    def update
      if @resource_type.nil?
        render json: {
          errors: ["Resource type #{params[:id]} does not exist."]
        }, status: 404
      else
        authorize @resource_type, :update?            
        if @resource_type.update(resource_type_params)
          render json: @resource_type
        else
          render json: @resource_type.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /resource_types/1
    def destroy
      if @resource_type.nil?
        render json: {
          errors: ["Resource type #{params[:id]} does not exist."]
        }, status: 404
      else
        authorize @resource_type, :destroy?                    
        @resource_type.active = false
        @resource_type.save!
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_type
      begin
        @resource_type = ResourceType.find(params[:id])
      rescue
        @resource_type = nil
      end
    end

    # Only allow a trusted parameter "white list" through.

    def resource_type_params
      params.require(:resource_type).permit(
        :city_hall_id,
        :name,
        :active,
        :mobile,
        :description
      )
    end
  end    
end
