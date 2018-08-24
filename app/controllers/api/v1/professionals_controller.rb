# This file is part of Agendador.
#
# Agendador is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Agendador is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Agendador.  If not, see <https://www.gnu.org/licenses/>.

module Api::V1
  class ProfessionalsController < ApplicationController
    include Authenticable
    include HasPolicies

    require "#{Rails.root}/lib/image_parser.rb"

    before_action :set_professional, only: [:show, :update, :destroy]

    # GET /professionals
    def index
      @professionals = policy_scope(Professional.filter(params[:q], params[:page],
        Professional.get_permission(current_user[1])))


      if @professionals.nil?
        render json: {
          # errors: ["You don't have the permission to view professionals."]
          errors: ["Você não tem permissão para listar profissionais!"]
        }, status: 403
      else
        response = Hash.new
        response[:num_entries] = @professionals.total_count
        response[:entries] = @professionals.index_response

        render json: response.to_json
      end
    end


    # GET professionals/check_citizen
    def check_create_professional
      cpf = params[:cpf]

      if not CpfValidator.validate_cpf(cpf)
        render json: {
          # errors: ["The given cpf is not valid."]
          errors: ["O CPF informado não é válido!"]
        }, status: 422
        return
      end

      @citizen = Citizen.find_by(cpf: cpf)

      if @citizen.nil?
        render json: {
          # errors: ["The citizen doesn't exist."]
          errors: ["O cidadão não existe!"]
        }, status: 404
      else
        if @citizen.professional.nil?
          render json: @citizen.complete_info_response
        else
          render json: {
            # errors: ["The citizen is already a professional."]
            errors: ["O cidadão já é um profissional!"]
          }, status: 409
        end
      end
    end


    # GET /professionals/1
    def show
      if @professional.nil?
        render json: {
          # errors: ["Professional #{params[:id]} does not exist."]
          errors: ["Profissional #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @professional, :show?
        rescue
          render json: {
            # errors: ["You're not allowed to view this professional."]
            errors: ["Você não tem permissão para visualizar este profissional!"]
          }, status: 403
          return
        end

        render json: @professional.complete_info_response
      end
    end


    # POST /professionals
    def create
      success = false
      error_message = nil

      # Check if the roles list is not empty, if it is, displays
      # an error message
      if params[:professional][:roles].blank?
        render json: {
          # errors: ["You must inform at least one role!"]
          errors: ["É necessário informar pelo menos uma permissão!"]
        }, status: 422
        return
      end

      raise_rollback = -> (error) {
        error_message = error
        raise ActiveRecord::Rollback
      }

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
            raise_rollback.call([I18n.t(
              "devise_token_auth.registrations.email_already_exists", email: @citizen.cpf
            )])
          end

          # Add avatar if provided
          if params[:image]
            begin
              params[:image] = Agendador::Image::Parser.parse(params[:image])
              @citizen.avatar = params[:image]
            ensure
              Agendador::Image::Parser.clean_tempfile
            end
          end

          # Assign new account to new citizen
          @citizen.account_id = @account.id
          raise_rollback.call(@citizen.errors.to_hash) unless @citizen.save

          # Creates professional
          @professional = Professional.new(professional_params)

          @professional.account_id = @account.id
          @professional.active = true
          raise_rollback.call(@professional.errors.to_hash) unless @professional.save

          # Professional service places list
          psp_id_list = []

          # Creates professionals service places
          params[:professional][:roles].each do |item|
            psp = ProfessionalsServicePlace.new({
              professional_id: @professional.id,
              service_place_id: item[:service_place_id],
              role: item[:role]
            })

            if psp_id_list.include?(item[:service_place_id])
              # raise_rollback.call(["Only one role per service place is allowed"])
              raise_rollback.call(["Apenas uma role por local de atendimento é permitido!"])
            end

            psp_id_list << item[:service_place_id]

            begin
              authorize psp, :create_psp?
            rescue
              # raise_rollback.call(
              #   ["You're not allowed to register this professional in the given service place."]
              # )
              raise_rollback.call(
                ["Você não tem permissão para registrar este profissional no local de atendimento informado!"]
              )
            end

            raise_rollback.call(
              psp.errors.to_hash.merge(full_messages: psp.errors.full_messages)
            ) unless psp.save
          end

          success = true
        end # End Transaction

      else # If the citizen already exists
        ActiveRecord::Base.transaction do
          @account = Account.find_by(uid: params[:cpf])

          if @account.nil?
            render json: {
              # errors: "Account #{params[:cpf]} doesn't exist."
              errors: "Conta #{params[:cpf]} não existe!"
            }, status: 404
            return
          end

          @professional = Professional.new(professional_params)
          @professional.account_id = Account.find_by(uid: params[:cpf]).id
          @professional.active = true

          raise_rollback.call(@professional.errors.to_hash) unless @professional.save

          psp_id_list = []
          # Creates professionals service places
          params[:professional][:roles].each do |item|
            psp = ProfessionalsServicePlace.new({
              professional_id: @professional.id,
              service_place_id: item[:service_place_id],
              role: item[:role]
            })

            if psp_id_list.include?(item[:service_place_id])
              # raise_rollback.call(["Only one role per service place is allowed"])
              raise_rollback.call(["Apenas uma role por local de atendimento é permitido!"])
            end

            psp_id_list << item[:service_place_id]

            begin
              authorize psp, :create_psp?
            rescue
              # raise_rollback.call(
              #   ["You're not allowed to register this professional in the given service place."]
              # )
              raise_rollback.call(
                ["Você não tem permissão para registrar este profissional no local de atendimento informado!"]
              )
            end

            raise_rollback.call(
              psp.errors.to_hash.merge(full_messages: psp.errors.full_messages)
            ) unless psp.save
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
          # errors: ["Professional #{params[:id]} does not exist."]
          errors: ["Profissional #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @professional, :update?
        rescue
          render json: {
            # errors: ["You're not allowed to update this professional."]
            errors: ["Você não tem permissão para atualizar este profissional!"]
          }, status: 403
          return
        end

        error_message = nil

        raise_rollback = -> (error) {
          error_message = error
          raise ActiveRecord::Rollback
        }

        ActiveRecord::Base.transaction do
          raise_rollback.call(@professional.citizen
            .errors.to_hash) unless @professional.citizen.update(citizen_params)

          ProfessionalsServicePlace.where(professional_id: @professional.id).destroy_all

          psp_id_list = []

          # Creates professionals service places
          params[:professional][:roles].each do |item|
            psp = ProfessionalsServicePlace.new({
              professional_id: @professional.id,
              service_place_id: item[:service_place_id],
              role: item[:role]
            })

            if psp_id_list.include?(item[:service_place_id])
              # raise_rollback.call(["Only one role per service place is allowed"])
              raise_rollback.call(["Apenas uma role por local de atendimento é permitido!"])
            end

            psp_id_list << item[:service_place_id]

            begin
              authorize psp, :create_psp?
            rescue
              # raise_rollback.call(
              #   ["You're not allowed to register this professional in the given service place."]
              # )
              raise_rollback.call(
                ["Você não tem permissão para registrar este profissional no local de atendimento informado!"]
              )
            end

            raise_rollback.call(
              psp.errors.to_hash.merge(full_messages: psp.errors.full_messages)
            ) unless psp.save
          end

          raise_rollback.call(@professional.errors) unless @professional.update(professional_params)
          raise_rollback
            .call(@professional.citizen.errors) unless @professional.citizen.update(citizen_params)
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
          # errors: ["Professional #{params[:id]} does not exist."]
          errors: ["Profissional #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @professional, :deactivate?
        rescue
          render json: {
            # errors: ["You're not allowed to delete this professional."]
            errors: ["Você não tem permissão para remover este profissional!"]
          }, status: 403
          return
        end

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
      when "create?"
        render json: {
          # errors: ["You're not allowed to create this professional."]
          errors: ["Você não tem permissão para criar este profissional!"]
        }, status: 403
      when "deactivate?"
      when "update?"
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
