module suibond::bounty {
  use std::string::{ String };
  use sui::coin::{ Coin };
  use sui::sui::{ SUI };
  use sui::object_table::{Self, ObjectTable};
  use suibond::proposal::{Proposal};

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
    unconfirmed_proposals: ObjectTable<ID, Proposal>, // developer can get back Proposal with stake when the Proposal has expired
    processing_proposals: ObjectTable<ID, Proposal>, 
    completed_proposals: ObjectTable<ID, Proposal>, 
  }
  // ================= METHODS =================

  public fun id(bounty: &Bounty): ID {
    object::id(bounty)
  }

  public fun name(bounty: &Bounty): String {
    bounty.name
  }

  public fun borrow_unconfirmed_proposal_mut(bounty: &mut Bounty, proposal_id: ID): &mut Proposal{
    bounty.proposals.unconfirmed_proposals.borrow_mut(proposal_id)
  }

  public fun add_unconfirmed_proposal(bounty: &mut Bounty, proposal: Proposal){
    bounty.proposals.unconfirmed_proposals.add(proposal.id(), proposal);
  }

  public fun remove_unconfirmed_proposal(bounty: &mut Bounty, proposal_id: ID): Proposal{
    bounty.proposals.unconfirmed_proposals.remove(proposal_id)
  }

  public fun add_processing_proposal(bounty: &mut Bounty, proposal: Proposal){
    bounty.proposals.processing_proposals.add(proposal.id(), proposal);
  }

  public fun confrim_proposal(
    bounty: &mut Bounty, 
    proposal_id: ID){
      let mut proposal = bounty.remove_unconfirmed_proposal(proposal_id);

      assert!(proposal.grant_size() >= bounty.min_amount && proposal.grant_size() <= bounty.max_amount, 100);

      proposal.set_state_processing();
      bounty.add_processing_proposal(proposal);
  }

  public fun reject_proposal(
    bounty: &mut Bounty, 
    proposal_id: ID){
      let proposal = bounty.borrow_unconfirmed_proposal_mut(proposal_id);
      proposal.set_state_rejected();
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
        unconfirmed_proposals: object_table::new<ID, Proposal>(ctx),
        processing_proposals: object_table::new<ID, Proposal>(ctx),
        completed_proposals: object_table::new<ID, Proposal>(ctx),
      }
    }
  }

}