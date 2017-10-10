module Api::V1
  class ProfessionalsController < ApplicationController
    include Authenticable
    include HasPolicies

    before_action :set_professional, only: [:show, :update, :destroy]

    # GET /professionals
    def index
      # TODO: @professionals = policy_scope(Professional.filter(params[:q], params[:page]))
      @professionals = policy_scope(Professional)

      if @professionals.nil?
        render json: {
          errors: ["You don't have the permission to view professionals."]
        }, status: 403
      else
        render json: @professionals.index_response.to_json
      end
    end

    # GET /professionals/1
    def show
      if @professional.nil?
        render json: {
          errors: ["Professional #{params[:id]} does not exist."]
        }, status: 404
      else
        authorize @professional, :show?

        render json: @professional.complete_info_response
      end
    end

    # POST /professionals
    def create
      @professional = Professional.new(professional_params)

      if @professional.save
        render json: @professional, status: :created
      else
        render json: @professional.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /professionals/1
    def update
      if @professional.nil?
        render json: {
          errors: ["Professional #{params[:id]} does not exist."]
        }, status: 404
      else
        if @professional.update(professional_params)
          render json: @professional
        else
          render json: @professional.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /professionals/1
    def destroy
      if @professional.nil?
        render json: {
          errors: ["Professional #{params[:id]} does not exist."]
        }, status: 404
      else
        @professional.active = false
        @professional.save!
      end
    end

    private

    # Rescue Pundit exception for providing more details in reponse
    def policy_error_description(exception)
      # Set @policy_name as the policy method that raised the error
      super

      case @policy_name
      when "show?"
        render json: {
          errors: ["You're not allowed to view this professional."]
        }, status: 403
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_professional
      begin
        @professional = Professional.find(params[:id])
      rescue
        @professional = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def professional_params
      params.require(:professional).permit(
        :id,
        :active,
        :account_id,
        :occupation_id,
        :registration
      )
    end
  end
end
