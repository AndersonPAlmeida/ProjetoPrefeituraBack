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

    # GET professionals/check_citizen
    def check_create_professional
      cpf = params[:cpf]

      @citizen = Citizen.find_by(cpf: cpf)

      if @citizen.nil?
        render json: {
          errors: ["The citizen doesn't exist."]
        }, status: 404
      else
        if @citizen.professional.nil?
          render json: @citizen.complete_info_response
        else
          render json: {
            errors: ["The citizen already is a professional."]
          }, status: 422
        end
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
      success = false
      error_message = nil
      raise_rollback = -> (error) { raise ActiveRecord::Rollback if not error.nil? }

      if params[:create_citizen] == "true"
        ActiveRecord::Base.transaction do
          # Creates citizen
          @citizen = Citizen.new(citizen_params)
          @citizen.active = true

          # Creates account
          begin
            @account = Account.new({
              uid: params[:cpf],
              provider: "cpf",
              password: @citizen.birth_date.strftime('%d%m%y'),
              password_confirmation: @citizen.birth_date.strftime('%d%m%y')
            })

            @account.save
          rescue ActiveRecord::RecordNotUnique
            error_message = [I18n.t(
              "devise_token_auth.registrations.email_already_exists", email: @citizen.cpf
            )]
          end

          raise_rollback.call(error_message)

          # Assign new account to new citizen
          @citizen.account_id = @account.id

          error_message = @citizen.errors.to_hash if not @citizen.save
          raise_rollback.call(error_message)


          # Creates professional
          @professional = Professional.new(professional_params)

          @professional.account_id = @account.id
          @professional.active = true

          error_message = @professional.errors.to_hash if not @professional.save
          raise_rollback.call(error_message)


          # Creates professionals service places
          params[:professional][:roles].each do |item|
            psp = ProfessionalsServicePlace.new({
              professional_id: @professional.id, 
              service_place_id: item[:service_place_id],
              role: item[:role]
            })

            begin
              authorize psp, :create_psp?
            rescue
              error_message =  ["You're not allowed to register this professional in the given service place."]
            end
            raise_rollback.call(error_message)

            error_message = psp.errors.to_hash.merge(full_messages: psp.errors.full_messages) if not psp.save
            raise_rollback.call(error_message)
          end

          success = true
        end # End Transaction

      else # If the citizen already exists
        ActiveRecord::Base.transaction do
          @account = Account.find_by(uid: params[:cpf])
        
          if @account.nil?
            render json: {
              errors: "Account #{params[:cpf]} doesn't exist."
            }, status: 404
            return
          end

          @professional = Professional.new(professional_params)
          @professional.account_id = Account.find_by(uid: params[:cpf]).id
          @professional.active = true

          error_message = @professional.errors.to_hash if not @professional.save
          raise_rollback.call(error_message)

          # Creates professionals service places
          params[:professional][:roles].each do |item|
            psp = ProfessionalsServicePlace.new({
              professional_id: @professional.id, 
              service_place_id: item[:service_place_id],
              role: item[:role]
            })

            begin
              authorize psp, :create_psp?
            rescue
              error_message =  ["You're not allowed to register this professional in the given service place."]
            end
            raise_rollback.call(error_message)

            error_message = psp.errors.to_hash.merge(full_messages: psp.errors.full_messages) if not psp.save
            raise_rollback.call(error_message)
          end

          success = true
        end # End Transaction
      end

      if success
        render json: @professional.complete_info_response, status: :created
      else
        render json: {
          errors: error_message 
        }, status: 422
      end
    end

    # PATCH/PUT /professionals/1
    def update
      if @professional.nil?
        render json: {
          errors: ["Professional #{params[:id]} does not exist."]
        }, status: 404
      else
        authorize @professional, :update?

        error_message = nil
        raise_rollback = -> (error) { raise ActiveRecord::Rollback if not error.nil? }

        ActiveRecord::Base.transaction do
          ProfessionalsServicePlace.where(professional_id: @professional.id).destroy_all

          # Creates professionals service places
          params[:professional][:roles].each do |item|
            psp = ProfessionalsServicePlace.new({
              professional_id: @professional.id, 
              service_place_id: item[:service_place_id],
              role: item[:role]
            })

            begin
              authorize psp, :create_psp?
            rescue
              error_message = ["You're not allowed to register this professional in the given service place."]
            end
            raise_rollback.call(error_message)

            error_message = psp.errors.to_hash.merge(
              full_messages: psp.errors.full_messages
            ) if not psp.save

            raise_rollback.call(error_message)
          end

          error_message = @professional.errors if not @professional.update(professional_params)
          raise_rollback.call(error_message)

          error_message = @professional
            .citizen.errors if not @professional.citizen.update(citizen_params)
          raise_rollback.call(error_message)
        end

        if error_message.nil?
          render json: @professional.complete_info_response
        else
          render json: {
            errors: error_message 
          }, status: 422
          return
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
        authorize @professional, :deactivate?

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
      when "create?"
        render json: {
          errors: ["You're not allowed to create this professional."]
        }, status: 403
      when "deactivate?"
        render json: {
          errors: ["You're not allowed to delete this professional."]
        }, status: 403
      when "update?"
        render json: {
          errors: ["You're not allowed to update this professional."]
        }, status: 403
      when "create_psp?"
        render json: {
          errors: ["You're not allowed to register this professional in the given service place."]
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

    def citizen_params
      params.require(:professional).permit(
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

    # Only allow a trusted parameter "white list" through.
    def professional_params
      params.require(:professional).permit(
        :active,
        :occupation_id,
        :registration
      )
    end
  end
end
