module suibond::developer {
  use std::string::{String};
  use sui::transfer;
  use sui::coin::{Self, Coin};
  use sui::sui::{Self, SUI};
  use suibond::developer_cap::{Self, DeveloperCap};


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

  public struct Project has key, store {
    id: UID,
    proposal: ID,

    title: String,
    description: String,

    grant_size: u64,
    current_stake_amount: u64,

    duration_epochs: u64,
    milestones: vector<Milestone>,
    current_processing_milestone_number: u64,

    state: u64
  }

  public struct Milestone has key, store {
    id: UID,
    milestone_number: u64,

    title: String,
    description: String,

    duration_epochs: u64,

    state: u64
  }
  // ================= METHODS =================


  // ================= FUNCTIONS =================


  public fun create_proposal(ctx: &mut TxContext) {

  }

  public fun create_project(ctx: &mut TxContext) {

  }

  public fun add_milestone(ctx: &mut TxContext) {

  }

  public fun add_project(ctx: &mut TxContext) {

  }
}