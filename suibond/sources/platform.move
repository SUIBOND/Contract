
module suibond::platform {
  use std::string::{Self, String};
  use sui::coin::{Self, Coin};
  use sui::sui::{Self, SUI};
  use sui::object_table::{Self, ObjectTable};
  use sui::dynamic_object_field::{Self};
  use suibond::foundation::{Foundation};
  use suibond::foundation_cap::{FoundationCap};
  use suibond::bounty::{Self, Bounty};
  
  public struct SuibondPlatform has key {
    id: UID,
    owner: address,
    foundation_table: ObjectTable<ID, Foundation>, 
    foundation_ids: vector<ID>,
  }

  // ================= METHODS =================

  public fun add_bounty_fo_foundation(platform: &mut SuibondPlatform, foundation: &Foundation, bounty: Bounty){
    let foundation = platform.foundation_table.borrow_mut(foundation.id());
    foundation.add_bounty(bounty);
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

  public fun register_foundation(platform: &mut SuibondPlatform, foundation: Foundation) {
    platform.foundation_ids.push_back(foundation.id());
    dynamic_object_field::add(&mut platform.id, foundation.id(), foundation);
  }

  public fun add_bounty_to_foundation_in_platform(
    platform: &mut SuibondPlatform, 
    foundation: &Foundation, 
    name: String,
    bounty_type: u64,
    risk_percent: u64,
    min_amount: u64,
    max_amount: u64,
    coin: Coin<SUI>,
    ctx: &mut TxContext) {
      let bounty = bounty::new(
        foundation.id(),
        name,
        bounty_type,
        risk_percent,
        min_amount,
        max_amount,
        coin,
        ctx);
      platform.add_bounty_fo_foundation(foundation, bounty);
  }
}