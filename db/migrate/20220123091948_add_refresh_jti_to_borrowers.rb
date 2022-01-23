class AddRefreshJtiToBorrowers < ActiveRecord::Migration[7.0]
  def change
    add_column :borrowers, :refresh_jti, :string
  end
end
