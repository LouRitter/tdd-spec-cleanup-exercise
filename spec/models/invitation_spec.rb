require "rails_helper"

RSpec.describe Invitation do

  describe "callbacks" do
    describe "after_save" do
      context "with valid data" do
        it "invites the user" do
          team = Team.new(name: "A fine team")
          new_user = User.new(email: "rookie@example.com")

          invitation = Invitation.new(team: team, user: new_user)
          invitation.save
          expect(new_user).to be_invited
        end
      end

      context "with invalid data" do

        it "does not save the invitation" do
          new_user = User.new(email: "rookie@example.com")

          invitation = Invitation.new(user: new_user)
          invitation.save

          expect(invitation).not_to be_valid
          expect(invitation).to be_new_record
        end

        it "does not mark the user as invited" do
          new_user = User.new(email: "rookie@example.com")

          expect(new_user).not_to be_invited
        end
      end
    end
  end

  describe "#event_log_statement" do
    context "when the record is saved" do

      it "include the name of the team" do
        team = Team.new(name: "A fine team")
        new_user = User.new(email: "rookie@example.com")

        invitation = Invitation.new(team: team, user: new_user)
        invitation.save
        log_statement = invitation.event_log_statement
        expect(log_statement).to include("A fine team")
      end

      it "include the email of the invitee" do
        team = Team.new(name: "A fine team")
        new_user = User.new(email: "rookie@example.com")

        invitation = Invitation.new(team: team, user: new_user)
        invitation.save
        log_statement = invitation.event_log_statement

        expect(log_statement).to include("rookie@example.com")
      end
    end

    context "when the record is not saved but valid" do
      it "includes the name of the team" do
        team = Team.new(name: "A fine team")
        new_user = User.new(email: "rookie@example.com")

        invitation = Invitation.new(team: team, user: new_user)

        log_statement = invitation.event_log_statement
        expect(log_statement).to include("A fine team")
      end

      it "includes the email of the invitee" do
        team = Team.new(name: "A fine team")
        new_user = User.new(email: "rookie@example.com")

        invitation = Invitation.new(team: team, user: new_user)
        log_statement = invitation.event_log_statement
        
        expect(log_statement).to include("rookie@example.com")
      end

      it "includes the word 'PENDING'" do
        team = Team.new(name: "A fine team")
        new_user = User.new(email: "rookie@example.com")

        invitation = Invitation.new(team: team, user: new_user)
        log_statement = invitation.event_log_statement
        expect(log_statement).to include("PENDING")
      end
    end

    context "when the record is not saved and not valid" do
      it "includes INVALID" do
        team = Team.new(name: "A fine team")
        invitation = Invitation.new(team: team, user: nil)
        invitation.user = nil
        log_statement = invitation.event_log_statement
        expect(log_statement).to include("INVALID")
      end
    end
  end
end
