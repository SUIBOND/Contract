module suibond::foundation {
  use std::string::{Self, String};
  use sui::coin::{Self, Coin};
  use sui::sui::{Self, SUI};
  use sui::object_table::{ObjectTable};
  use suibond::developer::{Proposal};

  public struct FoundationCap has key, store {
    id: UID,
    owner: address,
    name: String,
    foundation_ids: vector<ID>,
  }

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

  #[allow(lint(self_transfer))]
  public fun mint_foundation_cap(name: String, ctx: &mut TxContext) {
    transfer::public_transfer(FoundationCap{
      id: object::new(ctx),
      owner: ctx.sender(),
      name: name,
      foundation_ids: vector<ID>[],
    }, ctx.sender())
  }

}