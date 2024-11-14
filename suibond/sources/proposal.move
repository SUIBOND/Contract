module suibond::proposal {
  use std::string::{String};
  use sui::coin::{Self, Coin};
  use sui::sui::{Self, SUI};
  use suibond::project::{Self, Project};
  use suibond::milestone::{Self};


  public struct Proposal has key, store {
    id: UID,
    proposer: address,
    developer_cap: ID,
    foundation: ID,
    bounty: ID,

    title: String,
    project: Project,
    
    state: u64,
    submitted_epochs: u64,
    confirmed_epochs: u64,
    completed_epochs: u64,
    current_deadline_epochs: u64,

    grant_size: u64,
    received_grant: u64,
    stake: Coin<SUI>, // stake when create proposal with project
  }

  // ====================================================
  // ================= Constants =================

  // Duration
  // ============
  const CONFIRMING_DURATION: u64 = 10;
  const MILESTONE_CONFIRMING_DURATION: u64 = 5;
  

  // Proposal State
  // ============
  const UNSUBMITTED: u64 = 0;

  const SUBMITTED: u64 = 1;
  const EXPIRED: u64 = 2;
  const REJECTED: u64 = 3;

  const PROCESSING: u64 = 4;
  const MILESTONE_SUBMITTED: u64 = 5;

  const COMPLETED: u64 = 6;

  // ====================================================
  // ================= Create Functions =================
  public fun new(
    developer_cap_id: ID, 
    foundation_id: ID, 
    bounty_id: ID, 
    proposal_title: String, 
    project_title: String,
    project_description: String,
    grant_size: u64,
    ctx: &mut TxContext): Proposal {
      let proposal = object::new(ctx);
      let proposal_id = object::uid_to_inner(&proposal);
      let project = project::new(
        proposal_id,
        project_title,
        project_description,
        ctx);
      Proposal {
        id: proposal,
        proposer: ctx.sender(),
        developer_cap: developer_cap_id,
        foundation: foundation_id,
        bounty: bounty_id,
        title: proposal_title,
        project: project,
        state: UNSUBMITTED,
        submitted_epochs: 0,
        confirmed_epochs: 0,
        completed_epochs: 0,
        current_deadline_epochs: 0,
        grant_size: grant_size,
        received_grant: 0,
        stake: coin::zero(ctx),
      }
  }
  
  // ===========================================================
  // ================= Entry Related Functions =================
  
	// ===========================================
  // ================= Methods =================

  // Read
  // ============
  public fun id(proposal: &Proposal): ID {
    object::id(proposal)
  }

  public fun grant_size(proposal: &Proposal): u64 {
    proposal.grant_size
  }

  public fun received_grant(proposal: &Proposal): u64 {
    proposal.received_grant
  }

  public fun proposer(proposal: &Proposal): address {
    proposal.proposer
  }

  public fun state(proposal: &Proposal): u64 {
    proposal.state
  }

  public fun duration_epochs(proposal: &Proposal): u64 {
    proposal.project.duration_epochs()
  }
  
  // Borrow
  // ============

  // Check
  // ============
  public fun is_expired(proposal: &Proposal, ctx: &mut TxContext): bool {
    proposal.current_deadline_epochs < ctx.epoch()
  }

  public fun is_rejected(proposal: &Proposal): bool {
    proposal.state == REJECTED
  }

  public fun is_processing(proposal: &Proposal): bool {
    proposal.state == PROCESSING
  }

  public fun is_milestone_submitted(proposal: &mut Proposal): bool {
    proposal.state == MILESTONE_SUBMITTED
  }

  // Set
  // ============
  public fun add_received_grant(proposal: &mut Proposal, amount: u64) {
    proposal.received_grant = proposal.received_grant + amount;
  }

  public fun set_submitted_and_deadline_epochs(proposal: &mut Proposal, ctx: &mut TxContext) {
    proposal.submitted_epochs = ctx.epoch();
    proposal.current_deadline_epochs = proposal.submitted_epochs + CONFIRMING_DURATION;
  }

  public fun set_confirmed_epochs(proposal: &mut Proposal, ctx: &mut TxContext) {
    proposal.confirmed_epochs = ctx.epoch();
    proposal.current_deadline_epochs = proposal.confirmed_epochs + proposal.project.duration_epochs();
  }
  
  public fun set_state_submitted(proposal: &mut Proposal) {
    proposal.state = SUBMITTED;
  }

  public fun set_state_expired(proposal: &mut Proposal) {
    proposal.state = EXPIRED;
  }

  public fun set_state_rejected(proposal: &mut Proposal) {
    proposal.state = REJECTED;
  }

  public fun set_state_processing(proposal: &mut Proposal) {
    proposal.state = PROCESSING;
  }

  public fun set_state_milestone_submitted(proposal: &mut Proposal) {
    proposal.state = MILESTONE_SUBMITTED;
  }

  public fun set_state_completed(proposal: &mut Proposal) {
    proposal.state = COMPLETED;
  }

  public fun set_current_milestone_state_processing(proposal: &mut Proposal, ctx: &mut TxContext) {
    let milestone = proposal.project.borrow_current_processing_milestone_mut();
    milestone.set_state_processing();
    milestone.set_deadline_epochs(ctx);
  }
  
  // =============================================================
  // ================= Public-Mutative Functions =================
  public fun create_and_add_milestone(
    proposal: &mut Proposal,
    title: String,
    description: String,
    duration_epochs: u64,
    ctx: &mut TxContext) {
      proposal.project.create_and_add_milestone(
        title, 
        description, 
        duration_epochs, 
        ctx)
  }

  public fun stake(proposal: &mut Proposal, stake: Coin<SUI>) {
    proposal.stake.join(stake);
  }

  public fun submit_milestone(proposal: &mut Proposal, milestone_submission_id: ID, ctx: &mut TxContext) {
    let milestone = proposal.project.borrow_current_processing_milestone_mut();

    if (milestone.is_expired(ctx)) {
      // slashing

    };

    milestone.submit_milestone(milestone_submission_id, ctx);
    proposal.set_state_milestone_submitted();
  }

  public fun request_extend_deadline_of_milestone(proposal: &mut Proposal, ctx: &mut TxContext) {
    proposal.project.request_extend_deadline_of_milestone(ctx);
    proposal.current_deadline_epochs = proposal.current_deadline_epochs + milestone::CONST_EXTENDING_DURATION_EPOCHS();
  }

  public fun unstake(proposal: &mut Proposal, ctx: &mut TxContext) {
    let stake_amount = proposal.stake.balance().value();
    let unstake = proposal.stake.split(stake_amount, ctx);
    sui::transfer(unstake, proposal.proposer);
  }

  public fun confirm_current_milestone(proposal: &mut Proposal, ctx: &mut TxContext) {
    let milestone = proposal.project.borrow_current_processing_milestone_mut();
    milestone.set_state_confirmed();

    if (proposal.project.is_last_milestone()) {
      proposal.set_state_completed();
    } else {
      proposal.project.next_milestone();
      proposal.set_state_processing();
    };

    // grant 일부  전송

  }

  public fun slasing(proposal: &mut Proposal) {
  }

  // ==================================================
  // ================= TEST FUNCTIONS =================
}