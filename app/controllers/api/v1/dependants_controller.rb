module Api::V1
  class DependantsController < ApplicationController 
    include Authenticable

    before_action :set_dependant, only: [:show, :update, :destroy]
    before_action :set_citizen, only: [:index, :show, :update, :create]

    # GET citizens/1/dependants
    def index
      if @citizen.nil?
        render json: {
          errors: ["Citizen #{params[:citizen_id]} does not exist."]
        }, status: :not_found
      else
        @dependants = Dependant.where(citizens: {
          responsible_id: @citizen.id
        }).includes(:citizen)

        dependants_response = []

        @dependants.each do |item|
          dependants_response.append(item.citizen.as_json(only: [
            :id, :name, :rg, :cpf, :birth_date
          ]))

          dependants_response[-1]["id"] = item.id
        end

        render json: dependants_response.to_json, status: :ok
      end
    end

    # GET citizens/1/dependants/2
    def show
      if @citizen.nil?
        render json: {
          errors: ["Citizen #{params[:citizen_id]} does not exist."]
        }, status: :not_found
      else
        if @dependant.nil?
          render json: {
            errors: ["Dependant #{params[:id]} does not exist."]
          }, status: :not_found
        elsif @dependant.citizen.responsible_id != @citizen.id
          render json: {
            errors: ["Dependant #{params[:id]} does not belong to citizen #{params[:citizen_id]}."]
          }, status: :forbidden
        else
          render json: @dependant.complete_info_response, status: :ok
        end
      end
    end

    # POST citizens/1/dependants
    def create
      if @citizen.nil?
        render json: {
          errors: ["Citizen #{params[:citizen_id]} does not exist."]
        }, status: :not_found
      else
        new_params = dependant_params
        new_params[:responsible_id] = @citizen.id

        if new_params[:cep].blank?
          new_params[:cep] = @citizen.cep
        end
        
        # Create new citizen associated with new dependant
        citizen = Citizen.new(new_params)
        citizen.active = true
        citizen.city_id = Address.get_city_id(new_params[:cep])


        # Add image to citizen if provided
        if params[:dependant][:image]
          if params[:dependant][:image][:content_type] == "delete"
            citizen.avatar.destroy
          else
            begin
              params[:dependant][:image] = parse_image_data(params[:dependant][:image])
              citizen.update_attribute(:avatar, params[:dependant][:image])
            ensure
              clean_tempfile
            end
          end
        end


        if not citizen.save
          render json: citizen.errors, status: :unprocessable_entity
        else 
          @dependant = Dependant.new(citizen_id: citizen.id)

          if @dependant.save
            render json: @dependant.complete_info_response, status: :created
          else
            render json: @dependant.errors, status: :unprocessable_entity
          end
        end
      end
    end

    # PATCH/PUT citizens/1/dependants/2
    def update
      if @citizen.nil?
        render json: {
          errors: ["Citizen #{params[:citizen_id]} does not exist."]
        }, status: :not_found
      else
        if @dependant.nil?
          render json: {
            errors: ["Dependant #{params[:id]} does not exist."]
          }, status: :not_found
        elsif @dependant.citizen.responsible_id != @citizen.id
          render json: {
            errors: ["Dependant #{params[:id]} does not belong to citizen #{params[:id]}."]
          }, status: :forbidden
        else
          new_params = dependant_params

          if new_params[:cep].blank?
            new_params[:cep] = @citizen.cep
          end

          # Add image to citizen if provided
          if params[:dependant][:image]
            if params[:dependant][:image][:content_type] == "delete"
              @dependant.citizen.avatar.destroy
            else
              begin
                params[:dependant][:image] = parse_image_data(params[:dependant][:image])
                @dependant.citizen.update_attribute(:avatar, params[:dependant][:image])
              ensure
                clean_tempfile
              end
            end
          end

          if @dependant.citizen.update(new_params)
            render json: @dependant.complete_info_response
          else
            render json: @dependant.citizen.errors, status: :unprocessable_entity
          end
        end
      end
    end

    # DELETE citizens/1/dependants/2
    def destroy
      if @dependant.nil?
        render json: {
          errors: ["Dependant #{params[:id]} does not exist."]
        }, status: :not_found
      else
        @dependant.citizen.active = false
        @dependant.deactivated = DateTime.now

        @dependant.save
        @dependant.citizen.save
      end
    end

    private

    def parse_image_data(image_data)
      @tempfile = Tempfile.new('item_image')
      @tempfile.binmode
      @tempfile.write Base64.decode64(image_data[:content])
      @tempfile.rewind

      uploaded_file = ActionDispatch::Http::UploadedFile.new(
        tempfile: @tempfile,
        filename: image_data[:filename]
      )

      uploaded_file.content_type = image_data[:content_type]
      uploaded_file
    end

    def clean_tempfile
      if @tempfile
        @tempfile.close
        @tempfile.unlink
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_dependant
      begin
        @dependant = Dependant.find(params[:id])
      rescue
        @dependant = nil
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_citizen
      begin
        @citizen = Citizen.find(params[:citizen_id])
      rescue
        @citizen = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def dependant_params
      params.require(:dependant).permit(Citizen.keys)
    end
  end
end
