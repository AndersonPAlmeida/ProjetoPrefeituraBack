module Api::V1
  class CitizensController < ApplicationController
    include Authenticable
    include HasPolicies
    require 'csv'

    before_action :set_citizen, only: [:picture, :show, :update, :destroy]

    # GET /citizens
    def index
      @citizens = policy_scope(Citizen.filter(params[:q], params[:page],
        Professional.get_permission(current_user[1])))

      if @citizens.nil?
        render json: {
          errors: ["You don't have the permission to view citizens."]
        }, status: 403
      else
        response = Hash.new
        response[:num_entries] = @citizens.total_count
        response[:entries] = @citizens.as_json(only: [:id, :name, :birth_date, :cpf],
                                               methods: %w(num_of_dependants))

        render json: response.to_json
      end
    end


    # GET /citizens/1/picture
    def picture
      if @citizen.nil?
        render json: {
          errors: ["User #{params[:id]} does not exist."]
        }, status: 404
      else
        # Allow request only if the citizen is reachable from current user
        begin
          authorize @citizen, :show_picture?
        rescue
          render json: {
            errors: ["You're not allowed to view this citizen."]
          }, status: 403
          return
        end

        path = @citizen.avatar.path

        if path.nil?
          render json: {
            errors: ["User #{params[:id]} does not have a picture."]
          }, status: 404
        else
          if not params[:size].nil?
            path.sub!('original', params[:size])
          end

          begin
            send_file path,
              type: @citizen.avatar_content_type,
              disposition: 'inline'
          rescue
            send_file "public/missing.png",
              type: "image/png",
              disposition: 'inline'
          end
        end
      end
    end

    # GET /citizen/1/schedule_options
    def schedule_options
      @citizen = Citizen.find_by(cpf: params[:cpf])

      if @citizen.nil?
        render json: {
          errors: ["User #{params[:id]} does not exist."]
        }, status: 404
      else
        # Allow request only if the citizen is reachable from current user
        begin
          authorize @citizen, :schedule?
        rescue
          render json: {
            errors: ["You're not allowed to schedule for this citizen."]
          }, status: 403
          return
        end

        schedule_response = @citizen.schedule_response

        render json: schedule_response.to_json
      end
    end


    # GET /citizens/1
    def show
      if @citizen.nil?
        render json: {
          errors: ["User #{params[:id]} does not exist."]
        }, status: 404
      else
        # Allow request only if the citizen is reachable from current user
        begin
          authorize @citizen, :show?
        rescue
          render json: {
            errors: ["You're not allowed to view this citizen."]
          }, status: 403
          return
        end

        render json: @citizen
      end
    end


    # POST /citizens
    def create
      success = false
      error_message = nil

      raise_rollback = -> (error) {
        error_message = error
        raise ActiveRecord::Rollback
      }

      ActiveRecord::Base.transaction do

        # Creates citizen
        @citizen = Citizen.new(citizen_params)
        @citizen.active = true

        # Creates account
        begin
          @account = Account.new({
            uid: citizen_params[:cpf],
            provider: "cpf",
            password: @citizen.birth_date.strftime('%d%m%y'),
            password_confirmation: @citizen.birth_date.strftime('%d%m%y')
          })

          @account.save

        rescue ActiveRecord::RecordNotUnique
          raise_rollback.call([I18n.t(
            "devise_token_auth.registrations.email_already_exists", email: @citizen.cpf
          )])
        end

        # Assign new account to new citizen
        @citizen.account_id = @account.id
        raise_rollback.call(@citizen.errors.to_hash) unless @citizen.save

        success = true
      end # End Transaction

      if success
        render json: @citizen.complete_info_response, status: :created
      else
        render json: {
          errors: error_message
        }, status: 422
      end
    end


    # GET /citizens/upload_log/1
    def get_upload_log
      # Find uploads for current citizen
      @upload = CitizenUpload.find(params[:upload_id])

      if @upload.nil?
        render json: {
          errors: ["Upload task #{params[:upload_id]} does not exist."]
        }, status: 404

      else
        # Upload log path
        path = @upload.log.path

        # If log not found, displays not found message
        if path.nil?
          render json: {
            errors: ["Log not found for current task."]
          }, status: 404

        # Otherwise, send file
        else
          send_file path,
            type: @upload.log_content_type,
            disposition: 'inline'
        end
      end
    end

    # GET /citizens/upload
    def get_uploads
      # Current citizen id
      citizen_id = current_user[0][:id]

      # Permission
      permission = Professional.get_permission(current_user[1])

      # Find uploads for current citizen
      @uploads = CitizenUpload.where(citizen_id: citizen_id)
                              .order("created_at DESC")
                              .filter(params[:q], params[:page], permission)

      # Create response object
      response = Hash.new
      response[:num_entries] = @uploads.total_count
      response[:entries] = @uploads.as_json

      # Render uploads in JSON format
      render json: response.to_json
    end

    # POST /citizens/upload
    def upload
      # Current citizen id
      citizen_id = current_user[0][:id]

      # Data must be defined in the parameters
      if params.has_key?(:data) and params[:data].present?
        # Number of citizens to upload
        upload_size = params[:data].size

        # Create upload object
        upload_object = CitizenUpload.new({
          citizen_id: citizen_id,
          status: 0, # ready to start
          amount: upload_size,
          progress: 0.0
        })

        # Save upload object in the database
        upload_object.save()

        # Create sidekiq job for uploading the citizens
        CitizenUploadWorker.perform_async(
          upload_object.id, upload_size, params[:data])

        render json: {
          errors: ["Citizens scheduled to be imported!"]
        }, status: 201
      else
        render json: {
          errors: ["Undefined citizens to import."]
        }, status: 404
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
        # Allow request only if the citizen is reachable from current user
        begin
          authorize @citizen, :deactivate?
        rescue
          render json: {
            errors: ["You're not allowed to deativate this citizen."]
          }, status: 403
          return
        end

        # Deactivate citizen, this will keep the citizen in the database, but
        # it will not be displayed in future requests
        @citizen.active = false

        if @citizen.save
          render json: @citizen
        else
          render json: @citizen.errors, status: :unprocessable_entity
        end
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
