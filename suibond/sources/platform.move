
module suibond::platform {
  use std::string::{Self, String};
  use sui::coin::{Self, Coin};
  use sui::sui::{Self, SUI};
  use sui::object_table::{Self, ObjectTable};
  use sui::dynamic_object_field::{Self};
  use suibond::proposal::{Proposal};
  use suibond::foundation::{Foundation};
  use suibond::bounty::{Self, Bounty};
  
  public struct SuibondPlatform has key {
    id: UID,
    owner: address,
    foundation_table: ObjectTable<ID, Foundation>, 
    foundation_ids: vector<ID>,
  }

  // ================= METHODS =================

  public fun register_foundation(platform: &mut SuibondPlatform, foundation: Foundation) {
    platform.foundation_ids.push_back(foundation.id());
    platform.foundation_table.add(foundation.id(), foundation);
  }

  public fun borrow_foundation_mut(platform: &mut SuibondPlatform, foundation_id: ID): &mut Foundation{
    platform.foundation_table.borrow_mut(foundation_id)
  }

  public fun add_bounty(platform: &mut SuibondPlatform, foundation_id: ID, bounty: Bounty){
    let foundation = platform.borrow_foundation_mut(foundation_id);
    foundation.add_bounty(bounty);
  }

  public fun create_and_add_bounty(
    platform: &mut SuibondPlatform, 
    // foundation: &Foundation, 
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
      platform.add_bounty(foundation_id, bounty);
  }

  public fun add_proposal(platform: &mut SuibondPlatform, foundation_id: ID, bounty_id: ID, proposal: Proposal){
    let foundation = platform.borrow_foundation_mut(foundation_id);
    foundation.add_proposal(bounty_id, proposal);
  }

public fun confirm_unconfirmed_proposal(
    platform: &mut SuibondPlatform, 
    foundation_id: ID, 
    bounty_id: ID, 
    proposal_id: ID){
      let foundation = platform.borrow_foundation_mut(foundation_id);
      foundation.confirm_unconfirmed_proposal(bounty_id, proposal_id);
  }

  // ================= FUNCTIONS =================

  public fun create_and_share(ctx: &mut TxContext) {
    transfer::share_object( SuibondPlatform{
      id: object::new(ctx),
      owner: ctx.sender(),
      foundation_table: object_table::new(ctx),
      foundation_ids: vector<ID>[]
    })
  }


}