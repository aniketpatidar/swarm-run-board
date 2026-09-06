# frozen_string_literal: true

require "test_helper"

class Cards::AdvancementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    sign_in_as(@account)
  end

  test "advance moves a card to the next lane" do
    run = @account.runs.create!(mission: "Ship alpha", pack_kind: "four-pack")
    card = run.cards.create!(name: "Run board index", current_role: "specifier", position: 1)

    post run_card_advancement_path(run, card), as: :turbo_stream
    assert_response :success
    assert_equal "coder", card.reload.current_role
  end

  test "advance on a card in another account returns 404" do
    run = accounts(:two).runs.create!(mission: "Other", pack_kind: "two-pack")
    card = run.cards.create!(name: "Run board index", current_role: "specifier", position: 1)

    post run_card_advancement_path(run, card), as: :turbo_stream
    assert_response :not_found
  end
end
