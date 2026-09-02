# frozen_string_literal: true

require_relative "../test/test_helper"
require "rantly/property"

class ActiveSupport::TestCase
  def property_of(&block)
    Rantly::Property.new(block)
  end
end

class RunPropertyTest < ActiveSupport::TestCase
  setup do
    @account = Account.create!(name: "Prop Account", email_address: "prop-#{rand(1_000_000)}@example.com", password: "password")
  end

  test "a run built from any mission and a valid pack kind is valid" do
    property_of {
      mission = array(range(1, 200)) { choose(*(("a".."z").to_a + [ " ", "\n", "-" ])) }.join
      [ mission, choose(*Run::PACK_KINDS) ]
    }.check(50) { |(mission, pack_kind)|
      run = @account.runs.new(mission: mission, pack_kind: pack_kind)
      assert run.valid?, "expected valid run for mission=#{mission.inspect} pack_kind=#{pack_kind.inspect}: #{run.errors.full_messages}"
      assert_includes Run::PACK_KINDS, run.pack_kind
    }
  end

  test "a run rejects any pack kind outside the allowed set" do
    property_of {
      string
    }.check(50) { |garbage|
      run = @account.runs.new(mission: "Any mission", pack_kind: garbage)
      if Run::PACK_KINDS.include?(garbage)
        assert run.valid?
      else
        assert_not run.valid?, "expected invalid pack_kind=#{garbage.inspect}"
        assert_includes run.errors[:pack_kind], "is not included in the list"
      end
    }
  end

  test "a run rejects any status outside the allowed set" do
    property_of {
      string
    }.check(50) { |garbage|
      run = @account.runs.new(mission: "Any mission", pack_kind: "two-pack", status: garbage)
      if Run::STATUSES.include?(garbage)
        assert run.valid?
      else
        assert_not run.valid?, "expected invalid status=#{garbage.inspect}"
        assert_includes run.errors[:status], "is not included in the list"
      end
    }
  end

  test "a persisted valid run round-trips its attributes unchanged" do
    property_of {
      mission = array(range(1, 120)) { choose(*(("a".."z").to_a + [ " " ])) }.join
      [ mission, choose(*Run::PACK_KINDS), choose(*Run::STATUSES) ]
    }.check(50) { |(mission, pack_kind, status)|
      run = @account.runs.create!(mission: mission, pack_kind: pack_kind, status: status)
      reloaded = Run.find(run.id)

      assert_equal mission, reloaded.mission
      assert_equal pack_kind, reloaded.pack_kind
      assert_equal status, reloaded.status
      assert_equal run.started_at.to_i, reloaded.started_at.to_i
      assert_equal run.account_id, reloaded.account_id

      run.destroy!
    }
  end

  test "newest_first orders runs by created_at descending" do
    property_of {
      n = range(1, 8)
      [ n, (1..n).map { rand }.sort.reverse ]
    }.check(25) { |(n, shuffle_keys)|
      account = Account.create!(name: "Order Account", email_address: "order-#{rand(1_000_000)}@example.com", password: "password")

      runs = shuffle_keys.each_with_index.map do |k, i|
        run = account.runs.create!(mission: "run #{i}", pack_kind: "two-pack")
        run.update_column(:created_at, Time.zone.at(k))
        run
      end

      expected = runs.map(&:id)
      actual = account.runs.newest_first.map(&:id)
      assert_equal expected, actual
    }
  end
end
