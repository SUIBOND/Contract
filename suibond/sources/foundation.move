module suibond::foundation {
  use std::string::{ String };
  use sui::coin::{ Coin };
  use sui::sui::{ SUI };
  use sui::object_table::{Self, ObjectTable};
  use suibond::bounty::{Self, Bounty};

  public struct Foundation has key, store {
    id: UID,
    owner: address,
    foundation_cap: ID,
    name: String,
    bounty_table: ObjectTable<String, Bounty>, // key: bounty_name, value: Bounty
    bounty_table_keys: vector<String>
  }

  // ================= METHODS =================

  public fun id(foundation: &Foundation): ID {
    object::id(foundation)
  }

  public fun owner(foundation: &Foundation): address {
    foundation.owner
  }

  public fun cap(foundation: &Foundation): ID {
    foundation.foundation_cap
  }

  public fun add_bounty(foundation: &mut Foundation, bounty: Bounty) {
    foundation.bounty_table_keys.push_back(bounty.name());
    foundation.bounty_table.add(bounty.name(), bounty);
  }

  public fun add_bounty_to_foundation(
    foundation: &mut Foundation, 
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

      foundation.add_bounty(bounty);
  }
  // ================= FUNCTIONS =================


  public fun new(
    foundation_cap: ID, 
    name: String,
    ctx: &mut TxContext
    ) : Foundation {
      Foundation {
        id: object::new(ctx),
        owner: ctx.sender(),
        foundation_cap: foundation_cap,
        name: name,
        bounty_table: object_table::new(ctx),
        bounty_table_keys: vector<String>[]
      }
  }





  public fun function_for_copy(
    ctx: &mut TxContext
    ) {

  }

}