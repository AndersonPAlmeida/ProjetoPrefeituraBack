module Api::V1
  class NotificationsController < ApplicationController
    include Authenticable
    before_action :set_notification, only: [:show, :update, :destroy]
      
    # GET /notifications 
    def index
      @notifications = Notification.all 
      render json: @notifications
    end

    # POST /notifications 
    def create
      @notification = Notification.create!(notification_params)
      render json: @notification, status: :created            
    end
  
    # GET /notifications/:id 
    def show
      if @notification.nil?
        render json: {
        errors: ["Notification #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @notification
      end
    end

    # PATCH/PUT /notifications/1 
    def update
      if @notification.nil?
        render json: {
        errors: ["Notification #{params[:id]} does not exist."]
        }, status: 404
      else
        if @notification.update(notification_params)
          render json: @notification
        else
          render json: @notification.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /notifications/1  (It does not remove the entry. It just change the read field )
    def destroy
      if @notification.nil?
        render json: {
            errors: ["Notification #{params[:id]} does not exist."]
        }, status: 404
      else
        @notification.read = true
        @notification.save!
      end
    end


    private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      begin
        @notification = Notification.find(params[:id])
      rescue
        @notification = nil
      end
    end
    
    # Only allow a trusted parameter "white list" through.
    def notification_params
      params.permit(
          :accounts_id,
          :schedule_id,
          :resource_schedule_id,
          :reminder_time,
          :read,
          :content,
          :reminder_email,
          :reminder_email_sent          
      )
    end
  end
end