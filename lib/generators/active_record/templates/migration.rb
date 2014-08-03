class TwoFactorAuthenticationAddTo<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    change_table :<%= table_name %> do |t|
      t.string   :unconfirmed_phone_number
      t.string   :confirmation_token
      t.datetime :sms_confirmed_at
      t.datetime :sms_confirmation_sent_at
    end
  end
end
