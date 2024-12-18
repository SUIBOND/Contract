module suibond::foundation {
  use std::string::{ String };
  use sui::object_table::{Self, ObjectTable};
  use sui::coin::{Coin};
  use sui::sui::{SUI};
  use suibond::bounty::{Bounty};
  use suibond::proposal::{Proposal};


  public struct Foundation has key, store {
    id: UID,
    owner: address,
    foundation_cap: ID,
    name: String,
    bounty_table: ObjectTable<ID, Bounty>, // key: bounty_id, value: Bounty
    bounty_table_keys: vector<ID>
  }

  // ====================================================
  // ================= Create Functions =================
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
  
  // ===========================================================
  // ================= Entry Related Functions =================
  
	// ===========================================
  // ================= Methods =================

  // Read
  // ============
  public fun id(foundation: &Foundation): ID {
    object::id(foundation)
  }

  public fun owner(foundation: &Foundation): address {
    foundation.owner
  }

  public fun cap(foundation: &Foundation): ID {
    foundation.foundation_cap
  }

  public fun risk_percent(foundation: &mut Foundation, bounty_id: ID): u64 {
    let bounty = foundation.borrow_bounty_mut(bounty_id);
    bounty.risk_percent()
  }
  
  // Borrow
  // ============
  public fun borrow_bounty_mut(foundation: &mut Foundation, bounty_id: ID): &mut Bounty {
    foundation.bounty_table.borrow_mut(bounty_id)
  }

  public fun borrow_processing_proposal( foundation: &mut Foundation, bounty_id: ID, proposal_id: ID): &mut Proposal{
    let bounty = foundation.bounty_table.borrow_mut(bounty_id);
    bounty.borrow_processing_proposal_mut(proposal_id)
  }

  // Check
  // ============
  public fun check_owner(foundation: &Foundation, ctx: &mut TxContext) {
    assert!(foundation.owner() == ctx.sender());
  }

  public fun check_cap(foundation: &Foundation, foundation_cap_id: ID) {
    assert!(foundation.cap() == foundation_cap_id);
  }
  
  // =============================================================
  // ================= Public-Mutative Functions =================
  public fun add_bounty(foundation: &mut Foundation, bounty: Bounty) {
    foundation.bounty_table_keys.push_back(bounty.id());
    foundation.bounty_table.add(bounty.id(), bounty);
  }

  public fun add_fund_to_bounty(foundation: &mut Foundation, bounty_id: ID, coin: Coin<SUI>) {
    let bounty = foundation.borrow_bounty_mut(bounty_id);
    bounty.add_fund(coin)
  }

  public fun add_proposal(foundation: &mut Foundation, bounty_id: ID, proposal: Proposal) {
    let bounty = foundation.borrow_bounty_mut(bounty_id);
    bounty.check_if_proposal_grant_size_within_bounty_range(&proposal);
    bounty.add_unconfirmed_proposal(proposal);
  }

  public fun confirm_proposal(
    foundation: &mut Foundation, 
    bounty_id: ID, 
    proposal_id: ID,
    ctx: &mut TxContext){
      let bounty = foundation.bounty_table.borrow_mut(bounty_id);
      bounty.confirm_proposal(proposal_id, ctx);
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

  public fun confirm_milestone(
    foundation: &mut Foundation, 
    bounty_id: ID, 
    proposal_id: ID,
    ctx: &mut TxContext) {
      let bounty = foundation.bounty_table.borrow_mut(bounty_id);
      bounty.confirm_milestone(proposal_id, ctx);
  }

  public fun reject_milestone(
    foundation: &mut Foundation, 
    bounty_id: ID, 
    proposal_id: ID) {
      let bounty = foundation.bounty_table.borrow_mut(bounty_id);
      bounty.reject_milestone(proposal_id);
  }

  // ==================================================
  // ================= TEST FUNCTIONS =================

}