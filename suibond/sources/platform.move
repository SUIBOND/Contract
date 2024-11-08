
module suibond::platform {
  use std::string::{Self, String};
  use sui::coin::{Self, Coin};
  use sui::sui::{Self, SUI};
  use sui::object_table::{Self, ObjectTable};
  use sui::dynamic_object_field::{Self};
  use suibond::foundation::{Foundation};
  use suibond::foundation_cap::{FoundationCap};
  
  public struct SuibondPlatform has key {
    id: UID,
    owner: address,
    foundation_table: ObjectTable<ID, Foundation>, 
    foundation_ids: vector<ID>,

  }

  // ================= METHODS =================


  // ================= FUNCTIONS =================

  public fun create_and_share(ctx: &mut TxContext) {
    transfer::share_object( SuibondPlatform{
      id: object::new(ctx),
      owner: ctx.sender(),
      foundation_table: object_table::new(ctx),
      foundation_ids: vector<ID>[]
    })
  }

  public fun register_foundation(platform: &mut SuibondPlatform, foundation_cap: &FoundationCap, foundation: Foundation, ctx: &mut TxContext) {
    assert!(foundation_cap.owner() == ctx.sender(),100);
    platform.foundation_ids.push_back(foundation.id());
    dynamic_object_field::add(&mut platform.id, foundation.id(), foundation);
  }
}