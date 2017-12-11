module Api::V1
  class CitizensController < ApplicationController 
    include Authenticable
    include HasPolicies

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
        path = @citizen.avatar.path

        if path.nil?
          render json: {
            errors: ["User #{params[:id]} does have a picture."]
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

    # GET /citizen/1/schedule_options
    def schedule_options
      @citizen = Citizen.find_by(cpf: params[:cpf])

      if @citizen.nil?
        render json: {
          errors: ["User #{params[:id]} does not exist."]
        }, status: 404
      else
        # Allow request only if the citizen is reachable from current user
        authorize @citizen, :schedule?

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
        authorize @citizen, :show?

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
        authorize @citizen, :deactivate?

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

    # Rescue Pundit exception for providing more details in reponse
    def policy_error_description(exception)
      # Set @policy_name as the policy method that raised the error
      super

      case @policy_name
      when "schedule?"
        render json: {
          errors: ["You're not allowed to schedule for this citizen."]
        }, status: 403
      when "deactivate?"
        render json: {
          errors: ["You're not allowed to deativate this citizen."]
        }, status: 403
      when "show?"
        render json: {
          errors: ["You're not allowed to view this citizen."]
        }, status: 403
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
