module Api::V1
  class ResourceShiftsController < ApplicationController
    include Authenticable

    before_action :set_resource_shift, only: [:show, :update, :destroy]

    # GET /resource_shifts
    def get_professional_resource_shift
      authorize ResourceShift

      professional_name = Citizen.where(
                          account_id:Account.where(
                                id:Professional.where(
                                    id: params[:id]
                                ).first.id
                          ).first.id
                        ).first.name

      render json: {
        professional_name: professional_name
      }
    end

    # GET /resource_shifts
    def index
      @resource_shift = policy_scope(ResourceShift.filter(
        params[:q], params[:page], params[:permission]))

      if @resource_shift.nil?
        render json: {
          errors: ["You don't have the permission to view resource shifts."]
        }, status: 403
      else
        render json: @resource_shift
      end
    end

    # GET /resource_shifts/1
    def show
      begin
        authorize @resource_shift, :show?
      rescue
        render json: {
          errors: ["This resource does not belong to your city"]
        }, status: :unprocessable_entity
        return
      end

      if @resource_shift.nil?
        render json: {
          errors: ["Resource shift #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @resource_shift
      end
    end

    # POST /resource_shifts
    def create
      @resource_shift = ResourceShift.new(resource_shift_params)
      @resource_shift.active = true
      @resource_shift.borrowed = false

      resource = Resource.where(id: @resource_shift.resource_id)

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
        :active,
        :borrowed
      )
    end

  end
end
