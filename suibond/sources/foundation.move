module suibond::foundation {
  use std::string::{ String };
  use sui::coin::{ Coin };
  use sui::sui::{ SUI };
  use sui::object_table::{Self, ObjectTable};
  use suibond::developer::{Proposal};
  use suibond::foundation_cap::{Self, FoundationCap};


  public struct Foundation has key, store {
    id: UID,
    owner: address,
    foundation_cap: ID,
    name: String,
    bounty_table: ObjectTable<String, Bounty>, // key: bounty_name, value: Bounty
    bounty_table_keys: vector<String>
  }

  public struct Bounty has key, store {
    id: UID,
    foundation: ID,

    name: String,
    bounty_type: u64,
    risk_percent: u64,
    min_amount: u64,
    max_amount: u64,

    coin_balance: Coin<SUI>, // need sui coin when create Bounty object

    proposals: ProposalsOfBounty
  }

  public struct ProposalsOfBounty has store {
    unconfirmed_proposal: ObjectTable<ID, Proposal>, // developer can get back Proposal with stake when the Proposal has expired
    unconfirmed_proposal_ids: vector<ID>,

    processing_proposal: ObjectTable<ID, Proposal>, 
    processing_proposal_ids: vector<ID>,

    completed_proposal: ObjectTable<ID, Proposal>, 
    completed_proposal_ids: vector<ID>,
  }

  // ================= METHODS =================

  public fun id(foundation: &Foundation): ID {
    object::id(foundation)
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