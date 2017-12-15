module Api::V1
  class ResourceBookingsController < ApplicationController
    include Authenticable  
    
    before_action :set_resource_booking, only: [:show, :update, :destroy]

    # GET /resource_bookings
    # You should pass the parameter view togheter with permission:
    # localhost:3000/resource_bookings&permission=2&view=professional
    def index
      citizen = current_user.first
      permission = Professional.get_permission(params[:permission])
      if (params[:permission] != "citizen")
        if (!params[:view])
          render json: {
            errors: ["You must provide the view parameter"]
          }, status: :unprocessable_entity
        end
        professional = citizen.professional
        service_place = professional.professionals_service_places
        .find(params[:permission]).service_place  

        city_hall_id = service_place.city_hall_id
        if (params[:view] == "professional")
          if permission == "adm_c3sl"
            @resource_booking = ResourceBooking.all.filter(params[:q], params[:page], permission)
          else       
            if (permission == "adm_prefeitura")
              # User can get all bookings of the city
              service_place_id = ServicePlace.where(city_hall_id: city_hall_id)
            else
              # User can get all bookings of the city
              service_place_id = [service_place]         
            end
            service_place_ids = []
            service_place_id.each do | sp | 
              service_place_ids << sp.id
            end
            @resource_booking = ResourceBooking.where(service_place_id: service_place_ids.uniq)
             .filter(params[:q], params[:page], permission)
          end 
        else 
          @resource_booking = get_resource_booking_from_citizen().filter(params[:q], params[:page], permission)
        end

      else
        @resource_booking = get_resource_booking_from_citizen().filter(params[:q], params[:page], permission)        
      end
      # TODO: Add more info when get
      @resource_booking.each do |rb|
        moreInfo = {}
        moreInfo['citizen_name'] = Citizen.where(id:rb.citizen_id).first.name
        moreInfo['resource'] = Resource.where(id: ResourceShift.where(id:rb.resource_shift_id).first.resource_id).first
        moreInfo['resource_type_name'] = ResourceType.where(id: moreInfo['resource'].resource_id).first.name
        p moreInfo['resource']
        rb[:more_info] = moreInfo
      end

      render json: @resource_booking.filter(params[:q], params[:page], permission) 
    end

    # GET /resource_bookings/1
    def show
      citizen = current_user.first  
      permission = Professional.get_permission(params[:permission])

      if params[:permission] == "citizen"
        city_hall_id = CityHall.where(city_id: citizen.city_id).first.id
      else 
        professional = citizen.professional
        service_place = professional.professionals_service_places
        .find(params[:permission]).service_place  

        city_hall_id = service_place.city_hall_id
      end

      if @resource_booking.nil?
        render json: {
          errors: ["Resource booking #{params[:id]} does not exist."]
        }, status: 404
      else
        if params[:permission] == "citizen" 
          if @resource_booking.citizen_id == citizen.id
            render json: @resource_booking
          else 
            render json: {
              errors: ["You do not have permission to see this booking"]
            }, status: :unprocessable_entity
          end
        else 
          case permission
          when "adm_c3sl"
            render json: @resource_booking
          when "adm_prefeitura"
            if (ServicePlace.where(id: @resource_booking.service_place_id).first.city_hall_id == city_hall_id)
              render json: @resource_booking
            else 
              render json: {
                errors: ["You do not have permission to see this booking: Booking outside your city"]
              }, status: :unprocessable_entity
            end
          else
            if (@resource_booking.service_place_id == service_place.id)
              render json: @resource_booking
            else 
              render json: {
                errors: ["You do not have permission to see this booking: Booking outside your service place"]
              }, status: :unprocessable_entity
            end
          end

        end
      end
    end 

    # POST /resource_bookings
    def create
      @resource_booking = ResourceBooking.new(resource_booking_params)
      @resource_booking.active = true
      @resource_booking.status = "Requisitado"
  
      if @resource_booking.save
        render json: @resource_booking, status: :created
      else
        render json: @resource_booking.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /resource_bookings/1
    def update
      citizen = current_user.first  
      permission = Professional.get_permission(params[:permission])

      if params[:permission] == "citizen"
        city_hall_id = CityHall.where(city_id: citizen.city_id).first.id
      else 
        professional = citizen.professional
        service_place = professional.professionals_service_places
        .find(params[:permission]).service_place  

        city_hall_id = service_place.city_hall_id
      end

      if @resource_booking.nil? 
        render json: {
          errors: ["Resource booking #{params[:id]} does not exist."]
        }, status: 404
      else

        if params[:permission] == "citizen" 
          if @resource_booking.citizen_id == citizen.id
            if @resource_booking.update(resource_booking_params)
              render json: @resource_booking
            else
              render json: @resource_booking.errors, status: :unprocessable_entity
            end
          else 
            render json: {
              errors: ["You do not have permission to update this booking"]
            }, status: :unprocessable_entity
          end
        else 
          case permission
          when "adm_c3sl"
            if @resource_booking.update(resource_booking_params)
              render json: @resource_booking
            else
              render json: @resource_booking.errors, status: :unprocessable_entity
            end
          when "adm_prefeitura"
            if (ServicePlace.where(id: @resource_booking.service_place_id).first.city_hall_id == city_hall_id)
              if @resource_booking.update(resource_booking_params)
                render json: @resource_booking
              else
                render json: @resource_booking.errors, status: :unprocessable_entity
              end
            else 
              render json: {
                errors: ["You do not have permission to update this booking: Booking outside your city"]
              }, status: :unprocessable_entity
            end
          else
            if (@resource_booking.service_place_id == service_place.id)
              if @resource_booking.update(resource_booking_params)
                render json: @resource_booking
              else
                render json: @resource_booking.errors, status: :unprocessable_entity
              end
            else 
              render json: {
                errors: ["You do not have permission to update this booking: Booking outside your service place"]
              }, status: :unprocessable_entity
            end
          end
        end
      end
    end

    # DELETE /resource_bookings/1
    def destroy
      citizen = current_user.first  
      permission = Professional.get_permission(params[:permission])
      professional = citizen.professional
      service_place = professional.professionals_service_places
      .find(params[:permission]).service_place  

      city_hall_id = service_place.city_hall_id

      if @resource_booking.nil?
        render json: {
          errors: ["Resource booking #{params[:id]} does not exist."]
        }, status: 404
      else
        case permission
        when "adm_c3sl"
          @resource_booking.active = false
          @resource_booking.status = "Indisponível"
          @resource_booking.save!
        when "adm_prefeitura"
          if (ServicePlace.where(id: @resource_booking.service_place_id).first.city_hall_id == city_hall_id)
            @resource_booking.active = false
            @resource_booking.status = "Indisponível"
            @resource_booking.save!
          else 
            render json: {
              errors: ["You do not have permission to delete this booking: Booking outside your city"]
            }, status: :unprocessable_entity
          end
        else
          if (@resource_booking.service_place_id == service_place.id)
            @resource_booking.active = false
            @resource_booking.status = "Indisponível"
            @resource_booking.save!
          else 
            render json: {
              errors: ["You do not have permission to delete this booking: Booking outside your service place"]
            }, status: :unprocessable_entity
          end
        end
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_booking
      begin
        @resource_booking = ResourceBooking.find(params[:id])
      rescue
        @resource_booking = nil
      end
    end

    # Only allow a trusted parameter "white list" through.

    def resource_booking_params
      params.require(:resource_booking).permit(
        :service_place_id,
        :resource_shift_id,
        :situation_id,
        :citizen_id,
        :booking_reason,
        :booking_start_time,
        :booking_end_time,
        :status
      )
    end

    def get_resource_booking_from_citizen
      citizen = current_user.first
      resource_booking = ResourceBooking.where(citizen_id: citizen.id)
      return resource_booking
    end

  end
end