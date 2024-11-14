module suibond::bounty {
  use std::string::{ String };
  use std::u64::{Self};
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

  const INITIAL_GRANT_PERCENT: u64 = 10;

  public struct ProposalsOfBounty has store {
    unconfirmed_proposals: ObjectTable<ID, Proposal>, // developer can get back Proposal with stake when the Proposal has expired
    unconfirmed_proposal_ids: vector<ID>,
    processing_proposals: ObjectTable<ID, Proposal>, 
    processing_proposal_ids: vector<ID>,
    completed_proposals: ObjectTable<ID, Proposal>, 
    completed_proposal_ids: vector<ID>,
  }

  // ====================================================
  // ================= Create Functions =================
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
      assert!(risk_percent <= 100, 100);
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
          unconfirmed_proposal_ids: vector<ID>[],
          processing_proposals: object_table::new<ID, Proposal>(ctx),
          processing_proposal_ids: vector<ID>[],
          completed_proposals: object_table::new<ID, Proposal>(ctx),
          completed_proposal_ids: vector<ID>[],
        }
      }
  }
  
  // ===========================================================
  // ================= Entry Related Functions =================
  
	// ===========================================
  // ================= Methods =================

  // Read
  // ============
  public fun id(bounty: &Bounty): ID {
    object::id(bounty)
  }

  public fun name(bounty: &Bounty): String {
    bounty.name
  }
  
  public fun risk_percent(bounty: &Bounty): u64 {
    bounty.risk_percent
  }

  // Borrow
  // ============
  public fun borrow_unconfirmed_proposal_mut(bounty: &mut Bounty, proposal_id: ID): &mut Proposal{
    bounty.proposals.unconfirmed_proposals.borrow_mut(proposal_id)
  }

  public fun borrow_processing_proposal_mut(bounty: &mut Bounty, proposal_id: ID,): &mut Proposal{
    bounty.proposals.processing_proposals.borrow_mut(proposal_id)
  }

  // Check
  // ============
  public fun check_if_proposal_grant_size_within_bounty_range(bounty: &Bounty, proposal: &Proposal){
    assert!(proposal.grant_size() >= bounty.min_amount && proposal.grant_size() <= bounty.max_amount,100);
  }
  
  // =============================================================
  // ================= Public-Mutative Functions =================
  public fun add_fund(bounty: &mut Bounty, coin: Coin<SUI>){
    bounty.fund.join(coin);
  }
  
  public fun add_unconfirmed_proposal(bounty: &mut Bounty, proposal: Proposal){
    bounty.proposals.unconfirmed_proposal_ids.push_back(proposal.id());
    bounty.proposals.unconfirmed_proposals.add(proposal.id(), proposal);
  }

  public fun remove_unconfirmed_proposal(bounty: &mut Bounty, proposal_id: ID): Proposal{
    let proposal = bounty.proposals.unconfirmed_proposals.remove(proposal_id);
    let (is_contain, proposal_index) = bounty.proposals.unconfirmed_proposal_ids.index_of(&proposal.id());
    if (is_contain) {
      bounty.proposals.unconfirmed_proposal_ids.remove(proposal_index);
    };
    proposal
  }

  public fun add_processing_proposal(bounty: &mut Bounty, proposal: Proposal){
    bounty.proposals.processing_proposal_ids.push_back(proposal.id());
    bounty.proposals.processing_proposals.add(proposal.id(), proposal);
  }

  public fun remove_processing_proposal(bounty: &mut Bounty, proposal_id: ID): Proposal{
    let proposal = bounty.proposals.processing_proposals.remove(proposal_id);
    let (is_contain, proposal_index) = bounty.proposals.processing_proposal_ids.index_of(&proposal.id());
    if (is_contain) {
      bounty.proposals.processing_proposal_ids.remove(proposal_index);
    };
    proposal
  }

  public fun confirm_proposal(bounty: &mut Bounty, proposal_id: ID, ctx: &mut TxContext){
      let mut proposal = bounty.remove_unconfirmed_proposal(proposal_id);

      assert!(!proposal.is_expired(ctx), 100);

      proposal.set_state_processing();
      proposal.set_confirmed_epochs(ctx);
      proposal.set_current_milestone_state_processing(ctx);

      let initial_grant_amount = u64::divide_and_round_up(proposal.grant_size() * INITIAL_GRANT_PERCENT ,100);
      proposal.add_received_grant(initial_grant_amount);
      bounty.fund.split_and_transfer(initial_grant_amount, proposal.proposer(), ctx);

      bounty.add_processing_proposal(proposal);
  }

  public fun reject_proposal(bounty: &mut Bounty, proposal_id: ID){
      let proposal = bounty.borrow_unconfirmed_proposal_mut(proposal_id);
      proposal.set_state_rejected();
  }

  public fun remove_rejected_or_expired_proposal( bounty: &mut Bounty, proposal_id: ID, ctx: &mut TxContext): Proposal {
      let proposal = bounty.remove_processing_proposal(proposal_id);
      assert!(proposal.is_expired(ctx), 100);
      assert!(proposal.is_rejected(), 100);
      proposal
  }

  public fun confirm_milestone(
    bounty: &mut Bounty, 
    proposal_id: ID,
    ctx: &mut TxContext) {
      let proposal = bounty.borrow_unconfirmed_proposal_mut(proposal_id);
      assert!(proposal.is_milestone_submitted(), 100);

      proposal.confirm_current_milestone(ctx);

      // let grant_amount = proposal.grant_size() * (proposal.duration_epochs() /1) * ((100 - INITIAL_GRANT_PERCENT) / 100); // proposal.grant_size * (project.duration_epochs / milestone_duration_epochs) * (100 - inital_grant_percent)/100
      // proposal.add_received_grant(grant_amount);
      // bounty.fund.split_and_transfer(grant_amount, proposal.proposer(), ctx);
  }

  // ==================================================
  // ================= TEST FUNCTIONS =================


}