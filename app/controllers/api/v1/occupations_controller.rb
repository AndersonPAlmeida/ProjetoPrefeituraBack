module Api::V1
  class OccupationsController < ApplicationController 
    include Authenticable

    before_action :set_occupation, only: [:show, :update, :destroy]

    # GET /occupations
    def index
      @occupations = policy_scope(Occupation.filter(params[:q], params[:page], 
        Professional.get_permission(current_user[1])))

      if @occupations.nil?
        render json: {
          errors: ["You don't have the permission to view occupations."]
        }, status: 403
      else
        response = Hash.new
        response[:num_entries] = @occupations.total_count
        response[:entries] = @occupations.index_response

        render json: response
      end
    end

    # GET /occupations/1
    def show
      if @occupation.nil?
        render json: {
          errors: ["Occupation #{params[:id]} does not exist."]
        }, status: 404
      else
        begin
          authorize @occupation, :show?
        rescue
          render json: {
            errors: ["You're not allow to see this occupation."]
          }, status: 403
          return
        end

        render json: @occupation.complete_info_response
      end
    end

    # POST /occupations
    def create
      @occupation = Occupation.new(occupation_params)

      begin
        authorize @occupation, :create?
      rescue
        render json: {
          errors: ["You're not allow to create this occupation."]
        }, status: 403
        return
      end

      if @occupation.save
        render json: @occupation.complete_info_response, status: :created
      else
        render json: @occupation.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /occupations/1
    def update
      if @occupation.nil?
        render json: {
          errors: ["Occupation #{params[:id]} does not exist."]
        }, status: 404
      else
        begin
          authorize @occupation, :update?
        rescue
          render json: {
            errors: ["You're not allow to update this occupation."]
          }, status: 403
          return
        end

        if @occupation.update(occupation_params)
          render json: @occupation.complete_info_response
        else
          render json: @occupation.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /occupations/1
    def destroy
      if @occupation.nil?
        render json: {
          errors: ["Occupation #{params[:id]} does not exist."]
        }, status: 404
      else
        @occupation.active = false
        @occupation.save!
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_occupation
      begin
        @occupation = Occupation.find(params[:id])
      rescue
        @occupation = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def occupation_params
      params.require(:occupation).permit(
        :active,
        :city_hall_id,
        :description,
        :name
      )
    end
  end
end
