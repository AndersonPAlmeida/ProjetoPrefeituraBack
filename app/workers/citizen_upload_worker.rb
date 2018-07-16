class CitizenUploadWorker
  include Sidekiq::Worker
  require 'csv'
  require 'json'

  sidekiq_options :queue => :citizens_upload

  def perform(upload_id, content, permission, city_id)
    # Batch size for upload
    batch_size = 100

    # Batch counter
    batch_counter = 0

    # Columns for citizens
    columns = [:name, :cpf, :rg, :birth_date, :cep,
               :address_number, :address_complement,
               :phone1, :phone2, :email, :pcd, :note, :active]

    # Complete list of columns for citizens
    complete = [:name, :cpf, :rg, :birth_date, :cep, :address_street,
                :address_number, :neighborhood, :address_complement, :city_id,
                :phone1, :phone2, :email, :pcd, :note, :active]

    # Columns for accounts
    account_columns = [:uid, :provider, :encrypted_password]

    # Update task status to in progress
    CitizenUpload.update(
      upload_id,
      status: 1 # parsing content
    )

    # Line number starts with one
    line_number = 1
    # Hash with errors
    errors = Array.new
    # Buffer containing users to create
    to_create = Array.new
    # Buffer containing accounts to create
    account_to_create = Array.new

    begin
      # Parse citizens from the CSV data
      citizens = CSV.parse(content).map { |row| Hash[columns.zip(row)] }

      # Remove headers
      citizens = citizens.drop(1)

      # Number of citizens to be uploaded
      upload_size = citizens.length
    rescue
      # Set citizens to nil
      citizens = []

      # Upload size is zero
      upload_size = 1

      # Add parsing error to log
      errors.push([
        0,
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        "Could not parse CSV file!"
      ])
    end

    # Update task status to in progress
    CitizenUpload.update(
      upload_id,
      amount: upload_size,
      status: 2 # in progress
    )

    # Go through each citizen in the list
    citizens.each do |citizen_params|
      # Set active parameter
      citizen_params[:active] = true

      # Create citizen object with defined parameters
      citizen = Citizen.new(citizen_params)

      # Create account object with defined parameters
      account = Account.new({
        uid: citizen.cpf,
        provider: "cpf"
      })

      # Citizen remaining info is added when .valid? method is called
      if citizen.valid?
        # Create default password for current citizen
        account.password = citizen.birth_date.strftime('%d%m%y')
      end

      # Check if account is valid
      if account.valid?
        # Check for permissions on the citizen to be added
        if permission != "adm_c3sl" and citizen.city_id != city_id
          # If there was a permission error, store it in the errors hash
          errors.push([
            line_number,
            citizen_params[:name],
            citizen_params[:cpf],
            citizen_params[:rg],
            citizen_params[:birth_date],
            citizen_params[:cep],
            citizen_params[:address_number],
            citizen_params[:address_complement],
            citizen_params[:phone1],
            citizen_params[:phone2],
            citizen_params[:email],
            citizen_params[:pcd],
            citizen_params[:note],
            "Permission denied for this city"
          ])

        else
          # Add valid citizen with complete info to to_create array
          inst = [
            citizen.name,
            citizen.cpf,
            citizen.rg,
            citizen.birth_date,
            citizen.cep,
            citizen.address_street,
            citizen.address_number,
            citizen.neighborhood,
            citizen.address_complement,
            citizen.city_id,
            citizen.phone1,
            citizen.phone2,
            citizen.email,
            citizen.pcd,
            citizen.note,
            citizen.active
          ]

          # Add valid account with complete info to to_create array
          acc_inst = [
            account.uid,
            account.provider,
            account.encrypted_password
          ]

          # Insert current citizen data to buffer of citizens to create
          to_create.append(inst)
          # Insert current account data to buffer of accounts to create
          account_to_create.append(acc_inst)
        end

      else
        # Go through error messages
        citizen.errors.full_messages.each do |message|
          # Add current error in the list of errors
          errors.push([
            line_number,
            citizen_params[:name],
            citizen_params[:cpf],
            citizen_params[:rg],
            citizen_params[:birth_date],
            citizen_params[:cep],
            citizen_params[:address_number],
            citizen_params[:address_complement],
            citizen_params[:phone1],
            citizen_params[:phone2],
            citizen_params[:email],
            citizen_params[:pcd],
            citizen_params[:note],
            message
          ])
        end
      end

      # Increase bath counter
      batch_counter += 1

      # If already reach batch size limit
      if batch_counter >= batch_size
        # Import citizens of current batch to database
        Citizen.transaction do
          Citizen.import complete, to_create, validate: true
        end

        # Import accounts of current batch to database
        Account.transaction do
          Account.import account_columns, account_to_create, validate: true
        end

        # Update task progress
        CitizenUpload.update(
          upload_id,
          progress: ((line_number - 1).to_f / upload_size.to_f) * 100.0
        )

        # Reset buffer containing citizens to create
        to_create = Array.new
        # Reset buffer containing accounts to create
        account_to_create = Array.new
        # Reset batch counter
        batch_counter = 0
      end

      # Increase line number
      line_number += 1
    end

    # If batch isn't empty
    if batch_counter > 0
      # Import remaining citizens to database
      Citizen.transaction do
        Citizen.import complete, to_create, validate: true
      end

      # Import remaining accounts to database
      Account.transaction do
        Account.import account_columns, account_to_create, validate: true
      end
    end

    # New status to update
    new_status = 3 # completed with no errors

    # If there were errors, change status to completed with errors
    if errors.size > 0
      new_status = 4 # completed with errors
    end

    # Update upload object progress
    CitizenUpload.update(
      upload_id,
      status: new_status,
      progress: 100.0
    )

    # Get CSV path
    path = "#{Rails.root.to_s}/tmp/citizen_uploads/#{upload_id}.csv"

    # Open log CSV file for writing the log
    CSV.open(path, "wb") do |csv|
      # Add headers to log
      csv << [
        "Linha", "Nome", "CPF", "RG", "Data de Nascimento", "CEP",
        "Numero", "Complemento", "Telefone 1", "Telefone 2", "E-mail",
        "Deficiencia", "Observacao", "Erro"
      ]

      # Go through the errors to add them into the log
      errors.each do |error|
        csv << error
      end
    end

    # Create upload object to save log
    upload_object = CitizenUpload.find(upload_id)
    upload_object.log = File.open(path)
    upload_object.save!
  end
end
