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
  class CitizenUploadsController < ApplicationController
    include Authenticable
    include HasPolicies
    require 'csv'

    before_action :set_citizen_upload, only: [:show, :destroy]

    # GET /citizen_uploads
    def index
      # Current citizen id
      citizen_id = current_user[0][:id]

      # Permission
      permission = Professional.get_permission(current_user[1])

      @resource_booking = policy_scope(ResourceBooking.filter(
        params[:q], params[:page], params[:permission]))

      # Find uploads for current citizen
      @uploads = policy_scope(CitizenUpload.filter(
        params[:q], params[:page], permission))

      # Check if uploads are not null for current citizen
      if @uploads.nil?
        render json: {
          # errors: ["You don't have the permission to view citizen uploads."]
          errors: ["Você não tem permissão para visualizar os uploads de cidadão!"]
        }, status: 403
        return
      end

      # Sort uploads by date in descending order
      @uploads = @uploads.order("created_at DESC")

      # Uploads with professional id
      uploads_with_professional = @uploads.as_json

      # Add professional id to uploads
      uploads_with_professional.each do |upload|
        upload_citizen = Citizen.find(upload['citizen_id'])
        professional = Professional.where(account_id: upload_citizen.account_id).first

        upload[:professional_id] = professional.id
      end

      # Create response object
      response = Hash.new
      response[:num_entries] = @uploads.total_count
      response[:entries] = uploads_with_professional

      # Render uploads in JSON format
      render json: response.to_json
    end

    # GET /citizen_uploads/1
    def show
      if @upload_id.nil?
        render json: {
          errors: ["Upload task #{params[:upload_id]} does not exist."]
        }, status: 404

      else
        begin
          authorize @upload_id, :show?
        rescue
          render json: {
            # errors: ["You're not allowed to view this citizen upload log."]
            errors: ["Você não tem permissão para visualizar este log de upload de cidadão!"]
          }, status: 403
          return
        end

        # Upload log path
        path = @upload_id.log.path

        # If log not found, displays not found message
        if path.nil?
          render json: {
            # errors: ["Log not found for current task."]
            errors: ["Log não encontrado para tarefa atual!"]
          }, status: 404

        # Otherwise, send file
        else
          send_file path,
            type: @upload_id.log_content_type,
            disposition: 'inline'
        end
      end
    end

    # POST /citizen_uploads
    def create
      # Current citizen id
      citizen = current_user[0]

      # Current citizen id
      citizen_id = citizen[:id]

      # Permission
      permission = Professional.get_permission(current_user[1])

      # City for current permission
      city_id = citizen.professional.professionals_service_places.find(
        current_user[1]).service_place.city_id

      # Data must be defined in the parameters
      if params.has_key?(:file) and params[:file].present?
        # File content
        content = params[:file].read

        # Create upload object
        upload_object = CitizenUpload.new({
          citizen_id: citizen_id,
          status: 0, # ready to start
          amount: 0,
          progress: 0.0
        })

        begin
          authorize upload_object, :create?
        rescue
          render json: {
            # errors: ["You're not allowed to perform citizen uploads."]
            errors: ["Você não tem permissão para fazer upload de cidadão!"]
          }, status: 403
          return
        end

        # Save upload object in the database
        upload_object.save()

        # Create sidekiq job for uploading the citizens
        CitizenUploadWorker.perform_async(upload_object.id, content, permission, city_id)

        render json: {
          # errors: ["Citizens scheduled to be imported!"]
          errors: ["Cidadãos agendados para serem importados!"]
        }, status: 201
      else
        render json: {
          # errors: ["Undefined citizens to import."]
          errors: ["Cidadãos para importar indefinidos!"]
        }, status: 404
      end
    end

    # DELETE /citizen_uploads/1
    def destroy
    end

    # GET /citizen_uploads/example_file_xls
    def example_xls
      filename = "#{Rails.root.to_s}/public/citizen_upload_example.xls"
      content_type = "application/xls"

      send_file filename, :type => content_type, :x_sendfile => true
    end

    # GET /citizen_uploads/example_file_ods
    def example_ods
      filename = "#{Rails.root.to_s}/public/citizen_upload_example.ods"
      content_type = "application/vnd.oasis.opendocument.spreadsheet"

      send_file filename, :type => content_type, :x_sendfile => true
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_citizen_upload
      begin
        @upload_id = CitizenUpload.find(params[:id])
      rescue
        @upload_id = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def citizen_upload_params
      params.permit(:file)
    end
  end
end
