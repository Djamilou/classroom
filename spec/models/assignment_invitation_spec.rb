# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentInvitation, type: :model do
  subject { create(:assignment_invitation) }

  it_behaves_like "a default scope where deleted_at is not present"

  it "should have a key after initialization" do
    assignment_invitation = build(:assignment_invitation)
    expect(assignment_invitation.key).to_not be_nil
  end

  it "should have a status after initialization" do
    assignment_invitation = build(:assignment_invitation)
    expect(assignment_invitation.status).to eq("unaccepted")
  end

  it "is errored? when errored_creating_repo!" do
    assignment_invitation = build(:assignment_invitation)
    assignment_invitation.errored_creating_repo!
    expect(assignment_invitation.errored?).to be_truthy
  end

  it "is errored? when errored_creating_repo!" do
    assignment_invitation = build(:assignment_invitation)
    assignment_invitation.errored_importing_starter_code!
    expect(assignment_invitation.errored?).to be_truthy
  end

  it "shouldn't invalidate old records" do
    assignment_invitation = AssignmentInvitation.create(status: nil, assignment: subject.assignment)
    expect(assignment_invitation.errors).to be_empty
    expect(assignment_invitation.valid?).to be_truthy
  end

  it "validates status can't be any symbol" do
    assignment_invitation = build(:assignment_invitation)
    expect { assignment_invitation.update(status: :not_a_status) }.to raise_error(ArgumentError)
  end

  describe "short_key" do
    it "allows multiple invitations with nil short_key" do
      first_inv = create(:assignment_invitation)
      second_inv = create(:assignment_invitation)

      first_inv.update_attributes!(short_key: nil)
      second_inv.short_key = nil

      expect(second_inv.save).to be_truthy
    end
  end

  describe "#redeem_for" do
    let(:student) { create(:user) }

    let(:result) do
      assignment_repo = create(:assignment_repo, user: student)
      AssignmentRepo::Creator::Result.success(assignment_repo)
    end

    it "returns a AssignmentRepo::Creator::Result with the assignment repo" do
      allow(subject).to receive(:redeem_for).with(student).and_return(result)
      result = subject.redeem_for(student)

      expect(result.success?).to be_truthy
      expect(result.assignment_repo).to eql(AssignmentRepo.last)
    end

    it "fails if invitations are not enabled" do
      assignment = subject.assignment

      assignment.invitations_enabled = false
      assignment.save

      result = subject.redeem_for(student)
      expect(result.success?).to be_falsey
    end
  end

  describe "#title" do
    it "returns the assignments title" do
      expect(subject.title).to eql(subject.assignment.title)
    end
  end

  describe "#to_param" do
    it "should return the key" do
      expect(subject.to_param).to eql(subject.key)
    end
  end
end
