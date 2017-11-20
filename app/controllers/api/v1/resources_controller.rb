module Api::V1
  class ResourcesController < ApplicationController
    include Authenticable
    
    before_action :set_resource, only: [:show, :update, :destroy]

    # GET /resources
    def index
      if (params[:permission] != "citizen")
        citizen = current_user.first

        professional = citizen.professional

        service_place = professional.professionals_service_places
        .find(params[:permission]).service_place  

        city_hall_id = service_place.city_hall_id

        if params[:permission] == "1"
          @resources = Resource.all
        else
          resource_type_ids = []
          resource_types = ResourceType.where(city_hall_id: city_hall_id)
          resource_types.each do |rt|
            resource_type_ids << rt.id          
          end
          @resources = Resource.where(resource_types_id:resource_type_ids.uniq)
        end 

        authorize @resources, :index?    

        render json: @resources
      end
    end

    # GET /resources/1
    def show
      if @resources.nil?
        render json: {
          errors: ["Resource #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @resources
      end
    end

    # POST /resources
    def create
      @resources = Resource.new(resource_params)
      @resources.active = true
      resource_type = ResourceType.where(id:@resources.resource_types_id)
      info = get_basic_info

      if resource_type.city_hall_id == info.city_hall_id
        if @resources.save
          render json: @resources, status: :created
        else
          render json: @resources.errors, status: :unprocessable_entity
        end
      else 
        render json: "You can not use this resource type", status: :unprocessable_entity        
      end
    end

    # PATCH/PUT /resources/1
    def update
      if @resources.nil?
        render json: {
          errors: ["Resource #{params[:id]} does not exist."]
        }, status: 404
      else
        if @resources.update(resource_params)
          render json: @resources
        else
          render json: @resources.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /resources/1
    def destroy
      if @resources.nil?
        render json: {
          errors: ["Resource #{params[:id]} does not exist."]
        }, status: 404
      else
        @resources.active = false
        @resources.save!
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      begin
        @resources = Resource.find(params[:id])
      rescue
        @resources = nil
      end
    end

    # Only allow a trusted parameter "white list" through.

    def resource_params
      params.require(:resource).permit(
        :resource_types_id,
        :service_place_id,
        :professional_responsible_id,
        :minimum_schedule_time,
        :maximum_schedule_time,
        :active,
        :brand,
        :model,
        :label,
        :note
      )
    end

    def get_basic_info 
      citizen = current_user.first      
      
      professional = citizen.professional

      service_place = professional.professionals_service_places
      .find(params[:permission]).service_place  

      city_hall_id = service_place.city_hall_id

      return {
        citizen: citizen, 
        professional: professional, 
        service_place: service_place,
        city_hall_id: city_hall_id
      }
    end
  end
end
