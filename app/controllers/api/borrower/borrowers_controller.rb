class Api::Borrower::BorrowersController < ApplicationController
  
  def index
    borrowers = Borrower.all
    render json: borrowers.as_json(only: [:id, :name, :email, :created_at])
  end
end
