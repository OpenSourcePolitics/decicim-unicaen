# frozen_string_literal: true

require "spec_helper"

describe "Authentication", type: :system do
  let(:organization) { create(:organization) }
  let(:last_user) { Decidim::User.last }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  describe "Sign Up" do
    context "user can't log in without SSO" do
      it "creates a new User" do
        find(".sign-up-link").click

        expect(page).not_to have_css(".new_user")
      end
    end

    context "when using CAEN CAS" do
      let(:omniauth_hash) do
        OmniAuth::AuthHash.new(
          provider: "cas",
          uid: "123545",
          info: {
            name: "Example user",
            email: "cas@example.org"
          }
        )
      end

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:cas] = omniauth_hash
      end

      after do
        OmniAuth.config.test_mode = false
        OmniAuth.config.mock_auth[:cas] = nil
      end

      it "creates a new User" do
        find(".sign-up-link").click

        click_link "Sign in with Cas"

        expect_user_logged
      end
    end

    context "when sign up is disabled" do
      let(:organization) { create(:organization, users_registration_mode: :existing) }

      it "redirects to the sign in when accessing the sign up page" do
        visit decidim.new_user_registration_path
        expect(page).not_to have_content("Sign Up")
      end

      it "don't allow the user to sign up" do
        find(".sign-in-link").click
        expect(page).not_to have_content("Create an account")
      end
    end
  end

  describe "Confirm email" do
    it "confirms the user" do
      perform_enqueued_jobs { create(:user, organization: organization) }

      visit last_email_link

      expect(page).to have_content("successfully confirmed")
      expect(last_user).to be_confirmed
    end
  end

  context "when confirming the account" do
    let!(:user) { create(:user, email_on_notification: true, organization: organization) }

    before do
      perform_enqueued_jobs { user.confirm }
      switch_to_host(user.organization.host)
      login_as user, scope: :user
      visit decidim.root_path
    end

    it "sends a welcome notification" do
      find("a.topbar__notifications").click

      within "#notifications" do
        expect(page).to have_content("Welcome")
        expect(page).to have_content("thanks for joining #{organization.name}")
      end

      expect(last_email_body).to include("thanks for joining #{organization.name}")
    end
  end

  describe "Resend confirmation instructions" do
    let(:user) do
      perform_enqueued_jobs { create(:user, organization: organization) }
    end

    it "sends an email with the instructions" do
      visit decidim.new_user_confirmation_path

      within ".new_user" do
        fill_in :confirmation_user_email, with: user.email
        perform_enqueued_jobs { find("*[type=submit]").click }
      end

      expect(emails.count).to eq(2)
      expect(page).to have_content("receive an email with instructions")
    end
  end

  context "when a user is already registered with a social provider" do
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:identity) { create(:identity, user: user, provider: "cas", uid: "12345") }

    let(:omniauth_hash) do
      OmniAuth::AuthHash.new(
        provider: identity.provider,
        uid: identity.uid,
        info: {
          email: user.email,
          name: "Example user",
          verified: true
        }
      )
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:cas] = omniauth_hash
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:cas] = nil
    end

    describe "Sign in" do
      it "authenticates an existing User" do
        find(".sign-in-link").click

        click_link "Sign in with Cas"

        expect(page).to have_content("Successfully")
        expect(page).to have_content(user.name)
      end

      context "when sign up is disabled" do
        let(:organization) { create(:organization, users_registration_mode: :existing) }

        it "doesn't allow the user to sign up" do
          find(".sign-in-link").click
          expect(page).not_to have_content("Sign Up")
        end
      end

      context "when sign in is disabled" do
        let(:organization) { create(:organization, users_registration_mode: :disabled) }

        it "doesn't allow the user to sign up" do
          find(".sign-in-link").click
          expect(page).not_to have_content("Sign Up")
        end

        it "doesn't allow the user to sign in as a regular user, only through external accounts" do
          find(".sign-in-link").click
          expect(page).not_to have_content("Email")
          expect(page).to have_css(".button--cas")
        end

        it "authenticates an existing User" do
          find(".sign-in-link").click

          click_link "Sign in with Cas"

          expect(page).to have_content("Successfully")
          expect(page).to have_content(user.name)
        end
      end
    end
  end
end
