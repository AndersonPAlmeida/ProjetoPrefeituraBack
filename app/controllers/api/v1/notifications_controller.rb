module Api::V1
  class NotificationsController < ApplicationController
    include Authenticable
    before_action :set_notification, only: [:show, :update, :destroy]
      
    # GET /notifications 
    def index
      @notifications = Notification.where(account_id: current_user.first.account_id)
        .where(read: false)
      
      render json: @notifications
    end

    # POST /notifications 
    def create
      notification = notification_params

      if notification["account_id"] == nil 
        notification["account_id"] = current_user.first.account_id
      else         
        notification["account_id"] = Citizen.where(account_id:notification["account_id"]).first.id
      end   

      @notification = Notification.new(notification)

      authorize @notification, :create?

      if @notification.save
        render json: @notification, status: :created            
      else
        render json: @notification.errors, status: :unprocessable_entity
      end
    end
  
    # GET /notifications/:id 
    def show
      if @notification.nil?
        render json: {
        errors: ["Notification #{params[:id]} does not exist."]
        }, status: 404
      else
        authorize @notification, :show?        

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
        authorize @notification, :update?

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
        authorize @notification, :update?
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
      params.require(:notification).permit(
          :account_id,
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
