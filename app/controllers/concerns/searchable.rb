module Searchable 
  extend ActiveSupport::Concern

  def search_function
    func = -> (record, cparams) {
      return record.ransack(cparams).result
        .page(params[:page]).per(20)
    }

    return func
  end
end
