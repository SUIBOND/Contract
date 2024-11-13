module suibond::foundation {
  use std::string::{ String };
  use sui::coin::{ Coin };
  use sui::sui::{ SUI };
  use sui::object_table::{Self, ObjectTable};
  use suibond::bounty::{Self, Bounty};
  use suibond::proposal::{Proposal};

  public struct Foundation has key, store {
    id: UID,
    owner: address,
    foundation_cap: ID,
    name: String,
    bounty_table: ObjectTable<ID, Bounty>, // key: bounty_name, value: Bounty
    bounty_table_keys: vector<ID>
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

  public fun borrow_bounty_mut(foundation: &mut Foundation, bounty_id: ID): &mut Bounty {
    foundation.bounty_table.borrow_mut(bounty_id)
  }

  public fun add_bounty(foundation: &mut Foundation, bounty: Bounty) {
    foundation.bounty_table_keys.push_back(bounty.id());
    foundation.bounty_table.add(bounty.id(), bounty);
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

  public fun get_stake_amount(foundation: &mut Foundation, bounty_id: ID, proposal_id: ID): u64 {
    let bounty = foundation.borrow_bounty_mut(bounty_id);
    bounty.get_stake_amount(proposal_id)
  }
  public fun add_proposal(foundation: &mut Foundation, bounty_id: ID, proposal: Proposal) {
    let bounty = foundation.borrow_bounty_mut(bounty_id);
    bounty.check_if_proposal_grant_size_within_bounty_range(&proposal);
    bounty.add_unconfirmed_proposal(proposal);
  }

  public fun confrim_proposal(
    foundation: &mut Foundation, 
    bounty_id: ID, 
    proposal_id: ID,
    ctx: &mut TxContext){
      let bounty = foundation.bounty_table.borrow_mut(bounty_id);
      bounty.confrim_proposal(proposal_id, ctx);
  }

  public fun reject_proposal(
    foundation: &mut Foundation, 
    bounty_id: ID, 
    proposal_id: ID){
      let bounty = foundation.bounty_table.borrow_mut(bounty_id);
      bounty.reject_proposal(proposal_id);
  }

  public fun remove_rejected_or_expired_proposal(
    foundation: &mut Foundation, 
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext): Proposal {
      let bounty = foundation.bounty_table.borrow_mut(bounty_id);
      bounty.remove_rejected_or_expired_proposal(proposal_id, ctx)
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
        bounty_table_keys: vector<ID>[]
      }
  }





  public fun function_for_copy(
    ctx: &mut TxContext
    ) {

  }

}