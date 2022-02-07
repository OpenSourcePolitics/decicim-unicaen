# frozen_string_literal: true

require "omniauth/strategies/unicaen"

Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth.config.logger = Rails.logger

  omniauth_config = Rails.application.secrets[:omniauth]

  if omniauth_config[:cas].present?
    provider(
      OmniAuth::Strategies::Unicaen,
      setup: setup_provider_proc(:cas,
                                 host: :host)
    )
  end
end
