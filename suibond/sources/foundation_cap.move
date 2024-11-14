
module suibond::foundation_cap {
  use std::string::{String};
  use suibond::foundation::{Foundation};
  use suibond::platform::{SuibondPlatform};

  public struct FoundationCap has key, store {
    id: UID,
    owner: address,
    name: String,
    url: String,
    foundation_ids: vector<ID>,
  }

  // ====================================================
  // ================= Create Functions =================
  public fun new(name: String, url: String, ctx: &mut TxContext): FoundationCap {
    FoundationCap{
      id: object::new(ctx),
      owner: ctx.sender(),
      name: name,
      url: url,
      foundation_ids: vector<ID>[],
    }
  }

  // ===========================================================
  // ================= Entry Related Functions =================
  #[allow(lint(self_transfer))]
  public fun mint(name: String, url: String, ctx: &mut TxContext) {
    let platform = new(name, url, ctx);
    transfer::public_transfer(platform, ctx.sender())
  }

  public fun register_foundation(foundation_cap: &mut FoundationCap, platform: &mut SuibondPlatform, foundation: Foundation) {
    foundation_cap.foundation_ids.push_back(foundation.id());
    platform.register_foundation(foundation);
  }

  public fun confirm_proposal(
    foundation_cap: &FoundationCap, 
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext) {
      foundation_cap.check_owner(ctx);
      platform.confirm_proposal(foundation_id, bounty_id, proposal_id, ctx);
  }

  public fun reject_proposal(
    foundation_cap: &FoundationCap, 
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext) {
      foundation_cap.check_owner(ctx);
      platform.reject_proposal(foundation_id, bounty_id, proposal_id);
  }
  // ===========================================
  // ================= Methods =================

  // Read
  // ============
  public fun id(foundation_cap: &FoundationCap): ID {
    object::id(foundation_cap)
  }

  public fun owner(foundation_cap: &FoundationCap): address {
    foundation_cap.owner
  }

  // Borrow
  // ============

  // Check
  // ============
  public fun check_owner(foundation_cap: &FoundationCap, ctx: &mut TxContext){
    assert!(foundation_cap.owner() == ctx.sender(), 100)
  }

  // =============================================================
  // ================= Public-Mutative Functions =================


  // ==================================================
  // ================= TEST FUNCTIONS =================
  
  #[test_only]
  public fun delete(foundation_cap: FoundationCap) {
    let FoundationCap {
      id: id,
      owner: _,
      name: _,
      url: _,
      foundation_ids: _,
    } = foundation_cap;
    object::delete(id);
  }

}