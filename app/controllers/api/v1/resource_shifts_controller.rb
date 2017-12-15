module Api::V1
  class ResourceShiftsController < ApplicationController
    include Authenticable
    
    before_action :set_resource_shift, only: [:show, :update, :destroy]

    # GET /resource_shifts
    def get_professional_resource_shift
      if (params[:permission] != "citizen")
        professional_name = Citizen.where(
                            account_id:Account.where(
                                  id:Professional.where(
                                      id: ProfessionalsServicePlace.where(id: params[:id]).first.professional_id
                                  ).first.id
                            ).first.id 
                          ).first.name
        render json: {professional_name: professional_name}
      end
    end

    # GET /resource_shifts
    def index
      citizen = current_user.first
      if (params[:permission] != "citizen")

        professional = citizen.professional
        service_place = professional.professionals_service_places
        .find(params[:permission]).service_place  

        city_hall_id = service_place.city_hall_id
        permission = Professional.get_permission(params[:permission])
        if params[:permission] == "1"
          @resource_shift = ResourceShift.all.filter(params[:q], params[:page], permission)
        else
          resource_type_ids = []
          resource_types = ResourceType.where(city_hall_id: city_hall_id)
          resource_types.each do |rt|
            resource_type_ids << rt.id          
          end
          resources = Resource.where(resource_types_id:resource_type_ids.uniq)
          resource_ids = []
          resources.each do | r | 
            resource_ids << r.id 
          end
          @resource_shift = ResourceShift.where(resource_id: resource_ids.uniq)
          .filter(params[:q], params[:page], permission)
        end 

      else
        city_hall_id = CityHall.where(city_id: citizen.city_id).first.id

        resource_type_ids = []
        resource_types = ResourceType.where(city_hall_id: city_hall_id)
        resource_types.each do |rt|
          resource_type_ids << rt.id          
        end
        resources = Resource.where(resource_types_id:resource_type_ids.uniq)
        resource_ids = []
        resources.each do | r | 
          resource_ids << r.id 
        end
        @resource_shift = ResourceShift.where(resource_id: resource_ids.uniq)
        .filter(params[:q], params[:page], permission)
      end


      render json: @resource_shift
    end

    # GET /resource_shifts/1
    def show
      citizen = current_user.first      
      if params[:permission] == "citizen"
        city_hall_id = CityHall.where(city_id: citizen.city_id).first.id
      else 
        professional = citizen.professional
        service_place = professional.professionals_service_places
        .find(params[:permission]).service_place  

        city_hall_id = service_place.city_hall_id

        permission = Professional.get_permission(params[:permission])
      end

      if @resource_shift.nil?
        render json: {
          errors: ["Resource shift #{params[:id]} does not exist."]
        }, status: 404
      else
        resource_city_hall_id = ResourceType.where(
                                id: (Resource.where(
                                      id: @resource_shift.resource_id
                                    ).first.resource_types_id
                                )).first.city_hall_id
        if (resource_city_hall_id == city_hall_id or permission=="adm_c3sl")
          render json: @resource_shift
        else 
          render json: {
            errors: ["This resource does not belong to your city"]
          }, status: :unprocessable_entity
        end
      end
    end

    # POST /resource_shifts
    def create
      if params[:permission] != "citizen"
        info = get_basic_info
        @resource_shift = ResourceShift.new(resource_shift_params)
        @resource_shift.active = true
        @resource_shift.borrowed = false
        
        resource = Resource.where(id: @resource_shift.resource_id )
        if !resource.first.nil?
          if resource.first.active == 1
            authorize @resource_shift, :create?
            if @resource_shift.save
              render json: @resource_shift, status: :created
            else
              render json: @resource_shift.errors, status: :unprocessable_entity
            end
          else 
            render json: {
              errors: ["The system could not create shift: Resource id #{@resource_shift.resource_id} is deactivated."]
            }, status: :unprocessable_entity
          end
        else 
          render json: {
            errors: ["The system could not create shift: Resource id #{@resource_shift.resource_id} does not exist."]
          }, status: :unprocessable_entity
        end
      else
        render json: {
          errors: ["You must be a professional to create a resource shift."]
        }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /resource_shifts/1
    def update
      if @resource_shift.nil?
        render json: {
          errors: ["Resource shift #{params[:id]} does not exist."]
        }, status: 404
      else
        authorize @resource_shift, :update?
        if @resource_shift.update(resource_shift_params)
          render json: @resource_shift
        else
          render json: @resource_shift.errors, status: :unprocessable_entity
        end        
      end
    end

    # DELETE /resource_shifts/1
    def destroy
      if @resource_shift.nil?
        render json: {
          errors: ["Resource shift #{params[:id]} does not exist."]
        }, status: 404
      else
        authorize @resource_shift, :destroy?        
        @resource_shift.active = false
        @resource_shift.save!
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_shift
      begin
        @resource_shift = ResourceShift.find(params[:id])
      rescue
        @resource_shift = nil
      end
    end

    # Only allow a trusted parameter "white list" through.

    def resource_shift_params
      params.require(:resource_shift).permit(
        :resource_id,
        :professional_responsible_id,
        :next_shift_id,
        :execution_start_time,
        :execution_end_time,
        :notes,
        :borrowed
      )
    end

    def get_basic_info 
      citizen = current_user.first      
      
      professional = citizen.professional

      service_place = professional.professionals_service_places
      .find(params[:permission]).service_place  

      city_hall_id = service_place.city_hall_id

      permission = Professional.get_permission(params[:permission])

      return {
        citizen: citizen, 
        professional: professional, 
        service_place: service_place,
        city_hall_id: city_hall_id,
        permission: permission
      }
    end


  end
end
