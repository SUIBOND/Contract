module suibond::bounty {
  use std::string::{ String };
  use sui::coin::{ Coin };
  use sui::sui::{ SUI };
  use sui::object_table::{Self, ObjectTable};
  use suibond::developer::{Proposal};

  public struct Bounty has key, store {
    id: UID,
    foundation: ID,

    name: String,
    bounty_type: u64,
    risk_percent: u64,
    min_amount: u64,
    max_amount: u64,

    fund: Coin<SUI>, // need sui coin when create Bounty object

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

  public fun id(bounty: &Bounty): ID {
    object::id(bounty)
  }

  public fun name(bounty: &Bounty): String {
    bounty.name
  }

  // ================= FUNCTIONS =================

  public fun new(
    foundation_id: ID, 
    name: String,
    bounty_type: u64,
    risk_percent: u64,
    min_amount: u64,
    max_amount: u64,
    coin: Coin<SUI>,
    ctx: &mut TxContext
    ) : Bounty {
    Bounty {
      id: object::new(ctx),
      foundation: foundation_id,
      name: name,
      bounty_type: bounty_type,
      risk_percent: risk_percent,
      min_amount: min_amount,
      max_amount: max_amount,
      fund: coin,
      proposals: ProposalsOfBounty{
        unconfirmed_proposal: object_table::new<ID, Proposal>(ctx),
        unconfirmed_proposal_ids: vector<ID>[],

        processing_proposal: object_table::new<ID, Proposal>(ctx),
        processing_proposal_ids: vector<ID>[],

        completed_proposal: object_table::new<ID, Proposal>(ctx),
        completed_proposal_ids: vector<ID>[],
      }
    }
  }

}