class ChangeGenderTypeFromUsers < ActiveRecord::Migration
  def change
    change_column :users, :gender, :integer
  end
end
