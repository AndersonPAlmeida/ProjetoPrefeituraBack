class CitizenUploadWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :citizens_upload

  def perform(upload_id, upload_size, citizens)
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

    # Line number starts with one
    line_number = 1
    # Hash with errors
    errors = Hash.new
    # Buffer containing users to create
    to_create = Array.new
    # Buffer containing accounts to create
    account_to_create = Array.new

    # Update task status to in progress
    CitizenUpload.update(
      upload_id,
      status: 1 # in progress
    )

    # Go through each citizen in the list
    citizens.each do |c|
      # Parameters for current line
      upload_params = Hash[columns.zip(c)]
      # Create citizen object with defined parameters
      citizen = Citizen.new(upload_params)

      # Create account object with defined parameters
      account = Account.new({
        uid: citizen.cpf,
        provider: "cpf"
      })

      # Create default password for current citizen
      account.password = citizen.birth_date.strftime('%d%m%y')

      # Citizen remaining info is added when .valid? method is called
      if citizen.valid? and account.valid?
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
      else
        # If there was an error, store it in the errors hash
        errors[line_number.to_s] = citizen.errors.to_hash
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
    new_status = 2 # completed with no errors

    # If there were errors, change status to completed with errors
    if errors.size > 0
      new_status = 3 # completed with errors
    end

    # Update upload object progress
    CitizenUpload.update(
      upload_id,
      status: new_status,
      progress: 100.0
    )

    # Initialize log content buffer
    log_content = StringIO.new("Line,Error Message\n")

    # Go through each error and write it in the log file
    errors.each do |line, message|
      log_content.puts "%d,%s\n" % [line, message]
    end

    # Create upload object to save log
    upload_object = CitizenUpload.find(upload_id)
    upload_object.log = log_content
    upload_object.save
  end
end
