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

    grant_size: u64,
    stake: Coin<SUI>, // stake when create proposal with project
    state: u64
  }

  const UNSUBMITTED: u64 = 0;
  const SUBMITTED: u64 = 1;
  const REJECTED: u64 = 2;
  const PROCESSING: u64 = 3;
  const COMPLETED: u64 = 4;

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

  public fun set_state_submitted( proposal: &mut Proposal) {
      proposal.state = SUBMITTED;
  }

  public fun set_state_rejected( proposal: &mut Proposal) {
      proposal.state = REJECTED;
  }

  public fun set_state_processing( proposal: &mut Proposal) {
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
    duration_epochs: u64,
    ctx: &mut TxContext): Proposal {
      let proposal = object::new(ctx);
      let proposal_id = object::uid_to_inner(&proposal);
      let project = project::new(
        proposal_id,
        project_title,
        project_description,
        duration_epochs,
        ctx);
      Proposal {
        id: proposal,
        proposer: ctx.sender(),
        developer_cap: developer_cap_id,
        foundation: foundation_id,
        bounty: bounty_id,
        title: proposal_title,
        project: project,
        grant_size: grant_size,
        stake: coin::zero(ctx),
        state: UNSUBMITTED
      }

  }

  public fun create_project(ctx: &mut TxContext) {

  }

  public fun add_milestone(ctx: &mut TxContext) {

  }

  public fun add_project(ctx: &mut TxContext) {

  }
}