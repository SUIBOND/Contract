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
  // ================= FUNCTIONS =================


  public fun new(
    developer_cap_id: ID, 
    foundation_id: ID, 
    bounty_id: ID, 
    proposal_title: String, 
    stake: Coin<SUI>, 

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
        stake: stake,
      }

  }

  public fun create_project(ctx: &mut TxContext) {

  }

  public fun add_milestone(ctx: &mut TxContext) {

  }

  public fun add_project(ctx: &mut TxContext) {

  }
}