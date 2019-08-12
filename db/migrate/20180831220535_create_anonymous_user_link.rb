# frozen_string_literal: true

class CreateAnonymousUserLink < ActiveRecord::Migration[5.2]
  def change
    create_table :anonymous_user_links do |t|
      t.references :user, null: false, index: { unique: true }, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :parent_user, null: false, index: { unique: true, where: "deactivated_at IS NULL" }, foreign_key: { to_table: :users, on_delete: :cascade }
      t.column :last_used_at, :datetime, null: false
      t.column :created_at, :datetime, null: false
      t.column :deactivated_at, :datetime
    end
  end
end
