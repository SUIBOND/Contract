
module suibond::platform {
  use std::string::{String};
  use sui::coin::{Coin};
  use sui::sui::{SUI};
  use sui::object_table::{Self, ObjectTable};
  use suibond::proposal::{Proposal};
  use suibond::foundation::{Foundation};
  use suibond::bounty::{Self, Bounty};
  
  public struct SuibondPlatform has key {
    id: UID,
    owner: address,
    foundation_table: ObjectTable<ID, Foundation>, 
    foundation_ids: vector<ID>,
  }

  // ====================================================
  // ================= Create Functions =================
  public fun new(ctx: &mut TxContext): SuibondPlatform {
    SuibondPlatform{
      id: object::new(ctx),
      owner: ctx.sender(),
      foundation_table: object_table::new(ctx),
      foundation_ids: vector<ID>[]
    }
  }

  // ===========================================================
  // ================= Entry Related Functions =================
  public fun create_and_share(ctx: &mut TxContext) {
    transfer::share_object( SuibondPlatform{
      id: object::new(ctx),
      owner: ctx.sender(),
      foundation_table: object_table::new(ctx),
      foundation_ids: vector<ID>[]
    })
  }

  public fun create_and_add_bounty(
    platform: &mut SuibondPlatform, 
    foundation_cap_id: ID, 
    foundation_id: ID, 
    name: String,
    bounty_type: u64,
    risk_percent: u64,
    min_amount: u64,
    max_amount: u64,
    coin: Coin<SUI>,
    ctx: &mut TxContext) {
      let bounty = bounty::new(
        foundation_id,
        name,
        bounty_type,
        risk_percent,
        min_amount,
        max_amount,
        coin,
        ctx);
      platform.add_bounty(foundation_cap_id, foundation_id, bounty, ctx);
  }
  
	// ===========================================
  // ================= Methods =================

  // Read
  // ============
  public fun risk_percent(platform: &mut SuibondPlatform, foundation_id: ID, bounty_id: ID): u64{
    let foundation = platform.borrow_foundation_mut(foundation_id);
    foundation.risk_percent(bounty_id)
  }
  
  // Borrow
  // ============
  public fun borrow_foundation_mut(platform: &mut SuibondPlatform, foundation_id: ID): &mut Foundation{
    platform.foundation_table.borrow_mut(foundation_id)
  }

  public fun borrow_processing_proposal_mut(
    platform: &mut SuibondPlatform, 
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ): &mut Proposal{
    let foundation = platform.borrow_foundation_mut(foundation_id);
    foundation.borrow_processing_proposal(bounty_id, proposal_id)
  }

  // Check
  // ============
  
  // =============================================================
  // ================= Public-Mutative Functions =================
  public fun register_foundation(platform: &mut SuibondPlatform, foundation: Foundation) {
    platform.foundation_ids.push_back(foundation.id());
    platform.foundation_table.add(foundation.id(), foundation);
  }

  public fun add_bounty(platform: &mut SuibondPlatform, foundation_cap_id: ID, foundation_id: ID, bounty: Bounty, ctx: &mut TxContext){
    let foundation = platform.borrow_foundation_mut(foundation_id);
    foundation.check_owner(ctx);
    foundation.check_cap(foundation_cap_id);
    foundation.add_bounty(bounty);
  }

  public fun add_proposal(platform: &mut SuibondPlatform, foundation_id: ID, bounty_id: ID, proposal: Proposal){
    let foundation = platform.borrow_foundation_mut(foundation_id);
    foundation.add_proposal(bounty_id, proposal);
  }

  public fun confirm_proposal(
    platform: &mut SuibondPlatform, 
    foundation_id: ID, 
    bounty_id: ID, 
    proposal_id: ID,
    ctx: &mut TxContext){
      let foundation = platform.borrow_foundation_mut(foundation_id);
      foundation.confirm_proposal(bounty_id, proposal_id, ctx);
  }

  public fun reject_proposal(
    platform: &mut SuibondPlatform, 
    foundation_id: ID, 
    bounty_id: ID, 
    proposal_id: ID){
      let foundation = platform.borrow_foundation_mut(foundation_id);
      foundation.reject_proposal(bounty_id, proposal_id);
  }

  public fun remove_rejected_or_expired_proposal(
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext): Proposal {
      let foundation = platform.borrow_foundation_mut(foundation_id);
      foundation.remove_rejected_or_expired_proposal(bounty_id, proposal_id, ctx)
  }

  // ==================================================
  // ================= TEST FUNCTIONS =================
  
  #[test_only]
  public fun delete(platform: SuibondPlatform) {
    let SuibondPlatform {id: id, owner: _, foundation_table: foundation_table, foundation_ids: _} = platform;
    foundation_table.destroy_empty();
    object::delete(id);
  } 

}