module suibond::proposal {
  use std::string::{String};
  use sui::transfer;
  use sui::coin::{Self, Coin};
  use sui::sui::{Self, SUI};
  use suibond::project::{Self, Project};


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
    stake: Coin<SUI>, // stake when create proposal with project
  }

  const CONFIRMING_DURATION: u64 = 10;

  const UNSUBMITTED: u64 = 0;
  const SUBMITTED: u64 = 1;
  const EXPIRED: u64 = 2;
  const REJECTED: u64 = 3;
  const PROCESSING: u64 = 4;
  const COMPLETED: u64 = 5;

  // ================= METHODS =================

  public fun id(proposal: &Proposal): ID {
    object::id(proposal)
  }

  public fun grant_size(proposal: &Proposal): u64 {
    proposal.grant_size
  }

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
    // proposal.project.add_stake_amount(&stake);
    proposal.stake.join(stake);
  }

  public fun set_submitted_epochs(proposal: &mut Proposal, ctx: &mut TxContext) {
    proposal.submitted_epochs = ctx.epoch();
    proposal.current_deadline_epochs = proposal.submitted_epochs + CONFIRMING_DURATION;
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
  // ================= FUNCTIONS =================


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
        stake: coin::zero(ctx),
      }

  }

  public fun create_project(ctx: &mut TxContext) {

  }

  public fun add_milestone(ctx: &mut TxContext) {

  }

  public fun add_project(ctx: &mut TxContext) {

  }
}