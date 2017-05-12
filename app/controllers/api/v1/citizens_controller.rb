module Api::V1
  class CitizensController < ApplicationController 
    include Authenticable

    before_action :set_citizen, only: [:show_picture, :show, :update, :destroy]

    # GET /citizens
    def index
      @citizens = Citizen.all_active

      render json: @citizens
    end

    def show_picture
      if @citizen.nil?
        render json: {
          errors: ["User #{params[:id]} does not exist."]
        }, status: 404
      else
        path = @citizen.avatar.path
        if path.nil?
          render json: {
            errors: ["User does not have a picture."]
          }, status: 404
        else
          if not params[:size].nil?
            path.sub!('original', params[:size])
          end

          send_file path, 
            type: @citizen.avatar_content_type, 
            disposition: 'inline'
        end
      end
    end

    # GET /citizens/1
    def show
      if @citizen.nil?
        render json: {
          errors: ["User #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @citizen
      end
    end

    # POST /citizens
    def create
      @citizen = Citizen.new(citizen_params)
      @citizen.active = true

      # TODO: the city must come from the front-end, which means that
      # no request to correios should be made in the back-end, except
      # the validation in the cep_controller when requested by the
      # front-end
      @citizen.city_id = Address.get_city_id(citizen_params[:cep])

      if @citizen.save
        render json: @citizen, status: :created
      else
        render json: @citizen.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /citizens/1
    def update
      if @citizen.nil?
        render json: {
          errors: ["User #{params[:id]} does not exist."]
        }, status: 404
      else
        if @citizen.update(citizen_params)
          render json: @citizen
        else
          render json: @citizen.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /citizens/1
    def destroy
      if @citizen.nil?
        render json: {
          errors: ["User #{params[:id]} does not exist."]
        }, status: 404
      else
        @citizen.active = false
        @citizen.save!
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_citizen
      begin
        @citizen = Citizen.find(params[:id])
      rescue
        @citizen = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def citizen_params
      params.require(:citizen).permit(
        :id,
        :account_id,
        :active,
        :address_complement,
        :address_number,
        :address_street,
        :birth_date,
        :cep,
        :city_id,
        :cpf,
        :email,
        :name,
        :neighborhood,
        :note,
        :pcd,
        :phone1,
        :phone2,
        :rg
      )
    end
  end
end
