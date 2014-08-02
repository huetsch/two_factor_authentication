require 'two_factor_authentication/hooks/two_factor_authenticatable'
module Devise
  module Models
    module TwoFactorAuthenticatable
      extend ActiveSupport::Concern

      included do
        before_create :populate_otp_secret_key
      end

      def self.required_fields(klass)
        required_methods = [:phone_number, :confirmation_token, :confirmed_at, :confirmation_sent_at, :otp_secret_key, :second_factor_attempts_count]
        required_methods << :unconfirmed_phone_number if klass.reconfirmable
        required_methods
      end

      def authenticate_otp(code, options = {})
        totp = ROTP::TOTP.new(self.otp_secret_key)
        drift = options[:drift] || self.class.allowed_otp_drift_seconds

        totp.verify_with_drift(code, drift)
      end

      def otp_code(time = Time.now)
        ROTP::TOTP.new(self.otp_secret_key).at(time, true)
      end

      def provisioning_uri(account = nil, options = {})
        account ||= self.email if self.respond_to?(:email)
        ROTP::TOTP.new(self.otp_secret_key, options).provisioning_uri(account)
      end

      def need_two_factor_authentication?(request)
        true
      end

      def send_two_factor_authentication_code
        raise NotImplementedError.new("No default implementation - please define in your class.")
      end

      def max_login_attempts?
        second_factor_attempts_count.to_i >= max_login_attempts.to_i
      end

      def max_login_attempts
        self.class.max_login_attempts
      end

      def populate_otp_secret_key
        self.otp_secret_key = ROTP::Base32.random_base32
      end
    end
  end
end
