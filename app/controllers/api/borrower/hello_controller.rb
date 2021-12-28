class Api::Borrower::HelloController < ApplicationController

  def index
    render json: "Hello"
  end
  
end
