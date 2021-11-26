# frozen_string_literal: true

require "omniauth-cas"

module OmniAuth
  module Strategies
    class Unicaen < OmniAuth::Strategies::CAS
      option :name, :cas
      option :origin_param, "redirect_url"
      option :service_validate_url, "/p3/serviceValidate"

      option :first_name_key, "givenName"
      option :last_name_key, "sn"
      option :email_key, "mail"
      option :status_key, "ucbnStatus"

      # As required by https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
      # rubocop:disable Naming/ConstantName
      AuthHashSchemaKeys = %w(name email nickname first_name last_name location image phone status).freeze
      # rubocop:enable Naming/ConstantName
      info do
        Rails.logger.debug raw_info
        prune!(
          name: raw_info[options[:first_name_key].to_s],
          email: raw_info[options[:email_key].to_s],
          nickname: raw_info[options[:nickname_key].to_s],
          first_name: raw_info[options[:first_name_key].to_s],
          last_name: raw_info[options[:last_name_key].to_s],
          location: raw_info[options[:location_key].to_s],
          image: raw_info[options[:image_key].to_s],
          phone: raw_info[options[:phone_key].to_s],
          status: raw_info[options[:status_key].to_s]
        )
      end
    end
  end
end
