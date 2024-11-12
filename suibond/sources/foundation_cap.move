
module suibond::foundation_cap {
  use std::string::{String};
  use sui::dynamic_object_field::{Self};
  use suibond::foundation::{Self, Foundation};
  use suibond::platform::{SuibondPlatform};

  public struct FoundationCap has key, store {
    id: UID,
    owner: address,
    name: String,
    foundation_ids: vector<ID>,
  }

  // ================= METHODS =================

  public fun id(foundation_cap: &FoundationCap): ID {
    object::id(foundation_cap)
  }

  public fun owner(foundation_cap: &FoundationCap): address {
    foundation_cap.owner
  }

  public fun add_foundation(foundation_cap: &mut FoundationCap, foundation: &Foundation) {
    assert!(foundation_cap.foundation_ids.length() <= 1, 100); // for easy version. it can store only one foundation

    foundation_cap.foundation_ids.push_back(foundation.id());
  }

  public fun check_owner(foundation_cap: &FoundationCap, ctx: &mut TxContext){
    assert!(foundation_cap.owner() == ctx.sender(), 100)

  }

  public fun confrim_proposal(
    foundation_cap: &FoundationCap, 
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext) {
      foundation_cap.check_owner(ctx);

      platform.confirm_unconfirmed_proposal(foundation_id, bounty_id, proposal_id);
  }

  // ================= FUNCTIONS =================

  fun new(name: String, ctx: &mut TxContext): FoundationCap {
    FoundationCap{
      id: object::new(ctx),
      owner: ctx.sender(),
      name: name,
      foundation_ids: vector<ID>[],
    }
  }

  #[allow(lint(self_transfer))]
  public fun mint(name: String, ctx: &mut TxContext) {
    let platform = new(name, ctx);
    transfer::public_transfer(platform, ctx.sender())
  }


}