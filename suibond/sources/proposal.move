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

    stake: Coin<SUI> // stake when create proposal with project
  }

  // ================= METHODS =================

  public fun id(proposal: &Proposal): ID {
    object::id(proposal)
  }

  public fun create_and_add_milestone(
    proposal: &mut Proposal,
    milestone_number: u64,
    title: String,
    description: String,
    duration_epochs: u64,
    ctx: &mut TxContext) {
      proposal.project.create_and_add_milestone(
        milestone_number, 
        title, 
        description, 
        duration_epochs, 
        ctx)
  }

  public fun stake(proposal: &mut Proposal, stake: Coin<SUI>) {
    proposal.project.add_stake_amount(&stake);
    proposal.stake.join(stake);
  }
  
  public fun set_project_state_submitted( proposal: &mut Proposal) {
      proposal.project.set_state_submitted();
  }

  public fun set_project_state_processing( proposal: &mut Proposal) {
      proposal.project.set_state_processing();
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
        grant_size,
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